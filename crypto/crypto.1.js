function randomBytes(length) {
    const result = new Uint8Array(length)
    return crypto.getRandomValues(result)
}

function randomText(length) {
    const bytes = randomBytes(length)
    const template = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    const result = []
    for (const byte of bytes) {
        result.push(template[byte % 62])
    }
    return result.join('')
}
