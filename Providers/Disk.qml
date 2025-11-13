pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick
import qs.Services as Service
import qs

Singleton {
    id: root

    readonly property alias mountModel: mountModelObj
    property var mountModelList: []

    readonly property var rate: QtObject {
        property real read: 0
        property real write: 0
    }

    signal updateDiskRate(var info)

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
            root.rate.read = data.readrate
            root.rate.write = data.writerate
            root.updateDiskRate(data)
        }
        function onUpdateInfoMounts(data) {
            const foundMounts = []
            for (let item of data) {
                const mount = data.mount
                const idx = root.mountModelList.indexOf(mount)
                if (idx === -1) {
                    mountModelObj.append(data)
                    root.mountModelList.push(mount)
                } else {
                    mountModelObj.set(idx, data)
                }
                foundMounts.push(mount)
            }
            if (foundMounts.length !== root.mountModelList.length) {
                for (let i = root.mountModelList.length - 1; i >= 0; --i) {
                    if (foundMounts.indexOf(root.mountModelList[i]) === -1)
                        mountModelObj.remove(i, 1)
                }
                root.mountModelList = foundMounts
            }
        }
    }

    ListModel {
        id: mountModelObj
        Component.onCompleted: {
            let stateCount = SettingsData.stateGet('Provider.Disk.ListModel.count', 0)
            const sampleData = {
                'device': '',
                'mount': '',
                'fstype': '',
                'size': 0,
                'used': 0,
                'avail': 0,
            }
            while (stateCount-- > 0) {
                append(sampleData)
                root.mountModelList.push('')
            }
        }
        onCountChanged: {
            SettingsData.stateSet('Provider.Disk.ListModel.count', count)
        }
    }

}
