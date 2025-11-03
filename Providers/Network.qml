pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    signal updateNetworkRate(var info)

    Component.onCompleted: {
        Service.Dgop.subscribe('infoNetwork')
    }

    Component.onDestruction: {
        Service.Dgop.unsubscribe('infoNetwork')
    }

    Connections {
        target: Service.Dgop
        function onUpdateInfoNetwork(data) {
            root.updateNetworkRate(data)
        }
    }

}
