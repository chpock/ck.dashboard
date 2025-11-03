pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Flat UI Color Palette - https://www.webnots.com/flat-ui-color-codes/
    readonly property var palette: {
        'turquoise':    '#1abc9c',
        'emerland':     '#2ecc71',
        'peterriver':   '#3498db',
        'amethyst':     '#9b59b6',
        'wetasphalt':   '#34495e',
        'greensea':     '#16a085',
        'nephritis':    '#27ae60',
        'belizehole':   '#2980b9',
        'wisteria':     '#8e44ad',
        'midnightblue': '#2c3e50',
        'sunflower':    '#f1c40f',
        'carrot':       '#e67e22',
        'alizarin':     '#e74c3c',
        'clouds':       '#ecf0f1',
        'concrete':     '#95a5a6',
        'orange':       '#f39c12',
        'pumpkin':      '#d35400',
        'pomegranate':  '#c0392b',
        'silver':       '#bdc3c7',
        'asbestos':     '#7f8c8d',
    }

    // readonly property color background: Qt.rgba(24, 24, 24, 0.07)
    readonly property color background: '#ed1f2428'

    readonly property var border: {
        'color': Qt.rgba(1.0, 1.0, 1.0, 0.2),
        'width': 1,
    }

    readonly property var padding: {
        'horizontal': 9,
        'vertical': 4,
    }

    readonly property var text: {
        'normal': palette.clouds,
        'grey': palette.concrete,
        'size': 14,
        'sizeS': 12,
    }

    readonly property var bar: {
        'active': palette.belizehole,
        'inactive': Qt.rgba(1.0, 1.0, 1.0, 0.15),
        'height': 3,
        'background': border.color,
        'padding': 1,
    }

    readonly property int spacing: 6

    readonly property var graph: {
        'height': 40,
        'border': {
            'width': 1,
        },
        'line': {
            'width': 1,
        },
        'bar': {
            'thresholds': [
                { 'value': 10, 'color': palette.asbestos  },
                { 'value': 70, 'color': palette.nephritis },
                { 'value': 95, 'color': palette.carrot    },
                { 'value': -1, 'color': palette.alizarin  },
            ]
        }
    }

}
