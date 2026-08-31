/*
    This file is a part of quickdashboard: https://github.com/chpock/quickdashboard

    Copyright (C) 2025-2026 Kostiantyn Kushnir <chpock@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.qd.Services as Service
import qs.qd as QD
import "state.js" as DiskState

Scope {
    id: root

    readonly property alias mountModel: mountModelObj
    property var mountModelList: []

    readonly property var rate: QtObject {
        property real read: 0
        property real write: 0
    }

    property bool hasService: true

    signal updateDiskRate(var info)

    Component.onCompleted: {
        if (root.hasService) {
            const stateEntries = mountModelObj.getStateEntries()

            if (!root.mountModelList.length) {
                for (const entry of stateEntries) {
                    mountModelObj.append(DiskState.placeholder(entry))
                    root.mountModelList.push(entry.mount)
                }
            }

            Service.Dgop.subscribe('infoDisk')
            Service.Dgop.subscribe('infoMounts')
            root.syncInfoDisk(Service.Dgop.infoDisk)
            root.syncInfoMounts(Service.Dgop.infoMounts)

            mountModelObj.stateInitialized = true
            if (mountModelObj.liveMountDataKnown) {
                mountModelObj.setState()
            }
        }
    }

    Component.onDestruction: {
        if (root.hasService) {
            Service.Dgop.unsubscribe('infoDisk')
            Service.Dgop.unsubscribe('infoMounts')
        }
    }

    function syncInfoDisk(data) {
        if (!data) {
            return
        }
        root.rate.read = data.readrate
        root.rate.write = data.writerate
        root.updateDiskRate(data)
    }

    function syncInfoMounts(data) {
        if (!data) {
            return
        }
        mountModelObj.liveMountDataKnown = true
        const foundMounts = []
        for (let item of data) {
            const mount = item.mount
            const idx = root.mountModelList.indexOf(mount)
            if (idx === -1) {
                mountModelObj.append(item)
                root.mountModelList.push(mount)
            } else {
                mountModelObj.set(idx, item)
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
        if (mountModelObj.stateInitialized) {
            mountModelObj.setState()
        }
    }

    Connections {
        target: Service.Dgop
        enabled: root.hasService
        function onInfoDiskChanged() {
            root.syncInfoDisk(Service.Dgop.infoDisk)
        }
        function onInfoMountsChanged() {
            root.syncInfoMounts(Service.Dgop.infoMounts)
        }
    }

    ListModel {
        id: mountModelObj

        property bool stateInitialized: false
        property bool liveMountDataKnown: false
        property string persistedStateEntries: ''
        readonly property string stateEntriesKey: 'Provider.Disk.ListModel.entries'

        function getStateEntries() {
            persistedStateEntries = QD.Settings.stateGet(stateEntriesKey, '')
            const entries = DiskState.parseEntries(persistedStateEntries)
            if (entries !== null) {
                return entries
            }

            // Legacy count-only state fallback. Remove this block once all caches contain entries state.
            const stateCountKey = 'Provider.Disk.ListModel.count'
            let stateCount = Number(QD.Settings.stateGet(stateCountKey, -1))
            if (!Number.isFinite(stateCount) || stateCount < 0) {
                return []
            }

            stateCount = Math.trunc(stateCount)
            const legacyEntries = []
            while (legacyEntries.length < stateCount) {
                legacyEntries.push({
                    device: '',
                    mount: '',
                    fstype: '',
                })
            }
            return legacyEntries
        }

        function setState() {
            const entries = []
            for (let i = 0; i < count; ++i) {
                entries.push(DiskState.identity(get(i)))
            }
            const entriesJson = JSON.stringify(entries)
            if (entriesJson !== persistedStateEntries) {
                QD.Settings.stateSet(stateEntriesKey, entriesJson)
                persistedStateEntries = entriesJson
            }
        }
    }

}
