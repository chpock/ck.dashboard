pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    readonly property var ram: QtObject {
        property real total: 0
        property real available: 0
    }

    readonly property var swap: QtObject {
        property real total: 0
        property real free: 0
        property bool isInstalled: false
    }

    Component.onCompleted: {
        Service.Dgop.subscribe('infoMemory')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('infoMemory')
    }

    Connections {
        target: Service.Dgop
        function onUpdateInfoMemory(data) {
            root.ram.total = data.total * 1024
            root.ram.available = data.available * 1024

            root.swap.total = data.swaptotal * 1024
            root.swap.isInstalled = data.swaptotal !== 0
            if (root.swap.isInstalled) {
                root.swap.free = data.swapfree
            } else {
                root.swap.free = 0
                root.swap.freePercent = 0
            }
        }
    }

}
