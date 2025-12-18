'use strict'

function randomBytes(length) {
    const bytes = new Uint8Array(length)
    return crypto.getRandomValues(bytes)
}

function randomTable(length, table) {
    const bytes = randomBytes(length)
    const result = []
    for (const byte of bytes) {
        result.push(table[byte % table.length])
    }
    return result.join('')
}
