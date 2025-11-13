pragma ComponentBehavior: Bound

import QtQuick
import qs

Item {
    id: root

    property bool capitalOnly: false
    property string preset: ""

    readonly property int wordSpacing: Math.round(spaceMetrics.boundingRect.width - textMetrics.boundingRect.width)

    property alias text: textObj.text
    property var color: undefined
    property int fontWeight: -1
    property int fontSize: -1
    property bool fontStrikeout: false
    property alias horizontalAlignment: textObj.horizontalAlignment
    property alias elide: textObj.elide

    implicitHeight: textMetrics.tightBoundingRect.height
    implicitWidth:  textObj.implicitWidth
    baselineOffset: textObj.baselineOffset

    // Rectangle {
    //     anchors.fill: parent
    //     color: 'blue'
    // }

    Text {
        id: textObj
        y: Math.round(textMetrics.tightBoundingRect.height - textMetrics.boundingRect.height) + (root.capitalOnly ? Math.ceil(fontMetrics.descent / 2) : 0)
        textFormat: Text.PlainText
        wrapMode: Text.NoWrap
        color: root.color !== undefined ? root.color : Theme.preset[root.preset !== '' ? root.preset : 'normal'].color
        font.pixelSize: root.fontSize !== -1 ? root.fontSize : Theme.preset[root.preset !== '' ? root.preset : 'normal'].fontSize
        font.weight: root.fontWeight !== -1 ? root.fontWeight : Theme.preset[root.preset !== '' ? root.preset : 'normal'].fontWeight
        font.strikeout: root.fontStrikeout
        anchors.left: parent.left
        anchors.right: parent.right
    }

    TextMetrics {
        id: textMetrics
        font: textObj.font
        text: root.capitalOnly ? 'H%0' : 'H%0bdfhklgjpqy'
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
