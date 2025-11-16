pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var meter: QtObject {
            readonly property var temperature: QtObject {
                property int offset: 50
                property var levels: ({
                    'ignore':   [ 0,  59 ],
                    'good':     [ 60, 74 ],
                    'warning':  [ 75, 89 ],
                    'critical': [ 90, 200],
                })
            }
            readonly property var bar: QtObject {
                readonly property var padding: QtObject {
                    property int top: 3
                    property int bottom: 2
                }
            }
            property var levels: ({
                'ignore':   [ 0,  5 ],
                'good':     [ 6, 69 ],
                'warning':  [70, 89 ],
                'critical': [90, 100],
            })
        }
        readonly property var processList: QtObject {
            readonly property var padding: QtObject {
                property int top: 5
                property int bottom: 0
            }
            property var levels: ({
                'ignore':   [ 0,  5 ],
                'good':     [ 6, 69 ],
                'warning':  [70, 89 ],
                'critical': [90, 100],
            })
        }
    }

    Connections {
        target: Provider.CPU
        function onUpdateCPU(data) {
            cpuUsageGraph.pushValue(data.usage)
        }
        function onUpdateCPUCores(data) {
            cpuCoresUsageGraph.pushValues(data.coreUsage)
        }
    }

    Connections {
        target: Provider.Process
        function onUpdateProcessesByCPU(data) {
            processList.pushValues(data)
        }
    }

    Item {
        id: cpuUsage
        implicitHeight: Math.max(cpuUsageLabel.implicitHeight, cpuUsageValue.implicitHeight) +
            root.theme.meter.bar.padding.top + root.theme.meter.bar.padding.bottom +
            cpuUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        E.TextTitle {
            id: cpuUsageLabel
            text: 'CPU'
            anchors.left: parent.left
        }

        E.TextTemperature {
            id: ramUsageTemperature
            value: Provider.CPU.cpu.temperature
            levels: root.theme.meter.temperature.levels
            anchors.right: parent.right
            anchors.rightMargin: root.theme.meter.temperature.offset
            anchors.bottom: cpuUsageLabel.bottom
            preset: 'details'
        }

        E.TextPercent {
            id: cpuUsageValue
            value: Provider.CPU.cpu.usage
            levels: root.theme.meter.levels
            anchors.right: parent.right
        }

        E.Bar {
            id: cpuUsageBar
            color: Theme.palette.belizehole
            value: Provider.CPU.cpu.usage
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.theme.meter.bar.padding.bottom
        }
    }

    Row {
        height: Math.max(cpuUsageGraph.implicitHeight, cpuCoresUsageGraph.implicitHeight)
        width: parent.width
        spacing: Theme.base.spacing.vertical

        E.GraphTimeseries {
            id: cpuUsageGraph
            color: Theme.palette.belizehole
            width: (parent.width - parent.spacing) / 2
        }

        E.GraphBars {
            id: cpuCoresUsageGraph
            color: Theme.palette.belizehole
            width: (parent.width - parent.spacing) / 2
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

            E.TextPercent {
                property var modelValue
                // qmllint disable unqualified
                value: modelValue
                // qmllint enable unqualified
                levels: root.theme.processList.levels
                preset: Theme.processList.preset
                horizontalAlignment: Text.AlignRight
            }
        }
    }

}
