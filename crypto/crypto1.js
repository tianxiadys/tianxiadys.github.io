function bytesFromBase64(base64) {
    const temp = atob(base64)
    return bytesFromChars(temp)
}

function bytesFromChars(text) {
    const length = text.length
    const result = new Uint8Array(length)
    for (let i = 0; i < length; i++) {
        result[i] = text.charCodeAt(i)
    }
    return result
}

function bytesFromUtf8(utf8) {
    const encoder = new TextEncoder()
    return encoder.encode(utf8)
}

function bytesToBase64(bytes) {
    const temp = bytesToChars(bytes)
    return btoa(temp)
}

function bytesToChars(bytes) {
    return String.fromCharCode(...bytes)
}

function bytesToUtf8(bytes) {
    const decoder = new TextDecoder()
    return decoder.decode(bytes)
}

function printBytes(bytes, parent) {
    parent.innerHTML = ''
    for (const byte of bytes) {
        const div1 = document.createElement('div')
        const div2 = document.createElement('div')
        const div3 = document.createElement('div')
        const number = Number(byte)
        div2.innerText = number.toString(16)
        div3.innerText = String.fromCharCode(number)
        div1.appendChild(div2)
        div1.appendChild(div3)
        parent.appendChild(div1)
    }
}

function randomBytes(length) {
    const bytes = new Uint8Array(length)
    return crypto.getRandomValues(bytes)
}

function randomString(length, chars) {
    const bytes = randomBytes(length)
    const result = []
    for (const byte of bytes) {
        result.push(chars[byte % chars.length])
    }
    return result.join('')
}
