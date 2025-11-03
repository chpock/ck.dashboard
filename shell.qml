import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import QtGraphs
import qs.Widgets as Widget

ShellRoot {

    Variants {
        model: [Quickshell.screens[0]]

        PanelWindow {
            id: w

            property var modelData
            screen: modelData

            property int paddingTop: 43

            anchors {
                right: true
                // top: true
                // bottom: true
            }

            margins {
                top: paddingTop
                // bottom: 50
            }

            implicitWidth: 212
            implicitHeight: w.screen.height - paddingTop

            color: "transparent"

            // WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.layer: WlrLayer.Top
            // exclusionMode: ExclusionMode.Normal
            // exclusiveZone: 212

            ColumnLayout {

                id: content
                anchors.fill: parent
                spacing: 3

                Widget.Calendar {
                }

                Widget.Network {
                }

                Widget.Memory {
                }

                Widget.CPU {
                }

                Widget.Disk {
                }

                Item {
                    Layout.fillHeight: true
                }

                Widget.Clock {
                }

            }

        }
    }
}
