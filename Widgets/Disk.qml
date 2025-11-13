pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var mount: QtObject {
            property int spacing: 0
            readonly property var bar: QtObject {
                readonly property var padding: QtObject {
                    property int top: 2
                    property int bottom: 3
                }
            }
            property var levels: ({
                'good':     [ 0, 79 ],
                'warning':  [80, 94 ],
                'critical': [95, 100],
            })
        }
        readonly property var rate: QtObject {
            readonly property var preset: QtObject {
                property var label: "normal"
                property var value: "details"
            }
            readonly property var read: QtObject {
                property color color: Theme.palette.belizehole
                property string label: "R:"
            }
            readonly property var write: QtObject {
                property color color: Theme.palette.greensea
                property string label: "W:"
            }
            readonly property var graph: QtObject {
                property int maxValue: 1024 * 10
            }
            property int spacing: 2
        }
    }

    Connections {
        target: Provider.Disk
        function onUpdateDiskRate(data) {
            rates.children[0].children[2].pushValue(data.readrate)
            rates.children[1].children[2].pushValue(data.writerate)
        }
    }

    Repeater {
        model: Provider.Disk.mountModel

        Column {
            id: mount
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: root.theme.mount.spacing

            required property var modelData

            Item {
                implicitHeight: Math.max(textMountPoint.implicitHeight, textFreePercent.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right

                E.TextTitle {
                    id: textMountPoint
                    text: mount.modelData.mount
                    hasSpace: false
                    hasColon: false
                    anchors.left: parent.left
                    anchors.right: textFreePercent.left
                }

                E.TextPercent {
                    id: textFreePercent
                    valueCurrent: mount.modelData.used
                    valueMax: mount.modelData.size
                    levels: root.theme.mount.levels
                    anchors.right: parent.right
                }
            }

            Item {
                implicitHeight: Math.max(textFsType.implicitHeight, textFree.implicitHeight, textTotal.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right

                E.Text {
                    id: textFsType
                    text: mount.modelData.fstype !== '' ? '(' + mount.modelData.fstype + ')' : ''
                    anchors.left: parent.left
                    anchors.bottom: textFree.bottom
                    preset: 'details'
                }

                E.TextBytes {
                    id: textFree
                    value: mount.modelData.avail
                    precision: 3
                    anchors.right: textTotal.left
                }

                E.TextBytes {
                    id: textTotal
                    value: mount.modelData.size
                    precision: 3
                    prefix: ' / '
                    anchors.right: parent.right
                    anchors.bottom: textFree.bottom
                    preset: 'details'
                }

            }

            Item {
                implicitHeight: fsUsageBar.implicitHeight + root.theme.mount.bar.padding.top + root.theme.mount.bar.padding.bottom
                implicitWidth: fsUsageBar.implicitWidth
                anchors.left: parent.left
                anchors.right: parent.right

                E.Bar {
                    id: fsUsageBar
                    color: Theme.palette.belizehole
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: root.theme.mount.bar.padding.top
                    anchors.right: parent.right
                    value: textFreePercent.calcValue
                }
            }

        }

    }

    Row {
        id: rates

        width: parent.width
        spacing: Theme.base.spacing.vertical

        Repeater {
            model: ['read', 'write']

            Item {
                id: rateItem

                required property var modelData

                implicitHeight: Math.max(label.implicitHeight, rate.implicitHeight) + root.theme.rate.spacing + graph.implicitHeight
                implicitWidth: (parent.width - rates.spacing) / 2

                E.Text {
                    id: label
                    text: root.theme.rate[rateItem.modelData].label
                    color: root.theme.rate[rateItem.modelData].color
                    anchors.left: parent.left
                    anchors.top: parent.top
                    preset: root.theme.rate.preset.label
                }

                E.TextBytes {
                    id: rate
                    anchors.right: parent.right
                    anchors.bottom: label.bottom
                    preset: root.theme.rate.preset.value
                    value: Provider.Disk.rate[rateItem.modelData]
                    isRate: true
                }

                E.GraphTimeseries {
                    id: graph
                    color: root.theme.rate[rateItem.modelData].color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    maxValueAuto: true
                    maxValue: root.theme.rate.graph.maxValue
                }

            }

        }

    }

}
