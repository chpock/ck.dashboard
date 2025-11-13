pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import '../utils.js' as Utils

Item {
    id: root

    required property var value
    property int precision: 4
    property bool isRate: false
    property string prefix: ''

    property string preset: ""
    property var color: undefined
    property var unitColors: Theme.units.colors

    property int horizontalAlignment: Text.AlignLeft

    readonly property var formatedValue: Utils.formatBytes(value, precision)

    implicitHeight: Math.max(valueObj.implicitHeight, unitObj.implicitHeight, suffix.implicitHeight)
    implicitWidth: valueObj.implicitWidth + valueObj.wordSpacing + unitObj.implicitWidth + suffix.implicitWidth

    E.Text {
        id: valueObj
        preset: root.preset
        text: root.prefix + root.formatedValue[0] + ' '
        color: root.color
        anchors.left: root.horizontalAlignment === Text.AlignLeft ? parent.left : undefined
        anchors.right: root.horizontalAlignment === Text.AlignRight ? unitObj.left : undefined
    }

    E.Text {
        id: unitObj
        preset: root.preset
        text: root.formatedValue[1]
        color: {
            const unitLowercase = root.formatedValue[1].toLowerCase()
            const color = root.unitColors[unitLowercase]
            return color ? color : root.color
        }
        anchors.left: root.horizontalAlignment === Text.AlignLeft ? valueObj.right : undefined
        anchors.right: root.horizontalAlignment === Text.AlignRight ? suffix.left : undefined
    }

    E.Text {
        id: suffix
        preset: root.preset
        text: root.isRate ? 'b/s' : 'b'
        color: root.color
        anchors.right: root.horizontalAlignment === Text.AlignRight ? parent.right : undefined
        anchors.left: root.horizontalAlignment === Text.AlignLeft ? unitObj.right : undefined
    }

}
