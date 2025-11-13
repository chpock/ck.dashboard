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
        for (const name in levels) {
            if (root.value >= levels[name][0] && root.value <= levels[name][1]) {
                return colors[name]
            }
        }
        return undefined
    }
    // capitalOnly: true
}
