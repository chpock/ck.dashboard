pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service
import qs
import '../utils.js' as Utils

Singleton {
    id: root

    readonly property alias ifaceModel: ifaceModelObj
    property var ifaceModelList: []

    Connections {
        target: Service.WirelessDevices
        function onUpdateInfoIface(name, data) {
            const idx = root.ifaceModelList.indexOf(name)
            // If we don't have this interface in ifaceModelObj
            if (idx === -1) return
            ifaceModelObj.set(idx, {
                ssid: data.ssid,
                isConnected: data.isConnected,
                signal: Utils.rssiToPercent(data.rssi),
            })
        }
        function onUpdateListIface(data) {
            root.ifaceModelList = []
            for (let i = 0; i < data.length; ++i) {
                const iface = data[i]
                const modelData = {
                    "iface": iface,
                    "ssid": "Waiting for data...",
                    "signal": 0,
                    "isConnected": false,
                }
                root.ifaceModelList.push(iface)
                if (i < ifaceModelObj.count) {
                    ifaceModelObj.set(i, modelData)
                } else {
                    ifaceModelObj.append(modelData)
                }
            }
            if (data.length < ifaceModelObj.count) {
                ifaceModelObj.remove(data.length, ifaceModelObj.count - data.length)
            }
        }
    }

    ListModel {
        id: ifaceModelObj
        Component.onCompleted: {
            let stateCount = SettingsData.stateGet('Provider.WirelessDevices.ListModel.count', 0)
            const sampleData = {
                'iface': '',
                'ssid': '',
                'signal': 0,
                'isConnected': false,
            }
            while (stateCount-- > 0) {
                append(sampleData)
            }
        }
        onCountChanged: {
            SettingsData.stateSet('Provider.WirelessDevices.ListModel.count', count)
        }
    }

}
