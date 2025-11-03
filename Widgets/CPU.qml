import Quickshell
import QtQuick
import qs
import qs.Components as Component
import qs.Providers as Provider

Base {
    id: root

    Connections {
        target: Provider.CPU
        function onUpdateCPU(data) {
            cpuUsageGraph.pushValue(data.usage)
            cpuUsageBar.value = data.usage
            cpuUsageValue.text = Math.round(data.usage) + '%'
        }
        function onUpdateCPUCores(data) {
            cpuCoresUsageGraph.pushValues(data.coreUsage)
        }
    }

    Connections {
        target: Provider.Process
        function onUpdateProcessesByCPU(data) {
            const processListData = data.map((item) => Object.assign({}, item, {
                value: (Math.round(item.value * 99) / 100) + '%'
            }))
            processList.pushValues(processListData)
        }
    }

    Item {
        id: cpuUsage
        implicitHeight: Math.max(cpuUsageLabel.implicitHeight, cpuUsageValue.implicitHeight) + cpuUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: cpuUsageLabel
            text: 'CPU:'
            color: Theme.text.normal
            anchors.left: parent.left
            font.pixelSize: Theme.text.size
        }

        Text {
            id: cpuUsageValue
            text: '0%'
            color: Theme.text.normal
            anchors.right: parent.right
            font.pixelSize: Theme.text.size
        }

        Component.Bar {
            id: cpuUsageBar
            color: Theme.palette.belizehole
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    Row {
        height: Math.max(cpuUsageGraph.implicitHeight, cpuCoresUsageGraph.implicitHeight)
        width: parent.width
        spacing: Theme.padding.vertical * 2

        Component.GraphTimeseries {
            id: cpuUsageGraph
            color: Theme.palette.belizehole
            width: parent.width / 2 - Theme.padding.vertical
        }

        Component.GraphBars {
            id: cpuCoresUsageGraph
            color: Theme.palette.belizehole
            width: parent.width / 2 - Theme.padding.vertical
        }
    }

    Component.ProcessList {
        id: processList
    }

}
