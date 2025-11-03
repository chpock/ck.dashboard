pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    signal updateRAM(var info)
    signal updateSwap(var info)

    Component.onCompleted: {
        Service.Dgop.subscribe('infoMemory')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('infoMemory')
    }

    Connections {
        target: Service.Dgop
        function onUpdateInfoMemory(data) {
            const infoRAM = {
                total:     data.total * 1024,
                free:      data.free * 1024,
                available: data.available * 1024,
                buffers:   data.buffers * 1024,
                cached:    data.cached * 1024,
                shared:    data.shared * 1024,
            }

            root.updateRAM(infoRAM)

            const infoSwap = {
                total: data.swaptotal * 1024,
                free:  data.swapfree * 1024,
            }

            root.updateSwap(infoSwap)
        }
    }

}
