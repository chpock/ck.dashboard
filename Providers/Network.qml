pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service

Singleton {
    id: root

    readonly property var rate: QtObject {
        property real download: 0
        property real upload: 0
    }

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
            root.rate.download = data.rxrate
            root.rate.upload = data.txrate
            root.updateNetworkRate(data)
        }
    }

}
