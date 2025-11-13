import Quickshell
import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider
import '../utils.js' as Utils

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var meter: QtObject {
            property int paddingTitle: 5
            readonly property var bar: QtObject {
                readonly property var padding: QtObject {
                    property int top: 2
                    property int bottom: 3
                }
            }
            readonly property var ram: QtObject {
                property var levels: ({
                    'good':     [0,  59 ],
                    'warning':  [60, 89 ],
                    'critical': [90, 100],
                })
            }
            readonly property var swap: QtObject {
                property var levels: ({
                    'good':     [0,  59 ],
                    'warning':  [60, 89 ],
                    'critical': [90, 100],
                })
            }
        }
        readonly property var processList: QtObject {
            readonly property var padding: QtObject {
                property int top: 5
                property int bottom: 0
            }
        }
    }

    Connections {
        target: Provider.Process
        function onUpdateProcessesByRAM(data) {
            processList.pushValues(data)
        }
    }

    readonly property int labelWidth: Math.max(ramUsageLabel.implicitWidth, swapUsageValue.implicitWidth)

    Item {
        id: ramUsage
        implicitHeight: Math.max(ramUsageLabel.implicitHeight, ramUsageValue.implicitHeight) +
            root.theme.meter.bar.padding.top + root.theme.meter.bar.padding.bottom +
            ramUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        E.TextTitle {
            id: ramUsageLabel
            text: 'RAM'
            anchors.left: parent.left
            width: root.labelWidth
        }

        E.TextBytes {
            id: ramUsageDetailsAvailable
            value: Provider.Memory.ram.available
            precision: 3
            anchors.left: ramUsageLabel.right
            anchors.leftMargin: root.theme.meter.paddingTitle
            anchors.bottom: ramUsageLabel.bottom
        }

        E.TextBytes {
            id: ramUsageDetailsTotal
            value: Provider.Memory.ram.total
            precision: 3
            prefix: ' / '
            anchors.left: ramUsageDetailsAvailable.right
            anchors.bottom: ramUsageLabel.bottom
            preset: 'details'
        }

        E.TextPercent {
            id: ramUsageValue
            valueCurrent: Provider.Memory.ram.total - Provider.Memory.ram.available
            valueMax: Provider.Memory.ram.total
            levels: root.theme.meter.ram.levels
            anchors.right: parent.right
        }

        E.Bar {
            id: ramUsageBar
            value: ramUsageValue.calcValue
            color: Theme.palette.belizehole
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.theme.meter.bar.padding.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Item {
        id: swapUsage
        implicitHeight: Math.max(swapUsageLabel.implicitHeight, swapUsageValue.implicitHeight) +
            root.theme.meter.bar.padding.top + root.theme.meter.bar.padding.bottom +
            swapUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        E.TextTitle {
            id: swapUsageLabel
            text: 'Swap'
            anchors.left: parent.left
            width: root.labelWidth
        }

        E.TextBytes {
            id: swapUsageDetailsFree
            value: Provider.Memory.swap.free
            precision: 3
            anchors.left: swapUsageLabel.right
            anchors.leftMargin: root.theme.meter.paddingTitle
            anchors.bottom: swapUsageLabel.bottom
        }

        E.TextBytes {
            id: swapUsageDetailsTotal
            value: Provider.Memory.swap.total
            precision: 3
            prefix: ' / '
            anchors.left: swapUsageDetailsFree.right
            anchors.bottom: swapUsageLabel.bottom
            preset: 'details'
        }

        E.TextPercent {
            id: swapUsageValue
            valueCurrent: Provider.Memory.swap.total - Provider.Memory.swap.free
            valueMax: Provider.Memory.swap.total
            levels: root.theme.meter.swap.levels
            anchors.right: parent.right
        }

        E.Bar {
            id: swapUsageBar
            value: swapUsageValue.calcValue
            color: Theme.palette.belizehole
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Item {
        implicitHeight: processList.implicitHeight + root.theme.processList.padding.top + root.theme.processList.padding.bottom
        implicitWidth: processList.implicitWidth
        anchors.left: parent.left
        anchors.right: parent.right

        E.ProcessList {
            id: processList
            y: root.theme.processList.padding.top

            E.TextBytes {
                property var modelValue
                value: modelValue
                precision: 3
                preset: Theme.processList.preset
                color: Theme.processList.colors.value
                horizontalAlignment: Text.AlignRight
            }
        }
    }

}
