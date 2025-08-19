function sha256(message) {
    // Pre-computed SHA-256 constants (avoid array lookup overhead)
    const K = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ];

    // Initial hash values
    let h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
    let h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;

    // Fast UTF-8 encoding for ASCII-only strings (common case)
    let msgBytes;
    let isAscii = true;
    
    // Quick ASCII check
    for (let i = 0; i < message.length; i++) {
        if (message.charCodeAt(i) > 127) {
            isAscii = false;
            break;
        }
    }
    
    if (isAscii) {
        // Fast path for ASCII strings
        msgBytes = new Array(message.length);
        for (let i = 0; i < message.length; i++) {
            msgBytes[i] = message.charCodeAt(i);
        }
    } else {
        // Full UTF-8 encoding
        msgBytes = stringToUtf8Bytes(message);
    }

    const msgLength = msgBytes.length;
    const bitLength = msgLength * 8;

    // Optimized padding calculation
    const totalBitsNeeded = bitLength + 1 + 64;
    const paddedLength = ((totalBitsNeeded + 511) >>> 9) << 6; // Faster than Math.ceil
    
    // Pre-allocate padded message with exact size
    const paddedMsg = new Array(paddedLength);
    
    // Fast copy using simple loop (faster than copying one by one in some engines)
    let i = 0;
    while (i < msgLength) {
        paddedMsg[i] = msgBytes[i];
        i++;
    }
    
    // Fill remaining with zeros (explicit is often faster than fill)
    while (i < paddedLength) {
        paddedMsg[i] = 0;
        i++;
    }
    
    // Add padding bit
    paddedMsg[msgLength] = 0x80;
    
    // Add length as 64-bit big-endian (optimized bit operations)
    const highBits = (bitLength / 0x100000000) >>> 0;
    const lowBits = bitLength >>> 0;
    
    const lengthOffset = paddedLength - 8;
    paddedMsg[lengthOffset] = highBits >>> 24;
    paddedMsg[lengthOffset + 1] = (highBits >>> 16) & 0xFF;
    paddedMsg[lengthOffset + 2] = (highBits >>> 8) & 0xFF;
    paddedMsg[lengthOffset + 3] = highBits & 0xFF;
    paddedMsg[lengthOffset + 4] = lowBits >>> 24;
    paddedMsg[lengthOffset + 5] = (lowBits >>> 16) & 0xFF;
    paddedMsg[lengthOffset + 6] = (lowBits >>> 8) & 0xFF;
    paddedMsg[lengthOffset + 7] = lowBits & 0xFF;

    // Pre-allocate working array (reused across chunks)
    const w = new Array(64);

    // Process message in 512-bit chunks
    for (let chunk = 0; chunk < paddedLength; chunk += 64) {
        
        // Unrolled word extraction for better performance
        let offset = chunk;
        w[0] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[1] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[2] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[3] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[4] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[5] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[6] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[7] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[8] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[9] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[10] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[11] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[12] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[13] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[14] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3]; offset += 4;
        w[15] = (paddedMsg[offset] << 24) | (paddedMsg[offset + 1] << 16) | (paddedMsg[offset + 2] << 8) | paddedMsg[offset + 3];

        // Extend words (partially unrolled for better performance)
        for (let i = 16; i < 64; i += 4) {
            // Process 4 words at once
            let s0 = rightRotate(w[i - 15], 7) ^ rightRotate(w[i - 15], 18) ^ (w[i - 15] >>> 3);
            let s1 = rightRotate(w[i - 2], 17) ^ rightRotate(w[i - 2], 19) ^ (w[i - 2] >>> 10);
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) >>> 0;
            
            s0 = rightRotate(w[i - 14], 7) ^ rightRotate(w[i - 14], 18) ^ (w[i - 14] >>> 3);
            s1 = rightRotate(w[i - 1], 17) ^ rightRotate(w[i - 1], 19) ^ (w[i - 1] >>> 10);
            w[i + 1] = (w[i - 15] + s0 + w[i - 6] + s1) >>> 0;
            
            s0 = rightRotate(w[i - 13], 7) ^ rightRotate(w[i - 13], 18) ^ (w[i - 13] >>> 3);
            s1 = rightRotate(w[i], 17) ^ rightRotate(w[i], 19) ^ (w[i] >>> 10);
            w[i + 2] = (w[i - 14] + s0 + w[i - 5] + s1) >>> 0;
            
            s0 = rightRotate(w[i - 12], 7) ^ rightRotate(w[i - 12], 18) ^ (w[i - 12] >>> 3);
            s1 = rightRotate(w[i + 1], 17) ^ rightRotate(w[i + 1], 19) ^ (w[i + 1] >>> 10);
            w[i + 3] = (w[i - 13] + s0 + w[i - 4] + s1) >>> 0;
        }

        // Initialize working variables
        let a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;

        // Main loop (partially unrolled)
        for (let i = 0; i < 64; i += 8) {
            // Round 1
            let S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            let ch = (e & f) ^ (~e & g);
            let temp1 = (h + S1 + ch + K[i] + w[i]) >>> 0;
            let S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 2
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 1] + w[i + 1]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 3
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 2] + w[i + 2]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 4
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 3] + w[i + 3]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 5
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 4] + w[i + 4]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 6
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 5] + w[i + 5]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 7
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 6] + w[i + 6]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
            
            // Round 8
            S1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
            ch = (e & f) ^ (~e & g);
            temp1 = (h + S1 + ch + K[i + 7] + w[i + 7]) >>> 0;
            S0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
            maj = (a & b) ^ (a & c) ^ (b & c);
            temp2 = (S0 + maj) >>> 0;
            h = g; g = f; f = e; e = (d + temp1) >>> 0; d = c; c = b; b = a; a = (temp1 + temp2) >>> 0;
        }

        // Add chunk's hash to result
        h0 = (h0 + a) >>> 0; h1 = (h1 + b) >>> 0; h2 = (h2 + c) >>> 0; h3 = (h3 + d) >>> 0;
        h4 = (h4 + e) >>> 0; h5 = (h5 + f) >>> 0; h6 = (h6 + g) >>> 0; h7 = (h7 + h) >>> 0;
    }

    // Fast hex conversion (pre-computed lookup table would be even faster)
    const hex = '0123456789abcdef';
    let result = '';
    
    const hashes = [h0, h1, h2, h3, h4, h5, h6, h7];
    for (let i = 0; i < 8; i++) {
        const h = hashes[i];
        result += hex[(h >>> 28) & 15] + hex[(h >>> 24) & 15] + hex[(h >>> 20) & 15] + hex[(h >>> 16) & 15] +
                  hex[(h >>> 12) & 15] + hex[(h >>> 8) & 15] + hex[(h >>> 4) & 15] + hex[h & 15];
    }
    
    return result;
}

function stringToUtf8Bytes(str) {
    const bytes = [];
    for (let i = 0; i < str.length; i++) {
        let code = str.charCodeAt(i);
        
        if (code < 0x80) {
            bytes.push(code);
        } else if (code < 0x800) {
            bytes.push(0xC0 | (code >> 6), 0x80 | (code & 0x3F));
        } else if (code < 0xD800 || code > 0xDFFF) {
            bytes.push(0xE0 | (code >> 12), 0x80 | ((code >> 6) & 0x3F), 0x80 | (code & 0x3F));
        } else {
            i++;
            const code2 = str.charCodeAt(i);
            const codePoint = 0x10000 + (((code & 0x3FF) << 10) | (code2 & 0x3FF));
            bytes.push(0xF0 | (codePoint >> 18), 0x80 | ((codePoint >> 12) & 0x3F), 
                      0x80 | ((codePoint >> 6) & 0x3F), 0x80 | (codePoint & 0x3F));
        }
    }
    return bytes;
}

// Inline right rotate function for better performance
function rightRotate(value, amount) {
    return ((value >>> amount) | (value << (32 - amount))) >>> 0;
}

// Test function to verify implementation
// function testSHA256() {
//   const tests = [
//     {
//       input: "",
//       expected:
//         "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
//     },
//     {
//       input: "Hello World",
//       expected:
//         "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
//     },
//     {
//       input: "abc",
//       expected:
//         "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
//     },
//     {
//       input: "The quick brown fox jumps over the lazy dog",
//       expected:
//         "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592",
//     },
//   ];

//   console.log("Running SHA-256 tests:");
//   tests.forEach((test, i) => {
//     const result = Crypto.sha256(test.input);
//     const passed = result === test.expected;
//     console.log(`Test ${i + 1}: ${passed ? "PASS" : "FAIL"}`);
//     if (!passed) {
//       console.log(`  Input: "${test.input}"`);
//       console.log(`  Expected: ${test.expected}`);
//       console.log(`  Got:      ${result}`);
//     }
//   });
// }
