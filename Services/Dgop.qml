pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import '../utils.js' as Utils

Singleton {
    id: root

    signal available()

    property bool running: false

    readonly property QtObject subscribers: QtObject {
        property int infoCPU: 0
        property int infoMemory: 0
        property int infoNetwork: 0
        property int infoDisk: 0
        property int infoMounts: 0
        property int processesByCPU: 0
        property int processesByRAM: 0
    }

    signal updateInfoCPU(var data)
    signal updateInfoMemory(var data)
    signal updateInfoNetwork(var data)
    signal updateInfoDisk(var data)
    signal updateInfoMounts(var data)
    signal updateProcessesByCPU(var data)
    signal updateProcessesByRAM(var data)

    // TODO: add ability to specify random port number by environment variable API_PORT.
    // Also, detect somehow that dgop failed to bind specified port and restart it with other port number.
    Process {
        id: dgopProc
        command: ["dgop", "server"]
        running: false

        // stderr: SplitParser {
        //     splitMarker: "\n"
        //     onRead: line => {
        //         console.log('[DGOP]', line)
        //     }
        // }
        //
        // stdout: SplitParser {
        //     splitMarker: "\n"
        //     onRead: line => {
        //         console.log('[DGOP]', line)
        //     }
        // }

        onExited: exitCode => {
            console.warn('dgop service exited with code:', exitCode)
            if (!restartTimer.running) {
                console.log('restart dgop in 5 seconds...')
                restartTimer.start()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: dgopProc.running = true
    }

    Timer {
        id: startupTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: dgopProc.running = true
    }

    Timer {
        id: healthCheck
        interval: 500
        running: true
        repeat: true
        onTriggered: doHealthCheck()
    }

    Timer {
        id: infoCPU
        interval: 1000
        repeat: true
        running: root.running && subscribers.infoCPU > 0
        onTriggered: getInfoCPU()
    }

    Timer {
        id: infoMemory
        interval: 1000
        repeat: true
        running: root.running && subscribers.infoMemory > 0
        onTriggered: getInfoMemory()
    }

    Timer {
        id: infoNetwork
        interval: 1000
        repeat: true
        running: root.running && subscribers.infoNetwork > 0
        onTriggered: getInfoNetwork()
    }

    Timer {
        id: infoDisk
        interval: 1000
        repeat: true
        running: root.running && subscribers.infoDisk > 0
        onTriggered: getInfoDisk()
    }

    Timer {
        id: processesByCPU
        interval: 5000
        repeat: true
        running: root.running && subscribers.processesByCPU > 0
        onTriggered: getProcessesByCPU()
    }

    Timer {
        id: processesByRAM
        interval: 5000
        repeat: true
        running: root.running && subscribers.processesByRAM > 0
        onTriggered: getProcessesByRAM()
    }

    Timer {
        id: infoMounts
        interval: 10000
        repeat: true
        running: root.running && subscribers.infoMounts > 0
        onTriggered: getInfoMounts()
    }

    function triggerAll() {
        if (!root.running) return
        if (subscribers.infoCPU > 0) getInfoCPU()
        if (subscribers.infoMemory > 0) getInfoMemory()
        if (subscribers.infoNetwork > 0) getInfoNetwork()
        if (subscribers.infoDisk > 0) getInfoDisk()
        if (subscribers.infoMounts > 0) getInfoMounts()
        if (subscribers.processesByCPU > 0) getProcessesByCPU()
        if (subscribers.processesByRAM > 0) getProcessesByRAM()
    }

    function subscribe(event) {
        ++root.subscribers[event]
    }

    function unsubscribe(event) {
        --root.subscribers[event]
    }

    function request(path, query, callback) {

        const xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if(xhr.readyState !== XMLHttpRequest.DONE) return
            const responseText = xhr.responseText.toString()
            var processed = false
            if (xhr.status === 200) {
                try {
                    const response = responseText === "OK" ? responseText : JSON.parse(responseText)
                    try {
                        callback(response)
                        processed = true
                    }
                    catch (e) {
                        console.warn('Error in callback:', e, 'response:', responseText)
                    }
                }
                catch (e) {
                    console.warn('Unable to parse JSON from dgop response:', e, 'response:', responseText)
                }
            } else {
                console.warn('HTTP request failed, status code:', xhr.status + '; response:', responseText)
            }
            if (!processed) {
                callback(null)
            }
        }

        var url = 'http://localhost:63484' + path
        if (query && Object.keys(query).length) {
            var parts = []
            for (var k in query) {
                var v = query[k]
                parts.push(encodeURIComponent(k) + "=" + encodeURIComponent(String(v)))
            }
            url += '?' + parts.join("&")
        }
        // console.log("Request URL", url)
        xhr.open('GET', url)

        xhr.send()

        return {
            abort: function() { try { xhr.abort() } catch(e) {} }
        }

    }

    function doHealthCheck() {

        if (!dgopProc.running) {
            if (running) running = false
            return
        }

        request('/health', {}, function(data) {
            if (data === "OK") {
                if (running) return
                running = true
                root.available()
                root.triggerAll()
            } else {
                if (!running) return
                running = false
            }
        })

    }

    property string cursorInfoCPU: ""
    function getInfoCPU() {
        if (!running) return null
        return request('/gops/cpu', {
            'cursor': cursorInfoCPU,
        }, function(data) {
            if (!data) return
            cursorInfoCPU = data.data.cursor
            root.updateInfoCPU(data.data)
        })
    }

    // Disk rates in dgop is too spiky. Let's smooth them out by taking
    // the average of the last 3 measurements.
    property int avgWinSizeDiskRate: 3
    property var readAvgDiskRate: Utils.movingAverage(() => avgWinSizeDiskRate)
    property var writeAvgDiskRate: Utils.movingAverage(() => avgWinSizeDiskRate)
    property string cursorInfoDisk: ""
    function getInfoDisk() {
        if (!running) return null
        return request('/gops/disk-rate', {
            'cursor': cursorInfoDisk,
        }, function(data) {
            if (!data) return
            cursorInfoDisk = data.cursor
            let readrate = 0
            let writerate = 0
            for (let i = 0; i < data.disks.length; ++i) {
                const diskData = data.disks[i]
                readrate += diskData.readrate
                writerate += diskData.writerate
            }
            root.updateInfoDisk({
                "readrate": readAvgDiskRate.push(readrate),
                "writerate": writeAvgDiskRate.push(writerate),
            })
        })
    }

    // Convert to bytes a string produced by this function:
    // https://github.com/AvengeMedia/dgop/blob/ae15dd44ae1c5f00cdbc6b405b468f58d860d277/gops/disk.go#L69
    function unformatBytes(val) {
        const units = "BKMGTPE"
        const lastChar = val[val.length - 1]
        const power = units.indexOf(lastChar)
        if (power === -1) {
            console.error("Unable to unformatBytes:", JSON.stringify(val))
            return 0
        }
        const numPart = val.slice(0, -1)
        const result = parseFloat(numPart)
        return Math.round(result * Math.pow(1024, power))
    }

    function getInfoMounts() {
        if (!running) return null
        return request('/gops/disk/mounts', {}, function(data) {
            if (!data) return
            const callbackData = data.data.map(function(item) {
                return {
                    'device': item.device,
                    'mount':  item.mount,
                    'fstype': item.fstype,
                    "size":   root.unformatBytes(item.size),
                    "used":   root.unformatBytes(item.used),
                    "avail":  root.unformatBytes(item.avail),
                }
            })
            root.updateInfoMounts(callbackData)
        })
    }

    function getInfoMemory() {
        if (!running) return null
        return request('/gops/memory', {}, function(data) {
            if (!data) return
            root.updateInfoMemory(data.data)
        })
    }

    function splitCommand(fullCommand) {
        let splitIdx = fullCommand.indexOf(" ")
        let command = (splitIdx === -1) ? fullCommand : fullCommand.slice(0, splitIdx)
        let args = (splitIdx === -1) ? "" : fullCommand.slice(splitIdx + 1)
        if (command.charAt(0) === "/") {
            splitIdx = command.lastIndexOf("/")
            if (splitIdx !== -1) {
                command = command.slice(splitIdx + 1)
            }
        }
        return [command, args]
    }

    property string cursorProcessesByCPU: ""
    function getProcessesByCPU() {
        if (!running) return null
        return request('/gops/processes', {
            'cursor': cursorProcessesByCPU,
            'sort_by': 'cpu',
            'limit': 5,
        }, function(data) {
            if (!data) return
            cursorProcessesByCPU = data.cursor
            const callbackData = data.data.filter(function(item) {
                return item.command !== 'dgop'
            }).map(function(item) {
                let splitCommand = root.splitCommand(item.fullCommand)
                return {
                    'command': splitCommand[0],
                    'args': splitCommand[1],
                    'pid': item.pid,
                    'value': item.cpu,
                }
            })
            root.updateProcessesByCPU(callbackData)
        })
    }

    property string cursorProcessesByRAM: ""
    function getProcessesByRAM() {
        if (!running) return null
        return request('/gops/processes', {
            'cursor': cursorProcessesByRAM,
            'sort_by': 'memory',
            'limit': 5,
        }, function(data) {
            if (!data) return
            cursorProcessesByRAM = data.cursor
            const callbackData = data.data.map(function(item) {
                let splitCommand = root.splitCommand(item.fullCommand)
                return {
                    'command': splitCommand[0],
                    'args': splitCommand[1],
                    'pid': item.pid,
                    'value': item.memoryKB * 1024,
                }
            })
            root.updateProcessesByRAM(callbackData)
        })
    }

    property string cursorInfoNetwork: ""
    // Network rates in dgop is too spiky. Let's smooth them out by taking
    // the average of the last 3 measurements.
    property int avgWinSizeNetworkRate: 3
    property var rxAvgNetworkRate: Utils.movingAverage(() => avgWinSizeNetworkRate)
    property var txAvgNetworkRate: Utils.movingAverage(() => avgWinSizeNetworkRate)
    function getInfoNetwork(callback) {
        if (!running) return null
        return request('/gops/net-rate', {
            'cursor': cursorInfoNetwork,
        }, function(data) {
            if (!data) return
            cursorInfoNetwork = data.cursor
            const callbackData = {
                rxrate: rxAvgNetworkRate.push(data.interfaces[0].rxrate),
                txrate: rxAvgNetworkRate.push(data.interfaces[0].rxrate),
            }
            root.updateInfoNetwork(callbackData)
        })
    }

}
