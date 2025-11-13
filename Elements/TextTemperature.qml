pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E
import '../utils.js' as Utils

E.Text {
    id: root

    property real value
    property var colors: Theme.thresholds.colors
    property var levels: Theme.thresholds.levels

    text: Utils.roundPercent(value) + "\u2103"
    color: {
        const calcValue = Math.floor(value)
        for (const name in levels) {
            if (calcValue >= levels[name][0] && calcValue <= levels[name][1]) {
                return colors[name]
            }
        }
        return undefined
    }
}
