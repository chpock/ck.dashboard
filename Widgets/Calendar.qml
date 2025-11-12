import Quickshell
import QtQuick
import QtQuick.Shapes
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
        }
    }

    readonly property int firstDayOfWeek: {
        return Qt.locale().firstDayOfWeek % 7
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
    }

    Item {
        id: header
        implicitHeight: Math.max(headerIconLeft.implicitHeight, headerText.implicitHeight, headerIconCurrent.implicitHeight, headerIconRight.implicitHeight)
        implicitWidth: parent.width

        E.Text {
            id: headerIconLeft
            anchors.left: parent.left
            text: "\u25C0"
            color:
                headerIconLeftHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: root.isHovered
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

        E.Text {
            id: headerIconCurrent
            anchors.right: headerIconRight.left
            anchors.rightMargin: wordSpacing * 3
            text: "\u2B24"
            color:
                headerIconCurrentHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: root.isHovered
            HoverHandler {
                id: headerIconCurrentHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: root.changeMonth(0)
            }
        }

        E.Text {
            id: headerIconRight
            anchors.right: parent.right
            text: "\u25B6"
            color:
                headerIconRightHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: root.isHovered
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

                readonly property bool isDayName: index < 7 ? true : false
                readonly property date dayDate: {
                    const date = new Date(parent.startDate)
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
                readonly property bool isToday: dayDate.toDateString() === systemClockDate.date.toDateString()

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
                        capitalOnly: true
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
        implicitHeight: Math.max(headerEventText.implicitHeight) +
            root.theme.events.header.padding.top + root.theme.events.header.padding.bottom
        implicitWidth: parent.width
        visible: Provider.Calendar.running

        E.TextTitle {
            id: headerEventText
            text: 'Events'
            hasSpace: false
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            anchors.right: parent.right
        }

        E.Text {
            id: headerEventIconToggleVisibility
            anchors.right: headerEventIconPlus.left
            anchors.rightMargin: wordSpacing * 3
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            text: "\u{1F441}"
            color:
                headerEventIconToggleVisibilityHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : Provider.Calendar.eventUpcomingShowHidden
                        ? root.theme.heading.buttons.colorActive
                        : root.theme.heading.buttons.color
            visible: root.isHovered
            HoverHandler {
                id: headerEventIconToggleVisibilityHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.eventsUpcomingToggleVisibility()
            }
        }

        E.Text {
            id: headerEventIconPlus
            anchors.right: headerEventIconMinus.left
            anchors.rightMargin: wordSpacing
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            text: "\u2295"
            color:
                headerEventIconPlusHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: root.isHovered
            HoverHandler {
                id: headerEventIconPlusHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Provider.Calendar.eventsUpcomingChangeAmount(1)
            }
        }

        E.Text {
            id: headerEventIconMinus
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: root.theme.events.header.padding.top
            text: "\u2296"
            color:
                headerEventIconMinusHover.hovered
                    ? root.theme.heading.buttons.colorHover
                    : root.theme.heading.buttons.color
            visible: root.isHovered
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
            required property var modelData

            visible: Provider.Calendar.running

            implicitHeight: root.theme.events.padding.top +
                Math.max(icon.implicitHeight, title.implicitHeight) +
                root.theme.events.spacing +
                leftTime.implicitHeight +
                root.theme.events.padding.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            // ⏰ U+23F0 - Alarm Clock
            // ⏳ U+23F3 - Hourglass Not Done
            // ⌛ U+231B - Hourglass Done
            // ⌚ U+231A - Watch
            E.Text {
                id: icon
                text: {
                    if (modelData.eventId === '') return ''
                    const startDiff = (modelData.start.getTime() - systemClockTimeMinutes.date.getTime()) / 10 ** 3
                    if (startDiff <= 0) {
                        // Event is in progress, return "Hourglass Not Done" icon
                        return "\u23F3 "
                    }
                    // Event is not started yet
                    if (startDiff <= root.theme.events.alarmOffsetSeconds) {
                        // Alarm icon
                        return "\u23F0 "
                    }
                    // Default icon is "Watch"
                    return "\u231A "
                }
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: root.theme.events.padding.top
            }

            E.Text {
                id: title
                text: modelData.title
                elide: Text.ElideRight
                anchors.left: icon.right
                anchors.right: root.isHovered ? hideIcon.left : parent.right
                anchors.verticalCenter: icon.verticalCenter
                fontStrikeout: Provider.Calendar.eventsUpcomingIsHidden(modelData.eventId)
            }

            E.Text {
                id: hideIcon
                anchors.right: parent.right
                anchors.verticalCenter: icon.verticalCenter
                text: "\u{1F441}"
                color:
                    hideIconHover.hovered
                        ? root.theme.heading.buttons.colorHover
                        : root.theme.heading.buttons.color
                visible: root.isHovered
                HoverHandler {
                    id: hideIconHover
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Provider.Calendar.eventsUpcomingToggleEventVisibility(modelData.eventId)
                }
            }

            E.Text {
                id: details
                preset: 'details'
                fontStrikeout: Provider.Calendar.eventsUpcomingIsHidden(modelData.eventId)
                text: {
                    if (modelData.eventId === '') return ''

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

                    const startDay = new Date(modelData.start.getFullYear(),
                        modelData.start.getMonth(), modelData.start.getDate())
                    const startDiff = Math.floor((startDay - today) / 86400000)

                    const endDay = new Date(modelData.end.getFullYear(),
                        modelData.end.getMonth(), modelData.end.getDate())
                    const endDiff = Math.floor((endDay - today) / 86400000)

                    const result = getNiceDate(startDay, startDiff) + ', ' +
                        modelData.start.toLocaleTimeString(Qt.locale(), Locale.ShortFormat) +
                        ' - '

                    if (startDiff === endDiff) {
                        return result + modelData.end.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    }

                    return result + getNiceDate(endDay, endDiff) + ', ' +
                        modelData.end.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                }
                anchors.left: title.left
                elide: Text.ElideRight
                anchors.right: leftTime.left
                anchors.bottom: leftTime.bottom
            }

            E.Text {
                id: leftTime
                text: {
                    if (modelData.eventId === '') return ''
                    let startDiff = (modelData.start.getTime() - systemClockTimeSeconds.date.getTime()) / 10 ** 3
                    const sign = startDiff < 0 ? '-' : ''
                    startDiff = Math.abs(startDiff)
                    const hours = Math.floor(startDiff / 3600)
                    const minutes = Math.floor((startDiff % 3600) / 60)
                    if (hours > 0) {
                        return `${sign}${hours}h ${minutes}m`
                    }
                    if (minutes > 10) {
                        return `${sign}${minutes}m`
                    }
                    const seconds = startDiff % 60
                    if (minutes > 0) {
                        return `${sign}${minutes}m ${seconds}s`
                    }
                    return `${sign}${seconds}s`
                }
                anchors.right: parent.right
                anchors.top: title.bottom
                anchors.topMargin: root.theme.events.spacing
                fontStrikeout: Provider.Calendar.eventsUpcomingIsHidden(modelData.eventId)
            }

        }
    }

}
