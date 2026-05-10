function fromUtf8(text) {
    const encoder = new TextEncoder()
    return encoder.encode(text)
}

function printBytes(bytes) {
    const root = document.createElement('div')
    for (const byte of bytes) {
        const div1 = document.createElement('div')
        const div2 = document.createElement('div')
        const div3 = document.createElement('div')
        const number = Number(byte)
        div2.innerText = number.toString(16)
        div3.innerText = String.fromCharCode(number)
        div1.appendChild(div2)
        div1.appendChild(div3)
        root.appendChild(div1)
    }
    return root
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
