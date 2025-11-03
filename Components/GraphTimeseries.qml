import QtQuick
import Quickshell
import QtGraphs
import qs

Item {
    id: root

    required property color color
    property color colorArea: Qt.rgba(color.r, color.g, color.b, 0.3)

    property real maxValue: 100.0
    property real minValue: 0.0
    property bool maxValueAuto: false

	property int maxPoints: 50

    implicitHeight: Theme.graph.height

    function pushValue(value) {
        graph.counter += 1
        axisX.min = graph.counter - maxPoints
        axisX.max = graph.counter
        if (points.count > maxPoints + 1) {
            points.removeMultiple(0, points.count - maxPoints - 1)
            // axisX.max = counter
            // axisX.min = counter - maxPoints
        }
        if (maxValueAuto) {
            let maxValueCalc = value
            for (let i = 0; i < points.count; ++i) {
                let curValue = points.at(i).y
                if (curValue > maxValueCalc)
                    maxValueCalc = curValue
            }
            axisY.maxValueCalc = maxValueCalc
        }
        points.append(graph.counter, value)
    }

    Component.onCompleted: {
        pushValue(0)
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

            property int counter: -1

            marginBottom: 0
            marginTop: 0
            marginLeft: 0
            marginRight: 0

            theme: GraphsTheme {
                backgroundVisible: false
                plotAreaBackgroundColor: "transparent"
                gridVisible: false
                borderWidth: 0
            }

            axisX: ValueAxis {
                id: axisX
                visible: false
                lineVisible: false
                gridVisible: true
                subGridVisible: false
                max: w.maxPoints
            }

            axisY: ValueAxis {
                id: axisY

                property real maxValueCalc: 0

                visible: false
                lineVisible: false
                gridVisible: true
                subGridVisible: false
                max: root.maxValueAuto && maxValueCalc > root.maxValue ? maxValueCalc : root.maxValue
                min: root.minValue
            }

            AreaSeries {
                id: area
                color: root.colorArea
                borderColor: root.color
                borderWidth: Theme.graph.line.width
                upperSeries: LineSeries {
                    id: points
                }
            }
        }
    }
}
