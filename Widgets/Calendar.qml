import Quickshell
import QtQuick
import QtQuick.Shapes
import qs
import qs.Components as Component
import qs.Providers as Provider

Base {
    id: root

    readonly property var dayNames: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
    readonly property int firstDayOfWeek: {
        return Qt.locale().firstDayOfWeek % 7
    }

    readonly property int dayBackgroundSpacing: 3

    function changeMonth(direction) {
        if (direction === 0) {
            calendar.currentDate = Qt.binding(() => systemClock.date)
        } else {
            const d = new Date(calendar.currentDate)
            // reset to first day to avoid overflow when we increate month
            d.setDate(1)
            // increment month
            d.setMonth(d.getMonth() + direction)
            // bound to system time if result month/year match current month/year
            if (d.getMonth() === systemClock.date.getMonth() && d.getYear() === systemClock.date.getYear()) {
                changeMonth(0)
            } else {
                calendar.currentDate = d
            }
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Hours
    }

    Item {
        id: header
        implicitHeight: Math.max(headerIconLeft.implicitHeight, headerText.implicitHeight, headerIconCurrent.implicitHeight, headerIconRight.implicitHeight)
        implicitWidth: parent.width

        Text {
            id: headerIconLeft
            anchors.left: parent.left
            text: "\u25C0"
            color: headerIconLeftHover.hovered ? Theme.palette.belizehole : Theme.text.grey
            font.pixelSize: Theme.text.size
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

        Text {
            id: headerText
            text: Qt.formatDate(calendar.currentDate, "MMMM, yyyy")
            horizontalAlignment: Text.AlignHCenter
            anchors.left: headerIconLeft.right
            anchors.right: headerIconRight.left
            color: Theme.text.normal
            font.pixelSize: Theme.text.size
        }

        Text {
            id: headerIconCurrent
            anchors.right: headerIconRight.left
            anchors.rightMargin: 8
            text: "\u2B24"
            color: headerIconCurrentHover.hovered ? Theme.palette.belizehole : Theme.text.grey
            font.pixelSize: Theme.text.size
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

        Text {
            id: headerIconRight
            anchors.right: parent.right
            text: "\u25B6"
            color: headerIconRightHover.hovered ? Theme.palette.belizehole : Theme.text.grey
            font.pixelSize: Theme.text.size
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

        property date currentDate: systemClock.date
        readonly property date startDate: {
            const monthStartDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
            let dateDiff = monthStartDate.getDay()
            dateDiff = (dateDiff + 7 - root.firstDayOfWeek) % 7
            monthStartDate.setDate(1 - dateDiff)
            return monthStartDate
        }
        property int dayCellWidth: 0

        width: (dayCellWidth + root.dayBackgroundSpacing * 2) * columns + columnSpacing * (columns - 1)
        columns: 7
        rows: 7
        rowSpacing: 2
        columnSpacing: 4
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
                        ? dayNames[(index + root.firstDayOfWeek) % 7]
                        : dayDate.getDate()
                readonly property bool isWeekend: dayDate.getDay() % 6 === 0
                readonly property bool isCurrentMonth: dayDate.getMonth() == calendar.currentDate.getMonth()
                readonly property bool isCurrentWeekDay: dayDate.getDay() == calendar.currentDate.getDay()
                readonly property bool isToday: dayDate.toDateString() === systemClock.date.toDateString()
                readonly property color dayColor: {
                    if (isDayName)
                        return Theme.palette.belizehole
                    if (!isCurrentMonth)
                        return Theme.palette.asbestos
                    if (isToday)
                        return Theme.palette.clouds
                    if (isWeekend)
                        return Theme.palette.alizarin
                    return Theme.palette.clouds
                }
                readonly property color dayBackgroundColor: isToday && isCurrentMonth ? Theme.palette.belizehole : 'transparent'
                readonly property int dayFontWeight: (isDayName && isCurrentWeekDay) || isToday ? Font.Bold : Font.Normal

                width: dayBackground.width
                height: dayBackground.height
                color: 'transparent'
                border.width: hover.hovered && !isDayName ? 1 : 0
                border.color: Theme.palette.belizehole

                HoverHandler {
                    id: hover
                }

                Rectangle {
                    id: dayBackground

                    width: calendar.dayCellWidth + root.dayBackgroundSpacing * 2
                    height: dayText.implicitHeight
                    color: day.dayBackgroundColor
                    // border.width: 1

                    Text {
                        id: dayText
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: calendar.dayCellWidth
                        text: day.dayText
                        color: day.dayColor
                        font.weight: day.dayFontWeight
                        horizontalAlignment: Text.AlignRight
                        onImplicitWidthChanged: {
                            if (implicitWidth > calendar.dayCellWidth)
                                calendar.dayCellWidth = implicitWidth
                        }
                    }
                }

            }
        }
    }

}
