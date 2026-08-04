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

Scope {
    id: root

    readonly property alias providersModel: providersModelObj
    property bool hasService: true
    property bool running: false

    property var notice: null

    property var latestProviders: []
    property var latestProvidersLines: ({})

    function getMainLineIndex(lines) {
        if (!lines || lines.length === 0) {
            return -1
        }

        let mainLineIndex = 0

        for (let i = 1; i < lines.length; ++i) {
            const candidateLine = lines[i]
            const currentMainLine = lines[mainLineIndex]

            if (candidateLine.periodDurationSeconds < currentMainLine.periodDurationSeconds) {
                mainLineIndex = i
            } else if (candidateLine.periodDurationSeconds === currentMainLine.periodDurationSeconds && candidateLine.percent > currentMainLine.percent) {
                mainLineIndex = i
            }
        }

        return mainLineIndex
    }

    function syncProvidersState(stateData) {
        if (!stateData) {
            return
        }

        const providersData = stateData.data
        const currentLatestProviders = []
        let latestProvidersDirty = false
        const currentLatestProvidersLines = {}
        let latestProvidersLinesDirty = false
        let noticeDirty = false

        if (stateData.notice !== root.notice) {
            root.notice = stateData.notice
            noticeDirty = true
        }

        if (root.latestProviders.length !== providersData.length) {
            latestProvidersDirty = true
        }

        const accountsCountMap = providersData.reduce((acc, item) => {
            acc[item.id] = (acc[item.id] || 0) + 1
            return acc
        }, {})

        for (let i = 0; i < providersData.length; ++i) {

            const providerData = providersData[i]

            const providerAccountKey = providerData.id + '#' + providerData.account.id

            const modelData = {
                accountKey: providerAccountKey,
                id: providerData.id,
                displayName: providerData.displayName,
                plan: providerData.plan ?? '',
                error: providerData.error ?? '',
                accountName: providerData.account.name ?? providerData.account.id,
                accountIsActive: providerData.account.isActive ?? true,
                accountIsSingle: accountsCountMap[providerData.id] == 1,
            }

            const previousLines =
                root.latestProvidersLines.hasOwnProperty(providerAccountKey)
                    ? root.latestProvidersLines[providerAccountKey]
                    : []

            if (root.latestProviders.length <= i) {
                latestProvidersDirty = true
                latestProvidersLinesDirty = true
            } else {
                const latestProviderItem = root.latestProviders[i]
                if (
                    latestProviderItem.id !== modelData.id ||
                    latestProviderItem.displayName !== modelData.displayName ||
                    latestProviderItem.accountName !== modelData.accountName ||
                    latestProviderItem.accountIsActive !== modelData.accountIsActive ||
                    latestProviderItem.accountIsSingle !== modelData.accountIsSingle
                ) {
                    latestProvidersDirty = true
                    latestProvidersLinesDirty = true
                    modelData.lines = []
                }
            }

            currentLatestProviders.push(modelData)

            if (i < providersModelObj.count) {
                providersModelObj.set(i, modelData)
            } else {
                modelData.lines = []
                providersModelObj.append(modelData)
            }

            const lines = providerData.lines

            if (lines.length) {

                const mainLineIndex = root.getMainLineIndex(lines)

                const providerModel = providersModelObj.get(i)
                const linesModel = providerModel.lines
                const currentLines = []

                if (!latestProvidersLinesDirty) {
                    if (previousLines.length !== lines.length) {
                        latestProvidersLinesDirty = true
                    }
                }

                for (let j = 0; j < lines.length; ++j) {
                    const line = lines[j]
                    const linesModelData = {
                        label: line.label,
                        periodDurationSeconds: line.periodDurationSeconds,
                        percent: line.percent,
                        resetsAt: line.resetsAt,
                        main: j === mainLineIndex,
                    }

                    currentLines.push({
                        label: line.label,
                        periodDurationSeconds: line.periodDurationSeconds,
                    })
                    if (!latestProvidersLinesDirty) {
                        if (previousLines.length <= j) {
                            latestProvidersLinesDirty = true
                        } else {
                            const previousLineItem = previousLines[j]
                            if (previousLineItem.label !== line.label || previousLineItem.periodDurationSeconds !== line.periodDurationSeconds) {
                                latestProvidersLinesDirty = true
                            }
                        }
                    }

                    if (j < linesModel.count) {
                        linesModel.set(j, linesModelData)
                    } else {
                        linesModel.append(linesModelData)
                    }
                }

                if (lines.length < linesModel.count) {
                    linesModel.remove(lines.length, linesModel.count - lines.length)
                }

                currentLatestProvidersLines[providerAccountKey] = currentLines

            } else if (root.latestProvidersLines.hasOwnProperty(providerAccountKey)) {
                currentLatestProvidersLines[providerAccountKey] = root.latestProvidersLines[providerAccountKey]
            } else {
                currentLatestProvidersLines[providerAccountKey] = []
                latestProvidersLinesDirty = true
            }
        }
        if (providersData.length < providersModelObj.count) {
            providersModelObj.remove(providersData.length, providersModelObj.count - providersData.length)
        }

        if (latestProvidersDirty) {
            root.latestProviders = currentLatestProviders
            QD.Settings.stateSet('Provider.AIUsageLimits.latestProviders', JSON.stringify(root.latestProviders))
        }

        if (latestProvidersLinesDirty) {
            root.latestProvidersLines = currentLatestProvidersLines
            QD.Settings.stateSet('Provider.AIUsageLimits.latestProvidersLines', JSON.stringify(root.latestProvidersLines))
        }

        if (noticeDirty) {
            QD.Settings.stateSet('Provider.AIUsageLimits.notice', JSON.stringify(root.notice))
        }
    }

    Connections {
        target: Service.Openusage
        enabled: root.hasService
        function onProvidersStateChanged() {
            root.syncProvidersState(Service.Openusage.providersState)
        }
        function onAvailable() {
            root.running = true
        }
        function onUnavailable() {
            root.running = false
        }
    }

    ListModel {
        id: providersModelObj
    }

    Component.onCompleted: {
        if (root.hasService) {
            try {

                root.notice = JSON.parse(QD.Settings.stateGet('Provider.AIUsageLimits.notice', 'null'))

                const currentLatestProviders =
                    JSON.parse(QD.Settings.stateGet('Provider.AIUsageLimits.latestProviders', '[]'))
                const currentLatestProvidersLines =
                    JSON.parse(QD.Settings.stateGet('Provider.AIUsageLimits.latestProvidersLines', '{}'))
                const currentDate = new Date()

                for (let i = 0; i < currentLatestProviders.length; ++i) {

                    const providerData = currentLatestProviders[i]
                    const providerAccountKey = providerData.accountKey ?? ''
                    const lines = currentLatestProvidersLines[providerAccountKey] ?? []
                    const mainLineIndex = root.getMainLineIndex(lines)

                    const modelData = {
                        accountKey: providerAccountKey,
                        id: providerData.id,
                        displayName: providerData.displayName,
                        plan: '',
                        error: 'Not initialized',
                        accountName: providerData.accountName ?? '',
                        accountIsActive: providerData.accountIsActive ?? true,
                        accountIsSingle: providerData.accountIsSingle ?? true,
                        lines: [],
                    }
                    providersModelObj.append(modelData)

                    const providerModel = providersModelObj.get(i)
                    const linesModel = providerModel.lines

                    for (let j = 0; j < lines.length; ++j) {

                        const line = lines[j]

                        const linesModelData = {
                            label: line.label,
                            periodDurationSeconds: line.periodDurationSeconds,
                            percent: -1,
                            resetsAt: currentDate,
                            main: j === mainLineIndex,
                        }

                        linesModel.append(linesModelData)

                    }

                }

                root.latestProviders = currentLatestProviders
                root.latestProvidersLines = currentLatestProvidersLines
            }
            catch (e) {
                console.warn('[Provider/AIUsageLimits]', 'could not load provider state:', e)
                providersModelObj.clear()
            }

            if (Service.Openusage.running && Service.Openusage.providersState !== null) {
                root.syncProvidersState(Service.Openusage.providersState)
            }
        }
    }
}
