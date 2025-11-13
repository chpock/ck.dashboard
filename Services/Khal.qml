pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool running: false
    property string formatDatetime: ''
    // In QML/JS 'yy' is parsed incorrectly. I.e. '25' is translated to 1925, but not to 2025.
    // This flag indicates whether the epoch in the dates needs to be corrected.
    property bool correctDatetimeEpoch: false
    property bool vdirsyncerAvailable: false

    signal updateEvents(var data)
    signal available()
    signal unavailable()

    Timer {
        id: startupTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: startupProc.running = true
    }

    Timer {
        id: checkVdirsyncerTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: checkVdirsyncerProc.running = true
    }

    Timer {
        id: checkTimer
        interval: 1000 * 60 * 5
        running: root.running
        repeat: true
        onTriggered: checkProc.running = true
    }

    // Additionally update events on hours changed. This will update events when the day changes.
    SystemClock {
        id: systemClock
        enabled: root.running
        precision: SystemClock.Hours
        onHoursChanged: {
            checkProc.running = true
        }
    }

    function refresh() {
        if (root.vdirsyncerAvailable) {
            refreshVdirsyncerProc.running = true
        } else {
            checkProc.running = true
        }
    }

    function parseFormat(format, type) {
        const replacements = {
            'date': [
                '21',   'dd',   'day',
                '12',   'MM',   'month',
                '2013', 'yyyy', 'year',
                '13',   'yy',   'year',
            ],
            'time': [
                '21', 'HH', 'hour',
                '45', 'mm', 'minute',
                '00', 'ss', 'second',
                '09', 'hh', 'hour12',
                'pm', 'ap', 'ampm',
            ]
        }
        const replacement = replacements[type]
        let found = []
        for (let i = 0; i < replacement.length; i += 3) {
            const from = replacement[i]
            if (!format.includes(from)) continue
            const to = replacement[i + 1]
            format = format.replace(from, to)
            const flag = replacement[i + 2]
            found.push(flag)
        }
        return [format, found]
    }

    function parseDateFormat(format) {
        let [parsedFormat, found] = parseFormat(format, 'date')
        for (let flag of ['day', 'month', 'year']) {
            if (!found.includes(flag)) {
                console.error('[Service.Khal]', `could not detect ${flag} in date format '${format}'`)
                return ''
            }
        }
        return parsedFormat
    }

    function parseTimeFormat(format) {
        let [parsedFormat, found] = parseFormat(format, 'time')
        let missing = ''
        if (!found.includes('minute')) {
            missing = 'minutes'
        } else if (!found.includes('hour') && !found.includes('hour12')) {
            missing = 'hours'
        } else if (found.includes('hour12') && !found.includes('ampm')) {
            missing = 'AM/PM indicator'
        } else {
            return parsedFormat
        }
        console.error('[Service.Khal]', `could not detect ${missing} in time format '${format}'`)
        return ''
    }

    Process {
        id: startupProc
        property bool success: false
        command: ['khal', 'printformats']
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let timeformat = ''
                let dateformat = ''
                const lines = text.split('\n')
                for (let line of lines) {
                    if (line.startsWith('timeformat: ')) {
                        timeformat = line.substring(line.indexOf(':') + 2)
                    } else if (line.startsWith('dateformat: ')) {
                        dateformat = line.substring(line.indexOf(':') + 2)
                    }
                }
                if (timeformat === '' || dateformat === '') {
                    console.warn('khal:', "could not detect 'timeformat:' or 'dateformat:' in 'khal printformats' output")
                    return
                }
                dateformat = parseDateFormat(dateformat)
                if (dateformat === '') return
                timeformat = parseTimeFormat(timeformat)
                if (timeformat === '') return
                root.correctDatetimeEpoch = !dateformat.includes('yyyy') && dateformat.includes('yy')
                root.formatDatetime = dateformat + '@##@##@' + timeformat
                startupProc.success = true
            }
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                console.warn('[Service.Khal/startupProc]', 'stderr:', line)
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.error('[Service.Khal/startupProc]', 'khal finished with exit code:', exitCode)
                startupProc.success = false
            }
            if (startupProc.success) {
                root.running = true
                // We don't need to trigger checkProc here. As we enable root.running,
                // systemClock will be enabled also. This will trigger hours change in it.
                // And hours change will trigger checkProc.
                root.available()
                startupProc.success = false
            } else {
                root.running = false
                root.unavailable()
            }
        }
    }

    Process {
        id: checkProc
        property var output: []
        command: [
            'khal', 'list', 'today', '2d',
            '--json', 'title',
            '--json', 'start-date', '--json', 'start-time',
            '--json', 'end-date', '--json', 'end-time',
            '--json', 'calendar',
        ]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {

                let events
                try {
                    events = JSON.parse(line)
                }
                catch (e) {
                    console.warn('[Service.Khal/checkProc]', 'unable to parse JSON from khal output:', e, 'output:', line)
                    return
                }

                for (let event of events) {

                    let validated = true

                    for (let field of ['start-date', 'start-time', 'end-date', 'end-time', 'title']) {
                        if (!event.hasOwnProperty(field)) {
                            console.warn('[Service.Khal/checkProc]', `there is no property '${field}' in event:`,
                                JSON.stringify(event))
                            validated = false
                        }
                    }
                    if (!validated) continue

                    let title = event['title']
                    let start = event['start-date'] + '@##@##@' + event['start-time']
                    let end = event['end-date'] + '@##@##@' + event['end-time']
                    let calendarId = event.hasOwnProperty('calendar') ? event['calendar'] : 'unknown'

                    const eventId = Qt.md5(start + end + title)

                    try {
                        start = Date.fromLocaleString(Qt.locale(), start, root.formatDatetime)
                    }
                    catch (e) {
                        console.warn('[Service.Khal/checkProc]', `failed to apply format '${root.formatDatetime}'`,
                            `to start date/time from event: '${start}'`)
                        continue
                    }
                    if (root.correctDatetimeEpoch) start.setFullYear(start.getFullYear() + 100)

                    try {
                        end = Date.fromLocaleString(Qt.locale(), end, root.formatDatetime)
                    }
                    catch (e) {
                        console.warn('[Service.Khal/checkProc]', `failed to apply format '${root.formatDatetime}'`,
                            `to end date/time from event: '${end}'`)
                        continue
                    }
                    if (root.correctDatetimeEpoch) end.setFullYear(end.getFullYear() + 100)

                    checkProc.output.push({
                        'calendarId': calendarId,
                        'eventId':    eventId,
                        'title':      title,
                        'start':      start,
                        'end':        end,
                    })

                }
            }
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                console.warn('[Service.Khal/checkProc]', 'stderr:', line)
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.error('[Service.Khal/checkProc]', 'khal finished with exit code:', exitCode)
            } else {
                root.updateEvents(checkProc.output)
            }
            checkProc.output = []
        }
    }

    Process {
        id: checkVdirsyncerProc
        command: ['vdirsyncer', 'showconfig']
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.info('[Service.Khal/checkVdirsyncerProc]', 'vdirsyncer: unavailable')
                root.vdirsyncerAvailable = false
            } else {
                console.info('[Service.Khal/checkVdirsyncerProc]', 'vdirsyncer: available')
                root.vdirsyncerAvailable = true
            }
        }
    }

    Process {
        id: refreshVdirsyncerProc
        property string output: ""
        command: ['vdirsyncer', 'sync']
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                refreshVdirsyncerProc.output += line + "\n"
            }
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                refreshVdirsyncerProc.output += '[stderr] ' + line + "\n"
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                Quickshell.execDetached([
                    "notify-send",
                    "-u", "critical",
                    "-a", "ck.dashboard",
                    "-i", "error",
                    "vdirsyncer refresh failed",
                    refreshVdirsyncerProc.output,
                ])
            } else {
                Quickshell.execDetached([
                    "notify-send", "-e",
                    "-u", "normal",
                    "-a", "ck.dashboard",
                    "vdirsyncer sucessfully refreshed",
                ])
                checkProc.running = true
            }
            refreshVdirsyncerProc.output = ""
        }
    }
}
