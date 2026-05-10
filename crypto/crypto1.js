/**
 * @param {String} base64
 * @returns {Uint8Array}
 */
function bytesFromBase64(base64) {
    const temp = atob(base64)
    return bytesFromChars(temp)
}

/**
 * @param {String} text
 * @returns {Uint8Array}
 */
function bytesFromChars(text) {
    const length = text.length
    const result = new Uint8Array(length)
    for (let i = 0; i < length; i++) {
        result[i] = text.charCodeAt(i)
    }
    return result
}

/**
 * @param {String} utf8
 * @returns {Uint8Array}
 */
function bytesFromUtf8(utf8) {
    const encoder = new TextEncoder()
    return encoder.encode(utf8)
}

/**
 * @param {Uint8Array} bytes
 * @returns {String}
 */
function bytesToBase64(bytes) {
    const temp = bytesToChars(bytes)
    return btoa(temp)
}

/**
 * @param {Uint8Array} bytes
 * @returns {String}
 */
function bytesToChars(bytes) {
    return String.fromCharCode(...bytes)
}

/**
 * @param {Uint8Array} bytes
 * @returns {String}
 */
function bytesToUtf8(bytes) {
    const decoder = new TextDecoder()
    return decoder.decode(bytes)
}

/**
 * @param {Uint8Array} bytes
 * @returns {String}
 */
function printBytes(bytes) {
    const root = document.createElement('div')
    for (const byte of bytes) {
        const div1 = document.createElement('div')
        const div2 = document.createElement('div')
        const div3 = document.createElement('div')
        div2.innerText = byte.toString(16)
        if (byte >= 32 && byte <= 126) {
            div3.innerText = String.fromCharCode(byte)
        }
        div1.appendChild(div2)
        div1.appendChild(div3)
        root.appendChild(div1)
    }
    return root.innerHTML
}

/**
 * @param {Number} length
 * @returns {Uint8Array}
 */
function randomBytes(length) {
    const bytes = new Uint8Array(length)
    return crypto.getRandomValues(bytes)
}

/**
 * @param {Number} length
 * @param {Array} chars
 * @returns {String}
 */
function randomString(length, chars) {
    const bytes = randomBytes(length)
    const result = []
    for (const byte of bytes) {
        result.push(chars[byte % chars.length])
    }
    return result.join('')
}
