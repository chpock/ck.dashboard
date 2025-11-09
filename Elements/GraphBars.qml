import QtQuick
import Quickshell
import QtGraphs
import qs

Item {
    id: root

    required property color color

    property real maxValue: 100.0

    implicitHeight: Theme.graph.height

    function pushValues(values) {
        if (barSeries.barSets.length > values.length) {
            barSeries.removeMultiple(0, barSeries.barSets.length - values.length);
        } else if (barSeries.barSets.length < values.length) {
            for (let i = barSeries.barSets.length; i < values.length; ++i) {
                const set = Qt.createQmlObject('import QtGraphs; BarSet {}', barSeries)
                barSeries.append(set);
            }
        }
        for (let i = 0; i < values.length; ++i) {
            const v = Math.round(values[i]);
            const set = barSeries.at(i)
            if (set.values[0] !== v) {
                set.values = [v]
                for (let j = 0; j < Theme.graph.bar.thresholds.length; ++j) {
                    const threshold = Theme.graph.bar.thresholds[j];
                    if (threshold.value === -1 || v <= threshold.value) {
                        set.color = threshold.color
                        break
                    }
                }
            }
        }
    }

    Rectangle {
        id: border
        anchors.fill: parent

        border {
            color: root.color
            width: Theme.graph.border.width
        }
        color: "transparent"

        GraphsView {
            id: graph
            anchors.fill: parent
            anchors.margins: Theme.graph.border.width + 2

            marginBottom: 0
            marginTop: 0
            marginLeft: 0
            marginRight: 0

            theme: GraphsTheme {
                backgroundVisible: false
                plotAreaBackgroundColor: "transparent"
                gridVisible: false
                labelsVisible: false
                borderWidth: 0
            }

            axisY: ValueAxis {
                id: axisY
                min: 0
                max: root.maxValue
                visible: false
                labelsVisible: false
                lineVisible: false
                gridVisible: false
                subGridVisible: false
                titleVisible: false
            }
            axisX: BarCategoryAxis {
                id: axisX
                visible: false
                labelsVisible: false
                lineVisible: false
                gridVisible: false
                subGridVisible: false
                titleVisible: false
            }

            BarSeries {
                id: barSeries
                barWidth: 1
                barDelegate: Rectangle {
                    property color barColor
                    color: barColor
                    // no rounding
                    radius: 0
                }
            }

        }
    }
}
