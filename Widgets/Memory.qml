import Quickshell
import QtQuick
import qs
import qs.Components as Component
import qs.Providers as Provider
import '../utils.js' as Utils

Base {
    id: root

    Connections {
        target: Provider.Memory
        function onUpdateRAM(data) {
            const ramUsagePercentage = 100 * (data.total - data.available) / data.total
            ramUsageBar.value = ramUsagePercentage
            ramUsageValue.text = Math.round(ramUsagePercentage) + '%'
            ramUsageDetails.text = Utils.formatBytes(data.available, 3) + ' / ' + Utils.formatBytes(data.total, 3)
        }
        // TODO: do something when total swap is 0 (no swap at all).
        // May be show "Not installed"? Or hide "Swap:" meter?
        function onUpdateSwap(data) {
            const swapUsagePercentage = 100 * (data.total - data.free) / data.total
            swapUsageBar.value = swapUsagePercentage
            swapUsageValue.text = Math.round(swapUsagePercentage) + '%'
            swapUsageDetails.text = Utils.formatBytes(data.free, 3) + ' / ' + Utils.formatBytes(data.total, 3)
        }
    }

    Connections {
        target: Provider.Process
        function onUpdateProcessesByRAM(data) {
            const processListData = data.map((item) => Object.assign({}, item, {
                value: Utils.formatBytes(item.value, 4)
            }))
            processList.pushValues(processListData)
        }
    }

    readonly property int labelWidth: Math.max(ramUsageLabel.implicitWidth, swapUsageValue.implicitWidth) + 15

    Item {
        id: ramUsage
        implicitHeight: Math.max(ramUsageLabel.implicitHeight, ramUsageValue.implicitHeight) + ramUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: ramUsageLabel
            text: 'RAM:'
            color: Theme.text.normal
            anchors.left: parent.left
            font.pixelSize: Theme.text.size
            width: root.labelWidth
        }

        Text {
            id: ramUsageDetails
            text: ''
            anchors.left: ramUsageLabel.right
            anchors.right: parent.right
            anchors.bottom: ramUsageLabel.bottom
            color: Theme.text.grey
            font.pixelSize: Theme.text.sizeS
        }

        Text {
            id: ramUsageValue
            text: '0%'
            color: Theme.text.normal
            anchors.right: parent.right
            font.pixelSize: Theme.text.size
        }

        Component.Bar {
            id: ramUsageBar
            color: Theme.palette.belizehole
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Item {
        id: swapUsage
        implicitHeight: Math.max(swapUsageLabel.implicitHeight, swapUsageValue.implicitHeight) + swapUsageBar.implicitHeight
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: swapUsageLabel
            text: 'Swap:'
            color: Theme.text.normal
            anchors.left: parent.left
            font.pixelSize: Theme.text.size
            width: root.labelWidth
        }

        Text {
            id: swapUsageDetails
            text: ''
            // horizontalAlignment: Text.AlignHCenter
            anchors.left: swapUsageLabel.right
            anchors.right: parent.right
            anchors.bottom: swapUsageLabel.bottom
            color: Theme.text.grey
            font.pixelSize: Theme.text.sizeS
        }

        Text {
            id: swapUsageValue
            text: '0%'
            color: Theme.text.normal
            anchors.right: parent.right
            font.pixelSize: Theme.text.size
        }

        Component.Bar {
            id: swapUsageBar
            color: Theme.palette.belizehole
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Component.ProcessList {
        id: processList
    }

}
