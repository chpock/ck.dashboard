function formatBytesSplit(value, precision) {
    let suffix = ['', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    let div = 1024.0
    let divcount
    let result
    for (divcount = 0; (value >= div && divcount < 9) || value >= 10**precision; ++divcount) {
        value = value / div
    }
    result = value.toPrecision(precision - (value < 1 ? 1 : 0))
    if (result.indexOf('.') !== -1) {
        // TODO: Optimize this to count amount of digits to cut and cut the string once
        while (result.length) {
            let lastChar = result[result.length - 1]
            if (lastChar === '0') {
                result = result.slice(0, -1)
                continue
            }
            if (lastChar === '.') {
                result = result.slice(0, -1)
            }
            break
        }
    }
    return [result, suffix[divcount]]
}

function formatBytes(value, precision) {
    const data = formatBytesSplit(value, precision)
    return data[0] + ' ' + data[1] + 'b'
}

function roundPercent(value) {
    // Return integers as is
    if (Number.isInteger(value))
        return value
    const intPart = Math.round(value)
    // If fraction part is less then 0.01 or integer part has more than 1 digit,
    // then return only integer part
    if (Math.abs(value % 1) < 0.01 || Math.abs(intPart) >= 10)
        return intPart
    // For 0.x values, return 0.XX
    if (intPart === 0)
        return Math.round(value * 100) / 100
    // Here we have only values from 0.0 to 9.99, return 0.X for them
    return Math.round(value * 10) / 10
}

function movingAverage(getWindowSize) {
    let size = Math.max(1, getWindowSize ? getWindowSize() : 5)
    let buf = new Array(size)
    let idx = 0
    let filled = 0
    let sum = 0
    return {
        push(v) {
            if (filled < size) {
                buf[idx] = v
                sum += v
                idx = (idx + 1) % size
                filled++
            } else {
                const old = buf[idx]
                buf[idx] = v
                sum += (v - old)
                idx = (idx + 1) % size
            }
            return Math.trunc(sum / filled)
        },
    }
}

function calculateMax(getWindowSize) {
    let size = Math.max(1, getWindowSize ? getWindowSize() : 5)
    let buf = []
    let max_queue = []
    return {
        push(v) {
            buf.push(v)
            while (max_queue.length && max_queue[max_queue.length - 1] < v) max_queue.pop()
            max_queue.push(v)
            while (buf.length > size) {
                let old = buf.shift()
                if (max_queue.length && max_queue[0] === old) max_queue.shift()
            }
            return max_queue[0]
        },
    }
}

function rssiToPercent(rssi) {
    // perfect/worst values are from:
    // https://github.com/torvalds/linux/blob/9ff9b0d392ea08090cd1780fb196f36dbb586529/drivers/net/wireless/intel/ipw2x00/ipw2100.c#L6038
    const perfect = -20
    const worst = -85
    // This algorithm is from:
    // https://github.com/torvalds/linux/blob/9ff9b0d392ea08090cd1780fb196f36dbb586529/drivers/net/wireless/intel/ipw2x00/ipw2200.c#L4322
    const k1 = perfect - worst
    const k2 = k1 * k1
    const r = perfect - rssi
    const percent = Math.round((100 * k2 - r * (15 * k1 + 62 * r)) / k2)
    if (percent < 0) return 0
    if (percent > 100) return 100
    return percent
}
