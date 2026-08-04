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
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool running: false
    property bool openusageAvailable: false
    property var closestResetData: null
    // When cacheMode is active, aggressive mode is always enabled because
    // requests are very cheap in this case and can be made frequently. When cache is inactive,
    // the regular checkTimer runs with updates every minute. Aggressive
    // mode is enabled only when a provider update is expected soon.
    property bool cacheMode: false
    property var providersState: null

    signal available()
    signal unavailable()

    Timer {
        id: avalabilityCheckTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: avalabilityCheckProc.running = true
    }

    Timer {
        id: checkTimer
        interval: 1000 * 60
        running: root.running
        repeat: true
        onTriggered: checkProc.running = true
    }

    Timer {
        id: checkAggressiveTimer
        interval: 1000 * 3
        running: false
        repeat: true
        onTriggered: checkProc.running = true
    }

    Timer {
        id: activateAggressiveTimer
        running: false
        repeat: false
        onTriggered: {
            checkProc.running = true
            checkAggressiveTimer.start()
        }
    }

    onClosestResetDataChanged: {
        if (!closestResetData) {
            activateAggressiveTimer.stop()
            if (!cacheMode) {
                checkAggressiveTimer.stop()
            }
            return
        }
        const now = Date.now()
        const delayMs = closestResetData.getTime() - now
        if (delayMs <= 0) {
            // console.log("START aggressive check now, delay secs is negative:", delayMs / 1000)
            activateAggressiveTimer.stop()
            if (!checkAggressiveTimer.running) {
                checkAggressiveTimer.start()
                checkProc.running = true
            }
        } else if (delayMs > checkTimer.interval) {
            // console.log("Delay secs is too hight:", delayMs / 1000)
            activateAggressiveTimer.stop()
            checkAggressiveTimer.stop()
        } else {
            // console.log("SCHEDULE aggressive check by delay secs:", delayMs / 1000)
            activateAggressiveTimer.interval = delayMs
            activateAggressiveTimer.restart()
            checkAggressiveTimer.stop()
        }
    }

    function processOpenusageData(outcome: var) {
        let closestResetDate = null

        const data = outcome.data
        const state = outcome.state

        const notice = state.queryMode === 'cache' ? null : "Query mode is not 'cache': " + state.queryMode

        if (state.queryMode === 'cache') {
            if (!root.cacheMode) {
                root.cacheMode = true
                checkTimer.stop()
                activateAggressiveTimer.stop()
                checkAggressiveTimer.start()
            }
        } else {
            if (root.cacheMode) {
                root.cacheMode = false
                checkTimer.start()
                checkAggressiveTimer.stop()
            }
        }

        const result = data.map(provider => {
            const providerAccount = provider.account
            const processedLines = (provider.lines || [])
                .filter(line => {
                    return line.format && line.format.kind === 'percent' && line.resetsAt !== null;
                })
                .map(line => {
                    const resetDate = new Date(line.resetsAt);

                    // We don't need closestResetDate in the cache mode as in this mode the aggressive
                    // check is always on.
                    if (!root.cacheMode) {
                        if (closestResetDate === null || resetDate < closestResetDate) {
                            closestResetDate = resetDate
                        }
                    }

                    return {
                        label: line.label,
                        periodDurationSeconds: line.periodDurationMs ? (line.periodDurationMs / 1000) : 0,
                        percent: line.limit > 0 ? (line.used / line.limit) : 0,
                        resetsAt: resetDate
                    }
                })
            const errorBadge = (provider.lines || []).find(line => {
                return line.type === 'badge' && line.label === 'Error'
            })

            return {
                id: provider.providerId,
                displayName: provider.displayName,
                plan: provider.plan,
                account: {
                    id: providerAccount.id,
                    name: providerAccount.name,
                    isActive: providerAccount.isActive,
                },
                lines: processedLines,
                error: errorBadge ? errorBadge.text : null,
            }
        }).filter(item => item.lines.length > 0 || item.error).sort((a, b) => {
            const idCompare = a.id.localeCompare(b.id)
            if (idCompare !== 0) {
                return idCompare
            }

            const accountNameA = (a.account && typeof a.account.name === 'string') ? a.account.name : ''
            const accountNameB = (b.account && typeof b.account.name === 'string') ? b.account.name : ''

            return accountNameA.localeCompare(accountNameB)
        })

        root.closestResetData = closestResetDate

        root.providersState = {
            data: result,
            notice: notice,
        }
    }

    Process {
        id: checkProc
        command: ['openusage-cli', 'query', '--with-state']
        running: false
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                console.warn('[Services/Openusage@checkProc]', '[stderr]', line)
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                let data
                try {
                     data = JSON.parse(text)
                }
                catch (e) {
                    console.warn(
                        '[Services/Openusage@checkProc]',
                        'unable to parse JSON from openusage-cli output:', e,
                        'output:', text
                    )
                    return
                }
                root.processOpenusageData(data)
            }
        }
        // qmllint disable signal-handler-parameters
        onExited: (exitCode, _) => {
        // qmllint enable signal-handler-parameters
            if (exitCode !== 0) {
                console.warn('[Services/Openusage@checkProc]', 'exited with code:', exitCode)
            }
        }
    }

    Process {
        id: avalabilityCheckProc
        command: ['openusage-cli', 'version']
        running: false
        property bool isInitialLoading: true
        // qmllint disable signal-handler-parameters
        onExited: (exitCode, _) => {
        // qmllint enable signal-handler-parameters
            if (exitCode !== 0) {
                console.info('[Service.Openusage/checkOpenusageProc]', 'openusage-cli: unavailable')
                root.openusageAvailable = false
                isInitialLoading = true
                root.running = false
                root.unavailable()
            } else {
                if (isInitialLoading) {
                    console.info('[Service.Openusage/checkOpenusageProc]', 'openusage-cli: available')
                    isInitialLoading = false
                }
                root.openusageAvailable = true
                root.running = true
                root.available()
                checkProc.running = true
            }
        }
    }

}
