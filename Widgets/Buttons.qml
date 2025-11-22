pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs
import qs.Elements as E

Base {
    id: root

    readonly property var theme: QtObject {
        property int spacing: 2
        property color color: Theme.palette.silver
        property color colorHover: Theme.palette.belizehole
    }

    property var buttons: [
        {
            icon: 'frame_inspect',
            command: 'T="$(mktemp)"; hyprprop >"$T" && alacritty -e fx "$T" || true; rm -f "$T"',
        },
    ]


    Row {
        width: parent.width
        spacing: root.theme.spacing

        Repeater {
            model: root.buttons

            Item {
                id: button
                required property var modelData

                implicitWidth: icon.implicitWidth
                implicitHeight: icon.implicitHeight

                E.Icon {
                    id: icon
                    icon: button.modelData.icon
                    color:
                        iconHover.hovered
                            ? root.theme.colorHover
                            : root.theme.color

                    HoverHandler {
                        id: iconHover
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            Quickshell.execDetached(["sh", "-c", button.modelData.command])
                        }
                    }
                }
            }
        }

    }

}
