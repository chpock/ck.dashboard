pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    signal updateDiskRate(var info)
    signal updateMounts(var info)

    Component.onCompleted: {
        Service.Dgop.subscribe('infoDisk')
        Service.Dgop.subscribe('infoMounts')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('infoDisk')
        Service.Dgop.unsubscribe('infoMounts')
    }

    Connections {
        target: Service.Dgop
        function onUpdateInfoDisk(data) {
            root.updateDiskRate(data)
        }
        function onUpdateInfoMounts(data) {
            root.updateMounts(data)
        }
    }

}
