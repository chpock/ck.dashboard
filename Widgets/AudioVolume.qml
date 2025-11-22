pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var icon: QtObject {
            readonly property var color: QtObject {
                property color normal: Theme.palette.amethyst
                property color unavailable: Theme.color.error
                property color muted: Theme.color.error
                property color second: Theme.palette.orange
            }
        }
        readonly property var bar: QtObject {
            readonly property var padding: QtObject {
                property int top: 2
                property int bottom: 0
            }
        }
        readonly property var name: QtObject {
            readonly property var color: QtObject {
                property color normal: Theme.text.color.grey
                property color hover: Theme.text.color.normal
            }
        }
    }

    Repeater {
        model: [
            {
                name: "output",
                device: Provider.AudioDevices.sink,
                icon: {
                    normal: 'volume_up',
                    muted: 'volume_off',
                    headset: 'headphones',
                    hdmi: 'connected_tv',
                },
            },
            {
                name: "input",
                device: Provider.AudioDevices.source,
                icon: {
                    normal: 'mic',
                    muted: 'mic_off',
                    headset: 'headset_mic',
                    hdmi: 'connected_tv',
                }
            },
        ]

        Item {
            id: item

            required property var modelData
            readonly property var device: modelData.device
            readonly property var audio: device ? device.audio : null
            readonly property bool isAvailable: audio !== null
            readonly property real volume: isAvailable ? audio.volume : 0
            readonly property bool isMuted: isAvailable && (audio.muted || volume === 0)
            readonly property string description: isAvailable ? device.description : 'Unavailable'
            readonly property string icon: !isAvailable || isMuted ? modelData.icon.muted : modelData.icon.normal
            readonly property color iconColor:
                !isAvailable
                    ? root.theme.icon.color.unavailable
                    : isMuted
                        ? root.theme.icon.color.muted
                        : root.theme.icon.color.normal
            readonly property bool hasIconSecond: isAvailable && (isHeadset || isHdmi)
            readonly property bool isHeadset: isAvailable && (device.name.includes('bluez') || device.name.includes('hdmi'))
            readonly property bool isHdmi: isAvailable && device.name.includes('hdmi')
            readonly property string iconSecond:
                isHeadset
                    ? modelData.icon.headset
                    : isHdmi
                        ? modelData.icon.hdmi
                        : ''
            readonly property color iconSecondColor: root.theme.icon.color.second

            function setVolume(newVolume) {
                device.audio.volume = newVolume
                if (newVolume > 0.0001 && device.audio.muted) {
                    device.audio.muted = false
                } else if (newVolume <= 0.0001 && !device.audio.muted) {
                    device.audio.muted = true
                }
            }

            implicitWidth: icon.implicitWidth + name.implicitWidth
            implicitHeight: Math.max(icon.implicitHeight, name.implicitHeight, volumeObj.implicitHeight) +
                root.theme.bar.padding.top + slider.implicitHeight + root.theme.bar.padding.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            E.Icon {
                id: icon
                icon: parent.icon
                color: parent.iconColor
                anchors.left: parent.left
            }

            E.Icon {
                id: iconSecond
                icon: parent.iconSecond
                color: parent.iconSecondColor
                anchors.left: icon.right
                anchors.leftMargin: name.wordSpacing
                visible: parent.hasIconSecond
            }

            E.Text {
                id: name
                text: parent.description
                color:
                    !parent.isAvailable
                        ? Theme.color.error
                        : itemHover.hovered
                            ? root.theme.name.color.hover
                            : root.theme.name.color.normal
                anchors.rightMargin: wordSpacing
                anchors.right: volumeObj.left
                anchors.left: parent.hasIconSecond ? iconSecond.right : icon.right
                anchors.leftMargin: wordSpacing
                anchors.top: parent.top
                anchors.bottom: icon.bottom
                preset: 'details'
                overflow: E.Text.OverflowElide
            }

            E.TextPercent {
                id: volumeObj
                valueCurrent: parent.volume
                valueMax: 1.0
                colors: []
                anchors.right: parent.right
            }

            E.Slider {
                id: slider
                value: parent.volume
                maxValue: 1.0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.theme.bar.padding.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                onSlide: offset => {
                    item.setVolume(offset)
                }
            }

            HoverHandler {
                id: itemHover
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => slider.wheelHandler(event)
            }

            TapHandler {
                gesturePolicy: TapHandler.WithinBounds
                onTapped: {
                    parent.device.audio.muted = !parent.device.audio.muted
                    if (!parent.device.audio.muted && parent.volume === 0) {
                        parent.device.audio.volume = 0.01
                    }
                }
            }

        }
    }

}
