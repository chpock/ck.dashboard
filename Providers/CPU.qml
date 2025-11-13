pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    readonly property var cpu: QtObject {
        property string model: "Unknown"
        property int cores: 0
        property real frequency: 0
        property real usage: 0
        property real temperature: 0
    }

    signal updateCPU(var info)
    signal updateCPUCores(var info)

    property string cpuModel: "Unknown"
    property int cpuCores: 0

    Component.onCompleted: {
        Service.Dgop.subscribe('infoCPU')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('infoCPU')
    }

    Connections {
        target: Service.Dgop
        function onUpdateInfoCPU(data) {
            root.cpu.model = data.model
            root.cpu.cores = data.count
            root.cpu.frequency = data.frequency
            root.cpu.usage = data.usage
            root.cpu.temperature = data.temperature

            const infoCPU = {
                frequency: data.frequency,
                temperature: data.temperature,
                usage: data.usage,
            }

            root.updateCPU(infoCPU)

            const infoCPUCores = {
                coreUsage: data.coreUsage
            }

            root.updateCPUCores(infoCPUCores)
        }
    }

}
