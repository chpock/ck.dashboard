pragma ComponentBehavior: Bound

import QtQuick
import qs

Rectangle {
    id: root

    default property alias content: content.data

    border {
        color: Theme.base.border.color
        width: Theme.base.border.width
    }
    color: Theme.base.background

    width: parent.width
    implicitHeight: content.implicitHeight + Theme.base.padding.vertical * 2 + Theme.base.border.width * 2

    HoverHandler {
        id: hh
    }

    readonly property bool isHovered: hh.hovered

    Column {
        id: content
        y: Theme.base.padding.vertical + Theme.base.border.width
        spacing: Theme.base.spacing.horizontal
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.base.padding.horizontal + Theme.base.border.width
    }
}
