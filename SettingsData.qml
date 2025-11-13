pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick
import QtCore

Singleton {
    id: root

    Settings {
        id: stateStore
        location: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/ck.dashboard/state.ini"
    }

    function stateSet(key, value) {
        return stateStore.setValue(key, value)
    }

    function stateGet(key, defaultValue) {
        return stateStore.value(key, defaultValue)
    }
}
