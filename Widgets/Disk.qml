import Quickshell
import QtQuick
import qs
import qs.Components as Component
import qs.Providers as Provider
import '../utils.js' as Utils

Base {
    id: root

    Connections {
        target: Provider.Disk
        function onUpdateDiskRate(data) {
            const readRate = data.readrate
            const readRateText = Utils.formatBytes(readRate, 4) + '/s'
            const writeRate = data.writerate
            const writeRateText = Utils.formatBytes(writeRate, 4) + '/s'
            // rates[0].rate
            rates.children[0].children[1].text = readRateText
            // rates[0].graph
            rates.children[0].children[2].pushValue(readRate)
            // rates[1].rate
            rates.children[1].children[1].text = writeRateText
            // rates[1].graph
            rates.children[1].children[2].pushValue(writeRate)
        }
        function onUpdateMounts(data) {
            const dataCount = data.length
            for (let i = 0; i < dataCount; ++i) {
                const item = data[i]
                const model = {
                    mountPoint: item.mount,
                    fsType: item.fstype,
                    total: Utils.formatBytes(item.size, 4),
                    free: Utils.formatBytes(item.avail, 4),
                    freePercent: Math.round(100 - 100 * item.avail / item.size),
                }
                if (dataModelVolumes.count <= i) {
                    dataModelVolumes.append(model)
                } else {
                    dataModelVolumes.set(i, model)
                }
            }
        }
    }

    ListModel {
        id: dataModelVolumes
    }

    property var dataModelRate: [
        { labelText: 'R:', color: Theme.palette.greensea, },
        { labelText: 'W:', color: Theme.palette.orange,  },
    ]

    Repeater {
        model: dataModelVolumes

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            required property var modelData

            Item {
                implicitHeight: Math.max(textMountPoint.implicitHeight, textFreePercent.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right

                readonly property var mountPoint: parent.modelData.mountPoint
                readonly property var freePercent: parent.modelData.freePercent

                Text {
                    id: textMountPoint
                    text: parent.mountPoint
                    font.pixelSize: Theme.text.size
                    color: Theme.text.normal
                    anchors.left: parent.left
                    anchors.right: textFreePercent.left
                }

                Text {
                    id: textFreePercent
                    text: Math.round(parent.freePercent) + '%'
                    font.pixelSize: Theme.text.size
                    color: Theme.text.normal
                    anchors.right: parent.right
                }
            }

            Item {
                implicitHeight: Math.max(textFsType.implicitHeight, textFree.implicitHeight, textTotal.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right

                readonly property var fsType: parent.modelData.fsType
                readonly property var free: parent.modelData.free
                readonly property var total: parent.modelData.total

                Text {
                    id: textFsType
                    text: '(' + parent.fsType + ')'
                    anchors.left: parent.left
                    anchors.right: textFree.left
                    font.pixelSize: Theme.text.sizeS
                    color: Theme.text.grey
                }

                Text {
                    id: textFree
                    text: parent.free
                    anchors.right: textDiv.left
                    anchors.rightMargin: 3
                    font.pixelSize: Theme.text.sizeS
                    color: Theme.text.normal
                }

                Text {
                    id: textDiv
                    text: '/'
                    anchors.right: textTotal.left
                    anchors.rightMargin: 3
                    font.pixelSize: Theme.text.sizeS
                    color: Theme.text.normal
                }

                Text {
                    id: textTotal
                    text: parent.total
                    anchors.right: parent.right
                    font.pixelSize: Theme.text.sizeS
                    color: Theme.text.normal
                }
            }

            Component.Bar {
                id: cpuUsageBar
                color: Theme.palette.belizehole
                anchors.left: parent.left
                anchors.right: parent.right
                value: parent.modelData.freePercent
                paddingTop: 5
                // paddingBottom: 50
            }

        }

        
    }

    Row {
        id: rates

        width: parent.width
        spacing: Theme.padding.vertical * 3

        Repeater {
            model: dataModelRate

            Item {
                implicitHeight: Math.max(label.implicitHeight, rate.implicitHeight) + 3 + graph.implicitHeight
                implicitWidth: parent.width / 2 - Theme.padding.vertical

                Text {
                    id: label
                    text: modelData.labelText
                    anchors.left: parent.left
                    anchors.top: parent.top
                    color: Theme.text.normal
                    font.pixelSize: Theme.text.size
                }

                Text {
                    id: rate
                    text: ''
                    anchors.right: parent.right
                    anchors.bottom: label.bottom
                    color: Theme.text.grey
                    font.pixelSize: Theme.text.sizeS
                }

                Component.GraphTimeseries {
                    id: graph
                    color: modelData.color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    maxValueAuto: true
                    maxValue: 1024 * 10
                }

            }

        }
        
    }

}
