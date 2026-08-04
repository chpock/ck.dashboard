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

import QtQuick
import qs.qd.Elements as E
import qs.qd.Providers as Provider
import qs.qd.Widgets as Widget

Widget.Base {
    id: root

    readonly property var providerAIUsageLimits: Provider.AIUsageLimits.instance

    _fragments: Fragments {
        _defaults: Defaults {
            widget: root
        }
        _custom: root.fragments
        _chain: (root._chain ? root._chain + '.' : '') + root.type + '.fragments'
    }

    component Notice: Item {
        id: line

        readonly property var config: root._fragments.notice

        implicitHeight: Math.max(title.implicitHeight, message.implicitHeight)

        E.TextTitle {
            id: title
            theme: root._theme
            config: line.config.title

            anchors.left: parent.left
        }

        E.Text {
            id: message
            theme: root._theme
            config: line.config.message

            text: root.providerAIUsageLimits.notice
            anchors.left: title.right
            anchors.right: parent.right
        }
    }

    component Line: Item {
        id: line

        required property var modelData
        readonly property var config: root._fragments.line
        readonly property bool initialized: modelData.percent >= 0
        property bool isCompact: false

        visible: !isCompact || modelData.main

        implicitHeight:
            Math.max(
                label.implicitHeight,
            )
            + bar.implicitHeight
            + (isCompact
                ? 0
                : Math.max(
                    resetsLabel.implicitHeight,
                    resetsTime.implicitHeight,
                ))

        E.Text {
            id: label
            theme: root._theme
            config: line.config.label

            text: parent.modelData.label
            anchors.left: parent.left
        }

        E.TextDuration {
            id: duration
            theme: root._theme
            config: line.config.duration

            seconds: parent.modelData.periodDurationSeconds
            anchors.left: label.right
            anchors.right: percent.left
            anchors.bottom: label.bottom
        }

        E.TextPercent {
            id: percent
            theme: root._theme
            config: line.config.percent

            visible: line.initialized
            valueCurrent: parent.modelData.percent
            valueMax: 1
            anchors.right: parent.right
            anchors.bottom: label.bottom
        }

        E.TextDuration {
            id: resets_compact
            theme: root._theme
            config: line.config.resets_compact

            visible: line.initialized && line.isCompact
            targetDate: parent.modelData.resetsAt
            allowNegative: false
            anchors.right: parent.right
            anchors.bottom: label.bottom
        }

        E.Bar {
            id: bar
            theme: root._theme
            config: line.config.bar

            value: line.initialized ? parent.modelData.percent : 0
            valueMax: 1.0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: label.bottom
        }

        E.Text {
            id: resetsLabel
            theme: root._theme
            config: line.config.resets.label

            visible: !line.isCompact
            anchors.top: bar.bottom
            anchors.left: parent.left
            anchors.bottom: resetsTime.bottom
        }

        E.TextDuration {
            id: resetsTime
            theme: root._theme
            config: line.config.resets.time

            visible: line.initialized && !line.isCompact
            targetDate: parent.modelData.resetsAt
            allowNegative: false
            anchors.top: bar.bottom
            anchors.right: parent.right
        }
    }

    component AIProvider: Item {
        id: provider

        required property var modelData
        readonly property var config: root._fragments.provider
        property bool isCompact: false

        implicitHeight: Math.max(
            title.implicitHeight,
            plan.implicitHeight,
        ) + column.implicitHeight

        E.Text {
            id: active_indicator
            theme: root._theme
            config: provider.config.active_indicator

            anchors.left: parent.left
            anchors.bottom: title.bottom

            style: modelData.accountIsActive ? 'active' : 'inactive'
            visible: !modelData.accountIsSingle
        }

        E.TextTitle {
            id: title
            theme: root._theme
            config: provider.config.title

            text: parent.modelData.displayName
            anchors.left: active_indicator.visible ? active_indicator.right : parent.left
        }

        E.Text {
            id: plan
            theme: root._theme
            config: provider.config.plan

            text:
                parent.modelData.error
                    ? parent.modelData.error
                    : parent.modelData.plan
                        ? parent.modelData.plan
                        : ''
            style: parent.modelData.error ? 'error' : null
            anchors.left: title.right
        }

        E.Text {
            id: account
            theme: root._theme
            config: provider.config.account

            anchors.right: parent.right
            anchors.bottom: plan.bottom

            args: [parent.modelData.accountName]
        }

        Column {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom

            spacing: provider.config.spacing.vertical

            Repeater {
                model: provider.modelData.lines

                Line {
                    isCompact: provider.isCompact
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                }
            }
        }
    }

    Notice {
        visible: root.providerAIUsageLimits.notice
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Repeater {
        model: root.providerAIUsageLimits.providersModel

        AIProvider {
            isCompact: root._isVariantCompact
            anchors.left: parent?.left
            anchors.right: parent?.right
        }
    }

    Component {
        id: detailsComponent

        Widget.Details {
            // qmllint disable incompatible-type
            base: root
            // qmllint enable incompatible-type
            implicitWidth: root.width

            Notice {
                visible: root.providerAIUsageLimits.notice
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Repeater {
                model: root.providerAIUsageLimits.providersModel

                AIProvider {
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                }
            }
        }
    }

    _details: _isVariantNormal ? null : detailsComponent

}
