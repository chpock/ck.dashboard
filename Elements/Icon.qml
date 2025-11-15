pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E

E.Text {
    id: root

    property string icon: ""
    property bool filled: false
    property int grade: -25
    property int weight: filled ? 500 : 400

    readonly property real fill: filled ? 1.0 : 0.0

    text: icon
    fontFamily: Theme.symbolsFont.name
    fontWeight: root.weight
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    fontVariableAxes: {
        "FILL": root.fill.toFixed(1),
        "GRAD": root.grade,
        "opsz": 24,
        "wght": root.weight
    }
}
