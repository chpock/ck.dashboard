pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Widgets as Widget

ShellRoot {

    Variants {
        model: [Quickshell.screens[0]]

        PanelWindow {
            id: w

            property var modelData
            screen: modelData

            implicitWidth: 212
            anchors {
                right: true
                top: true
                bottom: true
            }

            color: 'transparent'

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
