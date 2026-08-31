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

function identity(entry) {
    return {
        device: entry.device,
        mount: entry.mount,
        fstype: entry.fstype,
    }
}

function parseEntries(value) {
    if (typeof value !== 'string' || !value.length) {
        return null
    }

    let entries
    try {
        entries = JSON.parse(value)
    } catch (e) {
        return null
    }

    if (!Array.isArray(entries)) {
        return null
    }

    const result = []
    for (const entry of entries) {
        if (!entry
                || typeof entry.device !== 'string'
                || typeof entry.mount !== 'string'
                || typeof entry.fstype !== 'string') {
            return null
        }
        result.push(identity(entry))
    }
    return result
}

function placeholder(entry) {
    return {
        device: entry.device,
        mount: entry.mount,
        fstype: entry.fstype,
        size: 0,
        used: 0,
        avail: 0,
    }
}
