pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.Elements as E

E.Text {
    id: root

    required property string icon
    property bool filled: false
    property int grade: 200
    property int weight: filled ? 500 : 400
    property int opticalSize: 24

    readonly property real fill: filled ? 1.0 : 0.0

    text: icon
    fontFamily: Theme.symbolsFont.name
    fontFamilySpacing: Theme.normalFont.name
    fontWeight: root.weight
    // heightMode: E.Text.Content
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    fontVariableAxes: {
        "FILL": root.fill.toFixed(1),
        "GRAD": root.grade,
        "opsz": root.opticalSize,
        "wght": root.weight
    }
}
