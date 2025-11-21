pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var heading: QtObject {
            readonly property var buttons: QtObject {
                property color color: Theme.palette.silver
                property color colorHover: Theme.palette.belizehole
                property color colorActive: Theme.palette.pumpkin
            }
        }
        readonly property var days: QtObject {
            readonly property var names: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
            property int fontSize: Theme.text.fontSize.small
            readonly property var color: QtObject {
                property color name: Theme.palette.belizehole
                property color weekend: Theme.palette.pomegranate
                property color normal: Theme.text.color.normal
                property color today: Theme.text.color.normal
                property color other: Theme.text.color.grey
                property color border: Theme.palette.belizehole
            }
            readonly property var background: QtObject {
                property color normal: 'transparent'
                property color today: Theme.palette.belizehole
            }
            readonly property var fontWeight: QtObject {
                property int normal: Font.Normal
                property int today: Font.Bold
            }
            readonly property var spacing: QtObject {
                property int horizontal: 3
                property int vertical: 3
            }
            readonly property var padding: QtObject {
                property int top: 3
                property int bottom: 3
                property int left: 3
                property int right: 3
            }
        }
        readonly property var events: QtObject {
            // 600 seconds = 10 minutes
            property int alarmOffsetSeconds: 600
            readonly property var padding: QtObject {
                property int top: 2
                property int bottom: 1
            }
            readonly property var header: QtObject {
                readonly property var padding: QtObject {
                    property int top: 2
                    property int bottom: 0
                }
            }
            property int spacing: 2
            readonly property var timer: QtObject {
                readonly property var color: QtObject {
                    property color normal: Theme.text.color.normal
                    property color soon: Theme.palette.carrot
                    property color inProgress: Theme.palette.pomegranate
                }
            }
            readonly property var farInFuture: QtObject {
                // 4 hours
                // 60 * 60 * 4 = 14400
                property int excludeOffsetSeconds: 14400
                property color color: Theme.palette.asbestos
            }
        }
    }

    property var calendarColors
    property bool loaded: false

    readonly property int firstDayOfWeek: {
        return Qt.locale().firstDayOfWeek % 7
    }

    function changeCalendarColor(calendarId) {

        let colorIdx = -1
        if (calendarId in calendarColors) {
            const colorNameOld = calendarColors[calendarId]
            colorIdx = Theme.paletteColorNames.indexOf(colorNameOld)
        }
        colorIdx += 1
        if (colorIdx >= Theme.paletteColorNames.length) {
            // Re-create an object to trigger changes in bindings
            const calendarColorsNew = Object.assign({}, calendarColors)
            delete calendarColorsNew[calendarId]
            calendarColors = calendarColorsNew
        } else {
            const colorNameNew = Theme.paletteColorNames[colorIdx]
            // Re-create an object to trigger changes in bindings
            calendarColors = Object.assign({}, calendarColors, { [calendarId]: colorNameNew })
        }

    }

    function changeMonth(direction) {
        if (direction === 0) {
            calendar.currentDate = Qt.binding(() => systemClockDate.date)
        } else {
            const d = new Date(calendar.currentDate)
            // reset to first day to avoid overflow when we increate month
            d.setDate(1)
            // increment month
            d.setMonth(d.getMonth() + direction)
            // bound to system time if result month/year match current month/year
            if (d.getMonth() === systemClockDate.date.getMonth() && d.getYear() === systemClockDate.date.getYear()) {
                changeMonth(0)
            } else {
                calendar.currentDate = d
            }
        }
    }

    SystemClock {
        id: systemClockDate
        precision: SystemClock.Hours
        readonly property string dateString: date.toDateString()
    }

    Item {
        id: header
        implicitHeight: Math.max(headerIconLeft.implicitHeight, headerText.implicitHeight, headerIconCurrent.implicitHeight, headerIconRight.implicitHeight)
        implicitWidth: parent.width

        readonly property alias isHovered: headerHH.hovered
        HoverHandler {
            id: headerHH
        }

        E.Icon {
            id: headerIconLeft
            icon: 'keyboard_double_arrow_left'
            weight: 700
            anchors.left: parent.left
            color:
                headerIconLeftHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: header.isHovered
            HoverHandler {
                id: headerIconLeftHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: root.changeMonth(-1)
            }
        }

        E.TextTitle {
            id: headerText
            text: Qt.formatDate(calendar.currentDate, "MMMM, yyyy")
            horizontalAlignment: Text.AlignHCenter
            hasColon: false
            hasSpace: false
            anchors.left: parent.left
            anchors.right: parent.right
        }

        E.Icon {
            id: headerIconCurrent
            icon: 'today'
            anchors.right: headerIconRight.left
            anchors.rightMargin: wordSpacing
            color:
                headerIconCurrentHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: header.isHovered
            HoverHandler {
                id: headerIconCurrentHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: root.changeMonth(0)
            }
        }

        E.Icon {
            id: headerIconRight
            icon: 'keyboard_double_arrow_right'
            weight: 700
            anchors.right: parent.right
            color:
                headerIconRightHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: header.isHovered
            HoverHandler {
                id: headerIconRightHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: root.changeMonth(1)
            }
        }
    }

    Grid {
        id: calendar

        property date currentDate: systemClockDate.date
        readonly property date startDate: {
            const monthStartDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
            let dateDiff = monthStartDate.getDay()
            dateDiff = (dateDiff + 7 - root.firstDayOfWeek) % 7
            monthStartDate.setDate(1 - dateDiff)
            return monthStartDate
        }
        property int dayCellWidth: 0

        width: (dayCellWidth + root.theme.days.padding.left + root.theme.days.padding.right) * columns + columnSpacing * (columns - 1)
        columns: 7
        rows: 7
        rowSpacing: root.theme.days.spacing.vertical
        columnSpacing: root.theme.days.spacing.horizontal
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: 49

            Rectangle {
                id: day

                required property int index
                readonly property bool isDayName: index < 7 ? true : false
                readonly property date dayDate: {
                    const date = new Date(calendar.startDate)
                    date.setDate(date.getDate() + index - 7)
                    return date
                }

                readonly property string dayText:
                    isDayName
                        ? root.theme.days.names[(index + root.firstDayOfWeek) % 7]
                        : dayDate.getDate()

                readonly property bool isWeekend: dayDate.getDay() % 6 === 0
                readonly property bool isCurrentMonth: dayDate.getMonth() == calendar.currentDate.getMonth()
                readonly property bool isCurrentWeekDay: dayDate.getDay() == calendar.currentDate.getDay()
                readonly property bool isToday: dayDate.toDateString() === systemClockDate.dateString

                readonly property color dayColor: {
                    if (isDayName)
                        return root.theme.days.color.name
                    if (!isCurrentMonth)
                        return root.theme.days.color.other
                    if (isToday)
                        return root.theme.days.color.today
                    if (isWeekend)
                        return root.theme.days.color.weekend
                    return root.theme.days.color.normal
                }

                readonly property color dayBackgroundColor:
                    isToday && isCurrentMonth
                        ? root.theme.days.background.today
                        : root.theme.days.background.normal

                readonly property int dayFontWeight:
                    (isDayName && isCurrentWeekDay) || isToday
                        ? root.theme.days.fontWeight.today
                        : root.theme.days.fontWeight.normal

                width: dayBackground.width
                height: dayBackground.height
                color: 'transparent'
                border.width: hover.hovered && !isDayName ? 1 : 0
                border.color: root.theme.days.color.border

                HoverHandler {
                    id: hover
                }

                Rectangle {
                    id: dayBackground

                    width: calendar.dayCellWidth + root.theme.days.padding.left + root.theme.days.padding.right
                    height: dayText.implicitHeight + root.theme.days.padding.top + root.theme.days.padding.bottom
                    color: day.dayBackgroundColor

                    E.Text {
                        id: dayText
                        width: calendar.dayCellWidth
                        text: day.dayText
                        color: day.dayColor
                        heightMode: E.Text.Capitals
                        fontSize: root.theme.days.fontSize
                        fontWeight: day.dayFontWeight
                        horizontalAlignment: Text.AlignRight
                        anchors.right: parent.right
                        anchors.rightMargin: root.theme.days.padding.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: root.theme.days.padding.bottom
                        onImplicitWidthChanged: {
                            if (implicitWidth > calendar.dayCellWidth)
                                calendar.dayCellWidth = implicitWidth
                        }
                    }
                }

            }
        }
    }

    SystemClock {
        id: systemClockTimeMinutes
        precision: SystemClock.Minutes
        enabled: Provider.Calendar.running
    }

    SystemClock {
        id: systemClockTimeSeconds
        precision: SystemClock.Seconds
        enabled: Provider.Calendar.running
    }

    Item {
        id: headerEvent
        implicitHeight: Math.max(
                headerEventText.implicitHeight,
                headerEventIconRefresh.implicitHeight,
                headerEventIconToggleVisibility.implicitHeight,
                headerEventIconPlus.implicitHeight,
                headerEventIconMinus.implicitHeight
            ) +
            root.theme.events.header.padding.top + root.theme.events.header.padding.bottom
        implicitWidth: parent.width
        visible: Provider.Calendar.running

        readonly property alias isHovered: headerEventHH.hovered
        HoverHandler {
            id: headerEventHH
        }

        E.TextTitle {
            id: headerEventText
            text: 'Events'
            hasSpace: false
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            anchors.right: parent.right
        }

        E.Icon {
            id: headerEventIconRefresh
            icon: 'refresh'
            anchors.right: headerEventIconToggleVisibility.left
            anchors.rightMargin: wordSpacing * 3
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            color:
                headerEventIconRefreshHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: headerEvent.isHovered
            HoverHandler {
                id: headerEventIconRefreshHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.refresh()
            }
        }

        E.Icon {
            id: headerEventIconToggleVisibility
            icon: 'visibility_lock'
            anchors.right: headerEventIconPlus.left
            anchors.rightMargin: wordSpacing * 3
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            color:
                headerEventIconToggleVisibilityHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : Provider.Calendar.eventUpcomingShowHidden
                        ? root.theme.heading.buttons.colorActive
                        : root.theme.heading.buttons.color
            visible: headerEvent.isHovered
            HoverHandler {
                id: headerEventIconToggleVisibilityHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.eventsUpcomingToggleVisibility()
            }
        }

        E.Icon {
            id: headerEventIconPlus
            icon: 'add_circle'
            anchors.right: headerEventIconMinus.left
            anchors.rightMargin: wordSpacing
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            color:
                headerEventIconPlusHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: headerEvent.isHovered
            HoverHandler {
                id: headerEventIconPlusHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.eventsUpcomingChangeAmount(1)
            }
        }

        E.Icon {
            id: headerEventIconMinus
            icon: 'remove_circle'
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            color:
                headerEventIconMinusHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: headerEvent.isHovered
            HoverHandler {
                id: headerEventIconMinusHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.eventsUpcomingChangeAmount(-1)
            }
        }
    }

    Repeater {
        model: Provider.Calendar.eventsUpcomingModel

        Item {
            id: event
            required property var modelData

            visible: Provider.Calendar.running

            implicitHeight: root.theme.events.padding.top +
                Math.max(icon.implicitHeight, title.implicitHeight) +
                root.theme.events.spacing +
                leftTime.implicitHeight +
                root.theme.events.padding.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            readonly property bool isHidden: Provider.Calendar.eventsUpcomingIsHidden(modelData.eventId)
            readonly property bool isEmpty: modelData.eventId === ''

            readonly property real startDiff: (modelData.start.getTime() - systemClockTimeMinutes.date.getTime()) / 10 ** 3
            readonly property bool isInProgress: startDiff < 0
            readonly property bool isSoon: startDiff <= root.theme.events.alarmOffsetSeconds
            readonly property bool isFarInFuture:
                !isInProgress &&
                modelData.start.toDateString() !== systemClockDate.dateString &&
                startDiff > root.theme.events.farInFuture.excludeOffsetSeconds

            readonly property alias isHovered: eventHH.hovered
            HoverHandler {
                id: eventHH
            }

            E.Icon {
                id: icon
                icon:
                    event.isInProgress
                        ? 'event_upcoming'
                        : event.isSoon
                            ? 'alarm'
                            : 'event'
                color:
                    event.isInProgress
                        ? root.theme.events.timer.color.inProgress
                        : event.isSoon
                            ? root.theme.events.timer.color.soon
                            : event.isFarInFuture
                                ? root.theme.events.farInFuture.color
                                : root.theme.events.timer.color.normal
                grade: -25
                filled: true
                weight: 400
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: root.theme.events.padding.top
                visible: !event.isEmpty
            }

            Item {
                id: title
                implicitHeight: Math.max(titleText.implicitHeight, titleIcon.implicitHeight)
                implicitWidth: titleText.implicitWidth + titleIcon.implicitWidth
                anchors.left: icon.right
                anchors.leftMargin: titleText.wordSpacing * 2
                anchors.right: event.isHovered ? hideIcon.left : parent.right
                anchors.rightMargin: event.isHovered ? titleText.wordSpacing : undefined
                anchors.verticalCenter: icon.verticalCenter

                E.Text {
                    id: titleText
                    text: event.modelData.title
                    overflow: E.Text.OverflowElide
                    anchors.left: parent.left
                    width: Math.min(implicitWidth, parent.width - titleIcon.implicitWidth)
                    fontStrikeout: event.isHidden
                    color: event.isFarInFuture ? root.theme.events.farInFuture.color : undefined
                }

                E.Text {
                    id: titleIcon
                    anchors.left: titleText.right
                    anchors.right: parent.right
                    text:
                        event.isEmpty
                            ? ''
                            : event.modelData.calendarId in root.calendarColors
                                ? " \u25CF "
                                : " \u25CB "
                    color:
                        event.modelData.calendarId in root.calendarColors
                            ? Theme.palette[root.calendarColors[event.modelData.calendarId]]
                            : titleText.color
                    visible: (event.modelData.calendarId in root.calendarColors) || event.isHovered
                    HoverHandler {
                        enabled: !event.isEmpty
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: root.changeCalendarColor(event.modelData.calendarId)
                    }
                }

            }

            E.Icon {
                id: hideIcon
                icon: event.isHidden ? 'visibility' : 'visibility_off'
                anchors.right: parent.right
                anchors.verticalCenter: icon.verticalCenter
                color:
                    hideIconHover.hovered
                        ? root.theme.heading.buttons.colorHover
                        : root.theme.heading.buttons.color
                visible: event.isHovered && !event.isEmpty
                HoverHandler {
                    id: hideIconHover
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Provider.Calendar.eventsUpcomingToggleEventVisibility(event.modelData.eventId)
                }
            }

            E.Text {
                id: details
                preset: 'details'
                fontStrikeout: event.isHidden
                text: {
                    if (event.isEmpty) return ''

                    function getNiceDate(date, diff) {
                        if (diff === 0) {
                            return "Today"
                        } else if (diff === 1) {
                            return "Tomorrow"
                        } else if (diff === -1) {
                            return "Yesterday"
                        }
                        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                    }

                    const today = new Date(systemClockDate.date.getFullYear(),
                    systemClockDate.date.getMonth(), systemClockDate.date.getDate())

                    const startDay = new Date(event.modelData.start.getFullYear(),
                        event.modelData.start.getMonth(), event.modelData.start.getDate())
                    const startDiff = Math.floor((startDay - today) / 86400000)

                    const endDay = new Date(event.modelData.end.getFullYear(),
                        event.modelData.end.getMonth(), event.modelData.end.getDate())
                    const endDiff = Math.floor((endDay - today) / 86400000)

                    const result = getNiceDate(startDay, startDiff) + ', ' +
                        event.modelData.start.toLocaleTimeString(Qt.locale(), Locale.ShortFormat) +
                        ' - '

                    if (startDiff === endDiff) {
                        return result + event.modelData.end.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    }

                    return result + getNiceDate(endDay, endDiff) + ', ' +
                        event.modelData.end.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                }
                anchors.left: title.left
                overflow: E.Text.OverflowElide
                anchors.right: leftTime.left
                anchors.rightMargin: wordSpacing * 2
                anchors.bottom: leftTime.bottom
            }

            E.Text {
                readonly property var eventTime: event.modelData.start.getTime()
                readonly property var currentTime: systemClockTimeSeconds.date.getTime()
                readonly property int eventTimeDiff: Math.abs((eventTime - currentTime) / 10 ** 3)
                readonly property bool isInProgress: currentTime >= eventTime ? true : false
                id: leftTime
                text: {
                    if (event.modelData.eventId === '') return ''
                    const sign = isInProgress && eventTimeDiff > 0 ? '-' : ''
                    const days = Math.floor(eventTimeDiff / 86400)
                    const hours = Math.floor((eventTimeDiff % 86400) / 3600)
                    if (days > 0) {
                        return `${sign}${days}d ${hours}h`
                    }
                    const minutes = Math.floor((eventTimeDiff % 3600) / 60)
                    if (hours > 0) {
                        return `${sign}${hours}h ${minutes}m`
                    }
                    if (minutes > 9) {
                        return `${sign}${minutes}m`
                    }
                    const seconds = eventTimeDiff % 60
                    if (minutes > 0) {
                        return `${sign}${minutes}m ${seconds}s`
                    }
                    return `${sign}${seconds}s`
                }
                anchors.right: parent.right
                anchors.top: title.bottom
                anchors.topMargin: root.theme.events.spacing
                fontStrikeout: event.isHidden
                color:
                    isInProgress
                        ? root.theme.events.timer.color.inProgress
                        : eventTimeDiff < root.theme.events.alarmOffsetSeconds
                            ? root.theme.events.timer.color.soon
                            : event.isFarInFuture
                                ? root.theme.events.farInFuture.color
                                : root.theme.events.timer.color.normal
            }

        }
    }

    Component.onCompleted: {
        try {
            calendarColors = JSON.parse(SettingsData.stateGet('Widget.Calendar.calendarColors', '{}'))
        }
        catch (e) {
            calendarColors = {}
        }
        loaded = true
    }

    onCalendarColorsChanged: {
        if (!loaded) return
        SettingsData.stateSet('Widget.Calendar.calendarColors', JSON.stringify(calendarColors))
    }

}
