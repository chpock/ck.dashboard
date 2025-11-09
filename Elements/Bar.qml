import QtQuick
import Quickshell
import qs

Item {
    id: root

    required property color color

    property real maxValue: 100.0
    property real value: 0

    implicitHeight: Theme.bar.height

    // Background (empty part)
    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.bar.inactive
        height: Theme.bar.height
    }

    // Foreground (filled part)
    Rectangle {
        id: foreground
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: Theme.bar.height
        width: root.maxValue > 0 ? parent.width * root.value / root.maxValue : 0
        color: root.color
    }
}
