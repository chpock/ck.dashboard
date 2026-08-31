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
import "../qd/Widgets/Disk/filter.js" as DiskFilter

TestCase {
    name: "DiskFilter"

    function test_matchesGlob_data() {
        return [
            { tag: "exact", pattern: "btrfs", value: "btrfs", expected: true },
            { tag: "anchored", pattern: "btrfs", value: "btrfs2", expected: false },
            { tag: "case-sensitive", pattern: "BTRFS", value: "btrfs", expected: false },
            { tag: "star", pattern: "/run/*", value: "/run/user/1000", expected: true },
            { tag: "star-empty", pattern: "/run/*", value: "/run/", expected: true },
            { tag: "question", pattern: "/mnt/?", value: "/mnt/a", expected: true },
            { tag: "question-unicode", pattern: "/mnt/?", value: "/mnt/😀", expected: true },
            { tag: "question-one-character", pattern: "/mnt/?", value: "/mnt/ab", expected: false },
            { tag: "regexp-characters-literal", pattern: "/mnt/data+[1]", value: "/mnt/data+[1]", expected: true },
        ]
    }

    function test_matchesGlob(data) {
        compare(DiskFilter.matchesGlob(data.value, data.pattern), data.expected)
    }

    function test_isExcluded_data() {
        const root = { fstype: "btrfs", mount: "/" }
        const boot = { fstype: "vfat", mount: "/boot" }

        return [
            { tag: "undefined-filter", entry: root, exclude: undefined, expected: false },
            { tag: "null-filter", entry: root, exclude: null, expected: false },
            { tag: "empty-filter", entry: root, exclude: {}, expected: false },
            { tag: "empty-lists", entry: root, exclude: { fstype: [], mount: [] }, expected: false },
            { tag: "fstype-match", entry: root, exclude: { fstype: ["btrfs"] }, expected: true },
            { tag: "fstype-miss", entry: boot, exclude: { fstype: ["btrfs"] }, expected: false },
            { tag: "mount-match", entry: boot, exclude: { mount: ["/boot"] }, expected: true },
            { tag: "mount-glob", entry: boot, exclude: { mount: ["/bo??"] }, expected: true },
            { tag: "criteria-or-fstype", entry: root, exclude: { fstype: ["btrfs"], mount: ["/boot"] }, expected: true },
            { tag: "criteria-or-mount", entry: boot, exclude: { fstype: ["btrfs"], mount: ["/boot"] }, expected: true },
            { tag: "all-miss", entry: boot, exclude: { fstype: ["ext4", "xfs"], mount: ["/home", "/var/*"] }, expected: false },
        ]
    }

    function test_isExcluded(data) {
        compare(DiskFilter.isExcluded(data.entry, data.exclude), data.expected)
    }
}
