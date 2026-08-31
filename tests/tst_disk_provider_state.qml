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

import QtQuick
import QtTest
import "../qd/Providers/Disk/state.js" as DiskState

TestCase {
    name: "DiskProviderState"

    function test_parseEntries() {
        const entries = DiskState.parseEntries('[{"device":"/dev/nvme0n1p2","mount":"/","fstype":"btrfs"}]')

        verify(entries !== null)
        compare(entries.length, 1)
        compare(entries[0].device, "/dev/nvme0n1p2")
        compare(entries[0].mount, "/")
        compare(entries[0].fstype, "btrfs")
    }

    function test_parseEntries_emptyList() {
        const entries = DiskState.parseEntries('[]')

        verify(entries !== null)
        compare(entries.length, 0)
    }

    function test_parseEntries_rejectsInvalidState_data() {
        return [
            { tag: "missing-state", state: "" },
            { tag: "invalid-json", state: "not-json" },
            { tag: "not-array", state: "{}" },
            { tag: "missing-device", state: '[{"mount":"/","fstype":"btrfs"}]' },
            { tag: "missing-mount", state: '[{"device":"/dev/root","fstype":"btrfs"}]' },
            { tag: "missing-fstype", state: '[{"device":"/dev/root","mount":"/"}]' },
            { tag: "non-string-field", state: '[{"device":"/dev/root","mount":"/","fstype":1}]' },
        ]
    }

    function test_parseEntries_rejectsInvalidState(data) {
        compare(DiskState.parseEntries(data.state), null)
    }

    function test_identity() {
        const identity = DiskState.identity({
            device: "/dev/nvme0n1p2",
            mount: "/",
            fstype: "btrfs",
            size: 100,
            used: 60,
            avail: 40,
        })

        compare(Object.keys(identity).length, 3)
        compare(identity.device, "/dev/nvme0n1p2")
        compare(identity.mount, "/")
        compare(identity.fstype, "btrfs")
    }

    function test_placeholder() {
        const placeholder = DiskState.placeholder({
            device: "/dev/nvme0n1p2",
            mount: "/",
            fstype: "btrfs",
        })

        compare(placeholder.device, "/dev/nvme0n1p2")
        compare(placeholder.mount, "/")
        compare(placeholder.fstype, "btrfs")
        compare(placeholder.size, 0)
        compare(placeholder.used, 0)
        compare(placeholder.avail, 0)
    }
}
