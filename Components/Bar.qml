import QtQuick
import Quickshell
import qs

Item {
    id: root

    required property color color

    property real maxValue: 100.0
    property real value: 0
    property real paddingTop: Theme.bar.padding
    property real paddingBottom: Theme.bar.padding

    implicitHeight: Theme.bar.height + paddingTop + paddingBottom

    // Background (empty part)
    Rectangle {
        id: background
        anchors.topMargin: parent.paddingTop
        anchors.bottomMargin: parent.paddingBottom
        anchors.fill: parent
        color: Theme.bar.background
        height: Theme.bar.height
    }

    // Foreground (filled part)
    Rectangle {
        id: foreground
        anchors.topMargin: parent.paddingTop
        anchors.bottomMargin: parent.paddingBottom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: Theme.bar.height
        width: root.maxValue > 0 ? parent.width * root.value / root.maxValue : 0
        color: root.color
    }
}
