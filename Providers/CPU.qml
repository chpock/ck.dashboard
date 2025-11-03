pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

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
            if (cpuModel !== data.model) cpuModel = data.model
            if (cpuCores !== data.count) cpuCores = data.count

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
