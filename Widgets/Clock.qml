pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs
import qs.Elements as E

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var hours: QtObject {
            property int fontSize: 40
            property int fontWeight: Font.Bold
            property color color: Theme.text.color.normal
        }
        readonly property var minutes: QtObject {
            property int fontSize: 40
            property int fontWeight: Font.Normal
            property color color: Theme.text.color.normal
        }
        readonly property var separator: QtObject {
            property int fontSize: 40
            property int fontWeight: Font.Normal
            property color color: Theme.text.color.normal
            property int offset: -3
        }
        property int spacing: 5
        readonly property var padding: QtObject {
            property int top: 13
            property int bottom: 5
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Item {
        id: clock
        implicitHeight: Math.max(hours.implicitHeight, minutes.implicitHeight) + root.theme.padding.top + root.theme.padding.bottom
        implicitWidth: hours.implicitWidth + colon.implicitWidth + minutes.implicitWidth + root.theme.spacing * 2
        anchors.horizontalCenter: parent.horizontalCenter

        E.Text {
            id: hours
            text: Qt.formatDateTime(systemClock.date, "hh")
            color: root.theme.hours.color
            fontSize: root.theme.hours.fontSize
            fontWeight: root.theme.hours.fontWeight
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: root.theme.padding.top
            capitalOnly: true
        }

        E.Text {
            id: colon
            text: ':'
            anchors.left: hours.right
            anchors.leftMargin: root.theme.spacing
            anchors.top: parent.top
            anchors.topMargin: root.theme.padding.top + root.theme.separator.offset
            color: root.theme.separator.color
            fontSize: root.theme.separator.fontSize
            fontWeight: root.theme.separator.fontWeight
            capitalOnly: true
        }

        E.Text {
            id: minutes
            text: Qt.formatDateTime(systemClock.date, "mm")
            anchors.left: colon.right
            anchors.leftMargin: root.theme.spacing
            anchors.top: parent.top
            anchors.topMargin: root.theme.padding.top
            color: root.theme.minutes.color
            fontSize: root.theme.minutes.fontSize
            fontWeight: root.theme.minutes.fontWeight
            capitalOnly: true
        }

    }

}
