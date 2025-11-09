pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Flat UI Color Palette - https://www.webnots.com/flat-ui-color-codes/
    readonly property var palette: QtObject {
        property color turquoise:    '#1abc9c'
        property color greensea:     '#16a085'
        property color emerland:     '#2ecc71'
        property color nephritis:    '#27ae60'
        property color peterriver:   '#3498db'
        property color belizehole:   '#2980b9'
        property color amethyst:     '#9b59b6'
        property color wisteria:     '#8e44ad'
        property color wetasphalt:   '#34495e'
        property color midnightblue: '#2c3e50'
        property color sunflower:    '#f1c40f'
        property color orange:       '#f39c12'
        property color carrot:       '#e67e22'
        property color pumpkin:      '#d35400'
        property color alizarin:     '#e74c3c'
        property color pomegranate:  '#c0392b'
        property color clouds:       '#ecf0f1'
        property color silver:       '#bdc3c7'
        property color concrete:     '#95a5a6'
        property color asbestos:     '#7f8c8d'
    }

    readonly property var color: QtObject {
        property color ok: palette.nephritis
        property color warning: palette.sunflower
        property color error: palette.alizarin
    }

    readonly property var base: QtObject {
        property color background: '#ed1f2428'
        readonly property var border: QtObject {
            property int width: 1
            property color color: Qt.rgba(1.0, 1.0, 1.0, 0.2)
        }
        readonly property var padding: QtObject {
            property int horizontal: 8
            property int vertical: 8
        }
        readonly property var spacing: QtObject {
            property int horizontal: 5
            property int vertical: 15
        }
    }

    readonly property var text: QtObject {
        readonly property var color: QtObject {
            property color normal: palette.clouds
            property color grey: palette.concrete
            property color error: color.error
        }
        readonly property var fontSize: QtObject {
            property int normal: 14
            property int small: 12
        }
    }

    readonly property var preset: QtObject {
        readonly property var title: Preset {
            color: palette.amethyst
            fontWeight: Font.Medium
        }
        readonly property var normal: Preset {
        }
        readonly property var details: Preset {
            color: text.color.grey
            fontSize: text.fontSize.small
        }
    }

    component Preset: QtObject {
        property int fontSize: text.fontSize.normal
        property int fontWeight: Font.Normal
        property color color: text.color.normal
    }

    readonly property var thresholds: QtObject {
        readonly property var colors: QtObject {
            property color ignore: palette.asbestos
            property color good: color.ok
            property color warning: color.warning
            property color critical: color.error
        }
        property var levels: ({
            'ignore':   [ 0, 10],
            'good':     [11, 70],
            'warning':  [71, 95],
            'critical': [96, 100],
        })
    }

    readonly property var units: QtObject {
        // property var colors: ({
        //     'k': palette.greensea,
        //     'm': palette.pumpkin,
        //     'g': palette.amethyst,
        //     't': palette.pomegranate,
        //     'p': palette.pomegranate,
        //     'e': palette.pomegranate,
        //     'z': palette.pomegranate,
        //     'y': palette.pomegranate,
        // })
        property var colors: ({})
    }

    readonly property var bar: QtObject {
        property color active: palette.belizehole
        property color inactive: Qt.rgba(1.0, 1.0, 1.0, 0.15)
        property int height: 4
    }

    readonly property var graph: QtObject {
        property int height: 40
        readonly property var border: QtObject {
            property int width: 1
        }
        readonly property var line: QtObject {
            property int width: 1
        }
        readonly property var bar: QtObject {
            property var thresholds: ([
                { 'value': 10, 'color': palette.asbestos  },
                { 'value': 70, 'color': palette.nephritis },
                { 'value': 95, 'color': palette.carrot    },
                { 'value': -1, 'color': palette.alizarin  },
            ])
        }
    }

    readonly property var processList: QtObject {
        property string preset: 'details'
        readonly property var colors: QtObject {
            property color command: Theme.text.color.normal
            property color args: Theme.text.color.grey
            property color value: Theme.text.color.normal
        }
        property int spacing: 4
    }

}
