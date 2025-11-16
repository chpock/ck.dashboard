pragma ComponentBehavior: Bound

import QtQuick
import qs

Item {
    id: root

    enum HeightMode {
        Capitals = 0,
        Normal = 1,
        Content = 2
    }

    property string preset: ""

    readonly property int wordSpacing: Math.round(spaceMetrics.boundingRect.width - textMetrics.boundingRect.width)

    property alias text: textObj.text
    property var color: undefined
    property int fontWeight: -1
    property int fontSize: -1
    property bool fontStrikeout: false
    property var fontFamily: Theme.normalFont.name
    property var fontVariableAxes: ({})
    property alias horizontalAlignment: textObj.horizontalAlignment
    property var verticalAlignment: undefined
    property alias elide: textObj.elide
    property int heightMode: 1

    implicitHeight: textMetrics.tightBoundingRect.height
    implicitWidth:  textObj.implicitWidth

    // Rectangle {
    //     anchors.fill: parent
    //     color: 'blue'
    // }

    // Rectangle {
    //     width: textObj.width
    //     height: textObj.height
    //     x: textObj.x
    //     y: textObj.y
    //     color: {
    //         if (root.debug) {
    //             console.log("dbg:", height)
    //         }
    //         return '#54d70000'
    //     }
    // }

    Text {
        id: textObj
        height: textMetrics.tightBoundingRect.height
        textFormat: Text.PlainText
        wrapMode: Text.NoWrap
        color: root.color !== undefined ? root.color : Theme.preset[root.preset !== '' ? root.preset : 'normal'].color
        font.pixelSize: root.fontSize !== -1 ? root.fontSize : Theme.preset[root.preset !== '' ? root.preset : 'normal'].fontSize
        font.weight: root.fontWeight !== -1 ? root.fontWeight : Theme.preset[root.preset !== '' ? root.preset : 'normal'].fontWeight
        font.strikeout: root.fontStrikeout
        font.family: root.fontFamily
        font.variableAxes: root.fontVariableAxes
        verticalAlignment: root.verticalAlignment === undefined ? Text.AlignVCenter : root.verticalAlignment
        anchors.left: parent.left
        anchors.right: parent.right
    }

    TextMetrics {
        id: textMetrics
        font: textObj.font
        text:
            root.heightMode === 2
                ? textObj.text
                : root.heightMode === 0
                    ? 'H%0'
                    : 'H%0bdfhklgjpqy'
    }

    TextMetrics {
        id: spaceMetrics
        font: textObj.font
        text: {
            const s = textMetrics.text
            return s[0] + ' ' + s.slice(1)
        }
    }

    FontMetrics {
        id: fontMetrics
        font: textObj.font
    }

}
