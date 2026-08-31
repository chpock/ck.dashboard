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

function toCodePoints(value) {
    const result = []
    for (let index = 0; index < value.length;) {
        const codePoint = value.codePointAt(index)
        result.push(codePoint)
        index += codePoint > 0xffff ? 2 : 1
    }
    return result
}

function matchesGlob(value, pattern) {
    if (typeof value !== 'string' || typeof pattern !== 'string') {
        return false
    }

    const valueChars = toCodePoints(value)
    const patternChars = toCodePoints(pattern)
    const questionMark = '?'.charCodeAt(0)
    const star = '*'.charCodeAt(0)
    let valueIndex = 0
    let patternIndex = 0
    let starIndex = -1
    let starValueIndex = -1

    while (valueIndex < valueChars.length) {
        if (patternIndex < patternChars.length
                && (patternChars[patternIndex] === questionMark || patternChars[patternIndex] === valueChars[valueIndex])) {
            ++valueIndex
            ++patternIndex
        } else if (patternIndex < patternChars.length && patternChars[patternIndex] === star) {
            starIndex = patternIndex++
            starValueIndex = valueIndex
        } else if (starIndex !== -1) {
            patternIndex = starIndex + 1
            valueIndex = ++starValueIndex
        } else {
            return false
        }
    }

    while (patternIndex < patternChars.length && patternChars[patternIndex] === star) {
        ++patternIndex
    }

    return patternIndex === patternChars.length
}

function matchesAny(value, patterns) {
    if (!Array.isArray(patterns)) {
        return false
    }

    return patterns.some(pattern => matchesGlob(value, pattern))
}

function isExcluded(entry, exclude) {
    if (!entry || !exclude || typeof exclude !== 'object') {
        return false
    }

    return matchesAny(entry.fstype, exclude.fstype)
        || matchesAny(entry.mount, exclude.mount)
}
