import Quickshell
import QtQuick
import qs

Rectangle {
    id: root

    default property alias content: content.data

    border {
        color: Theme.border.color
        width: Theme.border.width
    }
    color: Theme.background

    width: parent.width
    implicitHeight: content.implicitHeight + Theme.padding.vertical * 2 + Theme.border.width * 2

    HoverHandler {
        id: hh
    }

    readonly property bool isHovered: hh.hovered

    Column {
        id: content
        y: Theme.padding.vertical + Theme.border.width
        spacing: Theme.spacing
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.padding.horizontal + Theme.border.width
    }
}
