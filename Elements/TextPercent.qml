import QtQuick
import qs
import qs.Elements as E
import '../utils.js' as Utils

E.Text {
    id: root

    property real value
    property real valueCurrent: NaN
    property real valueMax: NaN
    property var colors: Theme.thresholds.colors
    property var levels: Theme.thresholds.levels

    readonly property real calcValue:
        isNaN(valueMax)
            ? value
            : valueMax === 0
                ? 0
                : 100 * valueCurrent / valueMax

    text: Utils.roundPercent(calcValue) + '%'
    color: {
        const calcValue = root.calcValue
        for (const name in levels) {
            if (calcValue >= levels[name][0] && calcValue <= levels[name][1]) {
                return colors[name]
            }
        }
        return undefined
    }
}
