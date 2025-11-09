import QtQuick
import Quickshell
import QtGraphs
import qs
import '../utils.js' as Utils

Item {
    id: root

    required property color color
    property color colorArea: Qt.rgba(color.r, color.g, color.b, 0.3)

    property real maxValue: 100.0
    property real minValue: 0.0
    property bool maxValueAuto: false

    property int maxPoints: 50
    readonly property var calculateMax: Utils.calculateMax(() => maxPoints)

    implicitHeight: Theme.graph.height

    // In my Qt version, AreaSeries doesn't fill correctly areas when the first
    // value has non-zero value. To avoid this problem, we will leave the leftmost
    // point out of the graph and set its value to 0.
    function pushValue(value) {
        graph.counter += 1
        const minX = graph.counter - maxPoints - 2
        points.append(graph.counter, value)
        // Remove unused points from graph. We want only maxPoints (visible area)
        // points + 1 invisible point with 0 value.
        if (points.count > maxPoints + 1) {
            points.removeMultiple(0, points.count - maxPoints - 1)
            // Set the leftmost value to 0
            points.replace(0, minX, 0)
        }
        if (maxValueAuto) axisY.maxValueCalc = calculateMax.push(value)
        // Visible area should be minX+1 as we keep 1 invisible point with 0 value
        axisX.min = minX + 1
        axisX.max = graph.counter
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

            marginBottom: Theme.graph.border.width
            marginTop: Theme.graph.border.width
            marginLeft: Theme.graph.border.width
            marginRight: Theme.graph.border.width

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
                Behavior on max {
                    NumberAnimation {
                        duration: 200
                    }
                }
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
