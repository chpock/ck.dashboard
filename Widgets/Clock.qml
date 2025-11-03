import Quickshell
import QtQuick
import qs

Base {
    id: root

    property int fontSize: 40
    property int spacing: 4
    property int colonCorrection: -3

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Item {
        id: clock
        implicitHeight: Math.max(hours.implicitHeight, minutes.implicitHeight)
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: hours.implicitWidth + colon.implicitWidth + minutes.implicitWidth + root.spacing * 2

        Text {
            id: hours
            text: Qt.formatDateTime(systemClock.date, "hh")
            color: Theme.text.normal
            font.pixelSize: root.fontSize
            font.bold: true
        }

        Text {
            id: colon
            text: ':'
            color: Theme.text.normal
            font.pixelSize: root.fontSize
            anchors.left: hours.right
            anchors.leftMargin: root.spacing
            y: root.colonCorrection
        }

        Text {
            id: minutes
            text: Qt.formatDateTime(systemClock.date, "mm")
            color: Theme.text.normal
            font.pixelSize: root.fontSize
            anchors.left: colon.right
            anchors.leftMargin: root.spacing
        }

    }

}
