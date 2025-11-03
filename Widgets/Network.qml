import Quickshell
import QtQuick
import qs
import qs.Components as Component
import qs.Providers as Provider
import '../utils.js' as Utils

Base {
    id: root

    Connections {
        target: Provider.Network
        function onUpdateNetworkRate(data) {
            const downloadRate = data.rxrate
            const downloadRateText = Utils.formatBytes(downloadRate, 4) + '/s'
            const uploadRate = data.txrate
            const uploadRateText = Utils.formatBytes(uploadRate, 4) + '/s'
            rates.children[0].children[1].text = downloadRateText
            rates.children[0].children[2].pushValue(downloadRate)
            rates.children[1].children[1].text = uploadRateText
            rates.children[1].children[2].pushValue(uploadRate)
        }
    }

    property var dataModel: [
        { labelText: 'D:', color: Theme.palette.pumpkin, },
        { labelText: 'U:', color: Theme.palette.carrot,  },
    ]

    Row {
        id: rates

        width: parent.width
        spacing: Theme.padding.vertical * 3

        Repeater {
            model: dataModel

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
                    maxValue: 1024 * 5
                }

            }

        }
        
    }

}
