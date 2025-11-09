import QtQuick
import Quickshell
import qs
import qs.Elements as E

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: lv.implicitHeight

    default property Component valueRenderer

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
                row.value = 0
            }
        }
        lv.recomputeRightWidth()
    }

    ListModel {
        id: rows
        Component.onCompleted: {
            let stateCount = SettingsData.stateGet('Element.ProcessList.ListModel.count', 3)
            const sampleData = {
                'command': '',
                'args': '',
                'value': 0,
            }
            while (stateCount-- > 0) {
                append(sampleData)
            }
        }
        onCountChanged: {
            SettingsData.stateSet('Element.ProcessList.ListModel.count', count)
        }
    }

    ListView {
        id: lv
        anchors.fill: parent
        model: rows
        spacing: Theme.processList.spacing
        implicitHeight: contentHeight

        property int colValueWidth: 0

        function recomputeRightWidth() {
            var maxw = 0
            for (let i = 0; i < lv.count; ++i) {
                const d = lv.itemAtIndex(i)
                if (d) {
                    const currentWidth =
                        root.valueRenderer === null
                            ? d.children[0].children[2].implicitWidth
                            : d.children[0].children[3].implicitWidth
                    maxw = Math.max(maxw, currentWidth)
                }
            }
            colValueWidth = maxw
        }

        delegate: Item {
            width: lv.width
            height: Math.max(colCommand.implicitHeight, colValue.implicitHeight)

            Row {
                id: row
                anchors.fill: parent
                spacing: colCommand.wordSpacing * 2

                E.Text {
                    id: colCommand
                    text: model.command
                    preset: Theme.processList.preset
                    color: Theme.processList.colors.command
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                E.Text {
                    id: colArgs
                    text: model.args
                    preset: Theme.processList.preset
                    color: Theme.processList.colors.args
                    elide: Text.ElideRight
                    width: parent.width - colCommand.implicitWidth - lv.colValueWidth - parent.spacing * 2
                    horizontalAlignment: Text.AlignLeft
                }

                E.Text {
                    id: colValue
                    text: model.value
                    preset: Theme.processList.preset
                    color: Theme.processList.colors.value
                    horizontalAlignment: Text.AlignRight
                    width: lv.colValueWidth
                    visible: root.valueRenderer === null
                }

                Loader {
                    id: colValueLoader
                    width: lv.colValueWidth
                    visible: root.valueRenderer !== null
                    active: root.valueRenderer !== null
                    sourceComponent: valueRenderer
                    property var modelValue: model.value
                }
            }
        }
    }
}
