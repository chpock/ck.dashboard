import QtQuick
import Quickshell
import qs

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: lv.implicitHeight

    function pushValues(values) {
        for (let i = 0; i < rows.count; ++i) {
            const row = rows.get(i)
            if (i < values.length) {
                const rowValues = values[i]
                row.command = rowValues.command
                row.args = rowValues.args
                row.value = rowValues.value
            } else {
                row.command = ""
                row.args = ""
                row.value = ""
            }
        }
        lv.recomputeRightWidth()
    }

    ListModel {
        id: rows
        ListElement { command: ''; args: ''; value: ''; }
        ListElement { command: ''; args: ''; value: ''; }
        ListElement { command: ''; args: ''; value: ''; }
    }

    ListView {
        id: lv
        anchors.fill: parent
        clip: true
        model: rows
        spacing: 0
        implicitHeight: contentHeight

        property int colValueWidth: 0

        function recomputeRightWidth() {
            var maxw = 0
            for (let i = 0; i < lv.count; ++i) {
                const d = lv.itemAtIndex(i)
                if (d) maxw = Math.max(maxw, d.children[0].children[2].implicitWidth)
            }
            colValueWidth = maxw
        }

        delegate: Item {
            width: lv.width
            height: Math.max(colCommand.implicitHeight, colValue.implicitHeight)

            Row {
                id: row
                anchors.fill: parent
                spacing: 8

                Text {
                    id: colCommand
                    text: model.command
                    color: Theme.text.normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignLeft
                    clip: true
                }

                Text {
                    id: colArgs
                    text: model.args
                    color: Theme.text.grey
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    width: parent.width - colCommand.implicitWidth - lv.colValueWidth - row.spacing * 2
                    horizontalAlignment: Text.AlignLeft
                    clip: true
                }

                Text {
                    id: colValue
                    text: model.value
                    color: Theme.text.normal
                    elide: Text.ElideNone
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignRight
                    width: lv.colValueWidth
                }
            }
        }
    }
}
