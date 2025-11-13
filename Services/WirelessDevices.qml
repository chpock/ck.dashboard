pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal available()
    signal updateInfoIface(string name, var data)
    signal updateListIface(var data)

    property var ifacesList: []
    property bool running: false

    Timer {
        id: startupTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: startupProc.running = true
    }

    Process {
        id: startupProc
        command: ["iw", "dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                const ifacesListNew = []
                for (let line of lines) {
                    if (line.startsWith("\tInterface ")) {
                        let iface = line.substring(line.indexOf(' ') + 1)
                        ifacesListNew.push(iface)
                    }
                }
                if (!root.running) {
                    root.running = true
                    root.available()
                }
                root.updateListIface(ifacesListNew)
                root.ifacesList = ifacesListNew
            }
        }
    }

    Instantiator {
        model: root.ifacesList
        Scope {
            id: iface
            required property var modelData
            Timer {
                id: getIfaceInfoTimer
                interval: 1000
                running: true
                repeat: true
                onTriggered: getIfaceInfoProc.running = true
            }
            Process {
                id: getIfaceInfoProc
                command: ["iw", "dev", iface.modelData, "link"]
                running: true
                stderr: SplitParser {
                    splitMarker: "\n"
                    onRead: line => {
                        console.warn("[Services/WirelessDevices]", "[iw stderr]", line)
                    }
                }
                stdout: StdioCollector {
                    onStreamFinished: {
                        const lines = text.split('\n')
                        let rssi = 0
                        let ssid = ""
                        let isConnected = false
                        if (lines.length < 3) {
                            // Is not connected
                            ssid = lines[0]
                        } else {
                            for (let line of lines) {
                                if (line.startsWith("\tsignal:")) {
                                    let rssiString = line.substring(line.indexOf(':') + 2)
                                    rssiString = rssiString.slice(0, rssiString.indexOf(' '))
                                    rssi = parseInt(rssi)
                                } else if (line.startsWith("\tSSID:")) {
                                    ssid = line.substring(line.indexOf(':') + 2)
                                }
                            }
                            if (ssid !== "") {
                                isConnected = true
                            } else {
                                ssid = "unknown error"
                            }
                        }
                        const callbackData = {
                            "rssi": rssi,
                            "ssid": ssid,
                            "isConnected": isConnected,
                        }
                        root.updateInfoIface(iface.modelData, callbackData)
                    }
                }
                // qmllint disable signal-handler-parameters
                onExited: (exitCode, _) => {
                // qmllint enable signal-handler-parameters
                    if (exitCode !== 0) {
                        console.warn("command 'iw' finished with exit code:", exitCode)
                    }
                }
            }
        }
    }

}
