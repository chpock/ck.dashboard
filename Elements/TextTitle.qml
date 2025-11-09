import QtQuick
import qs
import qs.Elements as E

Item {
    id: root

    property int horizontalAlignment: Text.AlignLeft
    property alias text: titleObj.text
    property alias color: titleObj.color
    property bool hasColon: true
    property bool hasSpace: true

    property string preset: ""

    readonly property int spacing: hasSpace ? 2 * titleObj.wordSpacing : 0

    implicitHeight: Math.max(titleObj.implicitHeight, hasColon ? colonObj.implicitHeight : 0)
    implicitWidth: titleObj.implicitWidth + (hasColon ? colonObj.implicitWidth : 0) + spacing

    E.Text {
        id: titleObj
        preset: root.preset !== "" ? root.preset : 'title'
        anchors.left:
            root.horizontalAlignment === Text.AlignHCenter
                ? parent.left
                : root.horizontalAlignment === Text.AlignLeft
                    ? parent.left
                    : undefined
        anchors.right:
            root.horizontalAlignment === Text.AlignHCenter
                ? parent.right
                : root.horizontalAlignment === Text.AlignRight
                    ? root.hasColon
                        ? colonObj.left
                        : parent.right
                    : undefined
        anchors.rightMargin:
            root.horizontalAlignment === Text.AlignRight && !root.hasColon
                ? root.spacing
                : undefined
        horizontalAlignment: root.horizontalAlignment === Text.AlignHCenter ? Text.AlignHCenter : undefined
    }

    E.Text {
        id: colonObj
        preset: root.preset
        text: titleObj.text !== '' ? ':' : ''
        color: Theme.palette.asbestos
        anchors.left:
            root.horizontalAlignment === Text.AlignLeft || root.horizontalAlignment === Text.AlignHCenter
                ? titleObj.right
                : undefined
        anchors.right: root.horizontalAlignment === Text.AlignRight ? parent.right : undefined
        anchors.rightMargin: root.horizontalAlignment === Text.AlignRight ? root.spacing : undefined
        visible: root.hasColon
    }

}
