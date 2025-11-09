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
    }

    readonly property int firstDayOfWeek: {
        return Qt.locale().firstDayOfWeek % 7
    }

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

        E.Text {
            id: headerIconLeft
            anchors.left: parent.left
            text: "\u25C0"
            color: headerIconLeftHover.hovered ? root.theme.heading.buttons.colorHover : root.theme.heading.buttons.color
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
            color: Theme.text.normal
        }

        E.Text {
            id: headerIconCurrent
            anchors.right: headerIconRight.left
            anchors.rightMargin: wordSpacing * 3
            text: "\u2B24"
            color: headerIconCurrentHover.hovered ? root.theme.heading.buttons.colorHover : root.theme.heading.buttons.color
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
            color: headerIconRightHover.hovered ? root.theme.heading.buttons.colorHover : root.theme.heading.buttons.color
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
                readonly property bool isToday: dayDate.toDateString() === systemClock.date.toDateString()

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

}
