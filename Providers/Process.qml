pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    signal updateProcessesByCPU(var info)
    signal updateProcessesByRAM(var info)

    Component.onCompleted: {
        Service.Dgop.subscribe('processesByCPU')
        Service.Dgop.subscribe('processesByRAM')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('processesByCPU')
        Service.Dgop.unsubscribe('processesByRAM')
    }

    Connections {
        target: Service.Dgop
        function onUpdateProcessesByCPU(data) {
            root.updateProcessesByCPU(data)
        }
        function onUpdateProcessesByRAM(data) {
            root.updateProcessesByRAM(data)
        }
    }

}
