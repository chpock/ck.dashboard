pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import qs.Providers as Provider

Base {
    id: root

    readonly property var theme: QtObject {
        readonly property var albumArtBox: QtObject {
            property int size: 45
            property var padding: QtObject {
                property int right: 10
            }
            property var border: QtObject {
                property int width: 1
                property color color: Theme.text.color.grey
            }
            property var unknown: QtObject {
                property int size: 35
                property color color: Theme.palette.asbestos
            }
        }
        readonly property var status: QtObject {
            readonly property var unavailable: QtObject {
                property string text: 'No players'
                property color color: Theme.text.color.grey
            }
            readonly property var playing: QtObject {
                property string text: 'Playing'
                property color color: Theme.palette.nephritis
            }
            readonly property var paused: QtObject {
                property string text: 'Paused'
                property color color: Theme.palette.carrot
            }
            readonly property var stopped: QtObject {
                property string text: 'Stopped'
                property color color: Theme.palette.alizarin
            }
            readonly property var unknown: QtObject {
                property string text: 'Unknown status'
                property color color: Theme.palette.alizarin
            }
        }
        readonly property var controls: QtObject {
            property int verticalOffset: 1
            property color color: Theme.palette.silver
            property color colorHover: Theme.palette.belizehole
        }
        readonly property var slider: QtObject {
            property var padding: QtObject {
                property int top: 3
                property int bottom: 3
            }
        }
        readonly property var trackTitle: QtObject {
            property var padding: QtObject {
                property int bottom: 3
            }
        }
        readonly property var trackArtist: QtObject {
            property var padding: QtObject {
                property int bottom: 0
            }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: Math.max(albumArtBox.implicitHeight, playerStatus.implicitHeight)

        Rectangle {
            id: albumArtBox

            property bool isUnknown: !Provider.Mpris.hasTrackArt || isImageEmpty
            property bool isImageEmpty: true

            anchors.left: parent.left
            implicitWidth: root.theme.albumArtBox.size
            implicitHeight: root.theme.albumArtBox.size
            color: 'transparent'
            border.width: root.theme.albumArtBox.border.width
            border.color: root.theme.albumArtBox.border.color

            E.Icon {
                icon: 'question_mark'
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                fontSize: root.theme.albumArtBox.unknown.size
                color: root.theme.albumArtBox.unknown.color
                anchors.fill: parent
                visible: parent.isUnknown
            }

            Image {
                id: albumArtBoxImage
                anchors.fill: parent
                asynchronous: true
                // Don't cashe to not waste RAM
                cache: false
                fillMode: Image.PreserveAspectCrop
                retainWhileLoading: true
                source: Provider.Mpris.trackArtUrl
                visible: !parent.isUnknown
                onStatusChanged: {
                    if (albumArtBoxImage.status === Image.Ready) {
                        albumArtBox.isImageEmpty = false
                    } else if (albumArtBoxImage.status === Image.Null || albumArtBoxImage.status === Image.Error) {
                        albumArtBox.isImageEmpty = true
                    }
                }
            }

            TapHandler {
                enabled: Provider.Mpris.hasRaise
                gesturePolicy: TapHandler.WithinBounds
                onTapped: {
                    Provider.Mpris.raise()
                }
            }
            HoverHandler {
                enabled: Provider.Mpris.hasRaise
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            id: playerStatus

            anchors.top: albumArtBox.top
            anchors.left: albumArtBox.right
            anchors.leftMargin: root.theme.albumArtBox.padding.right
            anchors.right: parent.right
            implicitHeight: statusBox.implicitHeight +
                root.theme.slider.padding.top + slider.implicitHeight + root.theme.slider.padding.bottom +
                trackTitleObj.implicitHeight + root.theme.trackTitle.padding.bottom +
                trackArtistObj.implicitHeight + root.theme.trackArtist.padding.bottom
            color: 'transparent'

            Item {
                id: statusBox

                implicitHeight: Math.max(status.implicitHeight, playingTime.implicitHeight)
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                readonly property bool visibleTime:
                    !statusBoxHovered.hovered && Provider.Mpris.hasLength && Provider.Mpris.hasPosition
                readonly property bool visibleControl:
                    !visibleTime && (Provider.Mpris.hasPrev || Provider.Mpris.hasToggle || Provider.Mpris.hasNext)

                E.Text {
                    id: status
                    text: root.theme.status[Provider.Mpris.status].text
                    color: root.theme.status[Provider.Mpris.status].color
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.right:
                        parent.visibleTime
                            ? playingTime.left
                            : parent.visibleControl
                                ? playingControl.left
                                : parent.right
                    anchors.rightMargin: (parent.visibleTime || parent.visibleControl) ? wordSpacing : 0
                    overflow: E.Text.OverflowElide

                    TapHandler {
                        enabled: Provider.Mpris.hasPlayer
                        gesturePolicy: TapHandler.WithinBounds
                        onTapped: {
                            Provider.Mpris.toggle()
                        }
                    }
                    HoverHandler {
                        enabled: Provider.Mpris.hasPlayer
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                E.Text {
                    id: playingTime
                    text: {
                        const time = Math.max(0, Provider.Mpris.length - Provider.Mpris.position)
                        const hours = Math.floor(time / 3600)
                        const mins = Math.floor((time % 3600) / 60)
                        const secs = time % 60
                        const hoursStr = hours !== 0 ? (((hours < 10 ? '0' : '') + hours) + ':') : ''
                        const minsStr = (mins < 10 ? '0' : '') + mins + ':'
                        const secsStr = (secs < 10 ? '0' : '') + secs
                        return hoursStr + minsStr + secsStr
                    }
                    anchors.right: parent.right
                    anchors.top: parent.top
                    visible: parent.visibleTime
                }

                Item {
                    id: playingControl
                    anchors.right: parent.right
                    y: root.theme.controls.verticalOffset
                    visible: parent.visibleControl
                    implicitHeight: Math.max(iconPrev.implicitHeight, iconToggle.implicitHeight, iconNext.implicitHeight)
                    implicitWidth: iconPrev.implicitWidthFull + iconToggle.implicitWidthFull + iconNext.implicitWidthFull

                    E.Icon {
                        id: iconPrev

                        readonly property bool hasSpacing: Provider.Mpris.hasToggle || Provider.Mpris.hasNext
                        readonly property real implicitWidthFull: visible ? (implicitWidth + (hasSpacing ? wordSpacing : 0)) : 0

                        anchors.right:
                            Provider.Mpris.hasToggle
                                ? iconToggle.left
                                : Provider.Mpris.hasNext
                                    ? iconNext.left
                                    : parent.right
                        anchors.rightMargin: hasSpacing ? wordSpacing : undefined
                        filled: true
                        weight: 700
                        icon: 'skip_previous'
                        visible: Provider.Mpris.hasPrev
                        color:
                            iconPrevHover.hovered
                                ? root.theme.controls.colorHover
                                : root.theme.controls.color

                        HoverHandler {
                            id: iconPrevHover
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: Provider.Mpris.prev()
                        }
                    }

                    E.Icon {
                        id: iconToggle

                        readonly property bool hasSpacing: Provider.Mpris.hasNext
                        readonly property real implicitWidthFull: visible ? (implicitWidth + (hasSpacing ? wordSpacing : 0)) : 0

                        anchors.right: Provider.Mpris.hasNext ? iconNext.left : parent.right
                        anchors.rightMargin: Provider.Mpris.hasNext ? wordSpacing : undefined
                        filled: true
                        weight: 700
                        icon:
                            Provider.Mpris.isPaused
                            ? 'resume'
                            : Provider.Mpris.isStopped
                                ? 'play_arrow'
                                : Provider.Mpris.hasPause
                                    ? 'pause'
                                    : 'stop'
                        visible: Provider.Mpris.hasToggle
                        color:
                            iconToggleHover.hovered
                                ? root.theme.controls.colorHover
                                : root.theme.controls.color

                        HoverHandler {
                            id: iconToggleHover
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: Provider.Mpris.toggle()
                        }
                    }

                    E.Icon {
                        id: iconNext

                        readonly property bool hasSpacing: false
                        readonly property real implicitWidthFull: visible ? (implicitWidth + (hasSpacing ? wordSpacing : 0)) : 0

                        anchors.right: parent.right
                        filled: true
                        weight: 700
                        icon: 'skip_next'
                        visible: Provider.Mpris.hasNext
                        color:
                            iconNextHover.hovered
                                ? root.theme.controls.colorHover
                                : root.theme.controls.color

                        HoverHandler {
                            id: iconNextHover
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: Provider.Mpris.next()
                        }
                    }
                }

                HoverHandler {
                    id: statusBoxHovered
                }
            }

            E.Slider {
                id: slider
                value: Provider.Mpris.position
                maxValue: Provider.Mpris.length
                anchors.top: statusBox.bottom
                anchors.topMargin: root.theme.slider.padding.top
                anchors.left: parent.left
                anchors.right: parent.right
                canSeek: Provider.Mpris.hasSeek
                onSlide: offset => {
                    Provider.Mpris.activePlayer.position = offset
                }
            }

            E.Text {
                id: trackTitleObj
                text: Provider.Mpris.track
                anchors.top: slider.bottom
                anchors.topMargin: root.theme.slider.padding.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                visible: Provider.Mpris.hasPlayer
                overflow: E.Text.OverflowAnimate
            }

            E.Text {
                id: trackArtistObj
                text: Provider.Mpris.artist
                preset: 'details'
                anchors.top: trackTitleObj.bottom
                anchors.topMargin: root.theme.trackTitle.padding.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                visible: Provider.Mpris.hasPlayer
            }

        }

    }

}
