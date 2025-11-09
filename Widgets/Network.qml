import Quickshell
import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var ifaceList: QtObject {
            readonly property var details: QtObject {
                property string preset: "normal"
                readonly property var color: QtObject {
                    property color normal: Theme.text.color.normal
                    property color error: Theme.text.color.error
                }
            }
            readonly property var signal: QtObject {
                property string preset: "normal"
                property var levels: ({
                    'good':     [75, 100],
                    'warning':  [20, 74 ],
                    'critical': [ 0, 19 ],
                })
            }
        }
        readonly property var rate: QtObject {
            readonly property var preset: QtObject {
                property var label: "normal"
                property var value: "details"
            }
            readonly property var download: QtObject {
                property color color: Theme.palette.belizehole
                property string label: "D:"
            }
            readonly property var upload: QtObject {
                property color color: Theme.palette.greensea
                property string label: "U:"
            }
            readonly property var graph: QtObject {
                property int maxValue: 1024 * 5
            }
            property int spacing: 2
        }
    }

    Connections {
        target: Provider.Network
        function onUpdateNetworkRate(data) {
            rates.children[0].children[2].pushValue(data.rxrate)
            rates.children[1].children[2].pushValue(data.txrate)
        }
    }

    Column {
        id: wireless

        anchors.left: parent.left
        anchors.right: parent.right

        property int ifaceWidth: 0

        Repeater {
            model: Provider.WirelessDevices.ifaceModel

            Item {
                required property var modelData

                implicitHeight: Math.max(ifaceObj.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right

                E.TextTitle {
                    id: ifaceObj
                    text: modelData.iface
                    anchors.left: parent.left
                    onImplicitWidthChanged: {
                        if (implicitWidth > wireless.ifaceWidth)
                            wireless.ifaceWidth = implicitWidth
                    }
                }

                E.Text {
                    id: ssidObj
                    text: modelData.ssid
                    preset: root.theme.ifaceList.details.preset
                    anchors.left: ifaceObj.right
                    anchors.right: parent.right
                    color: modelData.isConnected ? root.theme.ifaceList.details.color.normal : root.theme.ifaceList.details.color.error
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                E.TextPercent {
                    id: signal
                    value: modelData.signal
                    levels: root.theme.ifaceList.signal.levels
                    preset: root.theme.ifaceList.signal.preset
                    anchors.right: parent.right
                    visible: modelData.isConnected
                }
            }
        }
    }

    Row {
        id: rates

        width: parent.width
        spacing: Theme.base.spacing.vertical

        Repeater {
            model: ['download', 'upload']

            Item {
                required property var modelData

                implicitHeight: Math.max(label.implicitHeight, rate.implicitHeight) + root.theme.rate.spacing + graph.implicitHeight
                implicitWidth: (parent.width - parent.spacing) / 2

                E.Text {
                    id: label
                    text: root.theme.rate[modelData].label
                    color: root.theme.rate[modelData].color
                    anchors.left: parent.left
                    anchors.top: parent.top
                    preset: root.theme.rate.preset.label
                }

                E.TextBytes {
                    id: rate
                    anchors.right: parent.right
                    anchors.bottom: label.bottom
                    preset: root.theme.rate.preset.value
                    value: Provider.Network.rate[modelData]
                    isRate: true
                }

                E.GraphTimeseries {
                    id: graph
                    color: root.theme.rate[modelData].color
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
