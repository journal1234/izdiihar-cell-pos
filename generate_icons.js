// Pure Node.js PNG icon generator (No external dependencies)
const fs = require('fs');
const zlib = require('zlib');

function createPng(size, filename) {
  const width = size;
  const height = size;
  
  // Create RGBA raw pixels
  // Background: Sky blue gradient (#0284c7 to #38bdf8) with rounded squircle
  const buffer = Buffer.alloc(height * (width * 4 + 1));
  let offset = 0;
  
  const rCorner = Math.floor(size * 0.22);
  const cx = width / 2;
  const cy = height / 2;
  
  for (let y = 0; y < height; y++) {
    buffer[offset++] = 0; // Filter byte 0 (None)
    for (let x = 0; x < width; x++) {
      // Check rounded corners
      let inBounds = true;
      const dx = Math.abs(x - cx);
      const dy = Math.abs(y - cy);
      const limit = size / 2;
      
      if (dx > limit - rCorner && dy > limit - rCorner) {
        const cornerDx = dx - (limit - rCorner);
        const cornerDy = dy - (limit - rCorner);
        if (cornerDx * cornerDx + cornerDy * cornerDy > rCorner * rCorner) {
          inBounds = false;
        }
      }
      
      if (!inBounds) {
        buffer[offset++] = 0;
        buffer[offset++] = 0;
        buffer[offset++] = 0;
        buffer[offset++] = 0;
        continue;
      }
      
      // Gradient ratio (top to bottom)
      const t = y / height;
      // Sky blue from #38bdf8 (56, 189, 248) to #0284c7 (2, 132, 199)
      const r = Math.round(56 * (1 - t) + 2 * t);
      const g = Math.round(189 * (1 - t) + 132 * t);
      const b = Math.round(248 * (1 - t) + 199 * t);
      
      // Draw phone/lightning symbol in center
      const inPhone = (x >= width * 0.28 && x <= width * 0.72 && y >= width * 0.22 && y <= width * 0.78);
      const inPhoneScreen = (x >= width * 0.32 && x <= width * 0.68 && y >= width * 0.28 && y <= width * 0.70);
      
      if (inPhoneScreen) {
        buffer[offset++] = 12;
        buffer[offset++] = 24;
        buffer[offset++] = 44;
        buffer[offset++] = 255;
      } else if (inPhone) {
        buffer[offset++] = 255;
        buffer[offset++] = 255;
        buffer[offset++] = 255;
        buffer[offset++] = 255;
      } else {
        buffer[offset++] = r;
        buffer[offset++] = g;
        buffer[offset++] = b;
        buffer[offset++] = 255;
      }
    }
  }
  
  const idatData = zlib.deflateSync(buffer);
  
  function crc32(buf) {
    let crc = -1;
    for (let i = 0; i < buf.length; i++) {
      crc = (crc >>> 8) ^ crcTable[(crc ^ buf[i]) & 0xff];
    }
    return (crc ^ -1) >>> 0;
  }
  
  const crcTable = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) {
      c = (c & 1) ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    }
    crcTable[n] = c;
  }
  
  function makeChunk(type, data) {
    const len = data.length;
    const chunk = Buffer.alloc(12 + len);
    chunk.writeUInt32BE(len, 0);
    chunk.write(type, 4);
    data.copy(chunk, 8);
    const crcVal = crc32(chunk.slice(4, 8 + len));
    chunk.writeUInt32BE(crcVal, 8 + len);
    return chunk;
  }
  
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // 8 bit depth
  ihdr[9] = 6; // Color type 6 (RGBA)
  ihdr[10] = 0; // Compression
  ihdr[11] = 0; // Filter
  ihdr[12] = 0; // Interlace
  
  const ihdrChunk = makeChunk('IHDR', ihdr);
  const idatChunk = makeChunk('IDAT', idatData);
  const iendChunk = makeChunk('IEND', Buffer.alloc(0));
  
  const pngFile = Buffer.concat([sig, ihdrChunk, idatChunk, iendChunk]);
  fs.writeFileSync(filename, pngFile);
  console.log(`Generated: ${filename} (${size}x${size}, ${pngFile.length} bytes)`);
}

createPng(192, 'icon-192.png');
createPng(512, 'icon-512.png');
