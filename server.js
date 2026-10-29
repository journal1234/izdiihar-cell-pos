const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const DB_FILE = path.join(__dirname, 'database.json');

let serverVersion = 1;
let serverData = null;

function ensureStandardUsers(data) {
  if (!data) return;
  if (!Array.isArray(data.users) || data.users.length === 0) {
    data.users = [
      { id: 'usr_admin', name: 'Pemilik Konter', role: 'admin', pin: '1234' },
      { id: 'usr_pegawai_1', name: 'Kasir Shift 1', role: 'pegawai', pin: '1111' },
      { id: 'usr_pegawai_2', name: 'Kasir Shift 2', role: 'pegawai', pin: '2222' }
    ];
    return;
  }
  if (!data.users.some(u => u.role === 'admin')) {
    data.users.unshift({ id: 'usr_admin', name: 'Pemilik Konter', role: 'admin', pin: '1234' });
  }
  const hasShift1 = data.users.some(u => u.role === 'pegawai' && (u.name.toLowerCase().includes('shift 1') || u.id === 'usr_pegawai' || u.id === 'usr_pegawai_1'));
  if (!hasShift1) {
    const p1 = data.users.find(u => u.role === 'pegawai' && !u.name.toLowerCase().includes('shift 2'));
    if (p1) {
      p1.name = 'Kasir Shift 1';
      if (!p1.pin) p1.pin = '1111';
    } else {
      data.users.push({ id: 'usr_pegawai_1', name: 'Kasir Shift 1', role: 'pegawai', pin: '1111' });
    }
  }
  const hasShift2 = data.users.some(u => u.role === 'pegawai' && (u.name.toLowerCase().includes('shift 2') || u.id === 'usr_pegawai_2'));
  if (!hasShift2) {
    data.users.push({ id: 'usr_pegawai_2', name: 'Kasir Shift 2', role: 'pegawai', pin: '2222' });
  }
}

// Load initial database from database.json if exists
if (fs.existsSync(DB_FILE)) {
  try {
    const raw = fs.readFileSync(DB_FILE, 'utf8');
    serverData = JSON.parse(raw);
    ensureStandardUsers(serverData);
    console.log('[DB] Database loaded successfully from database.json');
  } catch (e) {
    console.warn('[DB] Warning loading database.json, will initialize from client:', e.message);
  }
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
  // Enable CORS so tunnel/domain/IP cross-origin works smoothly
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const urlParts = req.url.split('?');
  const pathname = urlParts[0];

  // ==================== REST API ENDPOINTS ====================
  // 1. Check version (Lightweight polling for real-time sync)
  if (pathname === '/api/version' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ version: serverVersion }));
    return;
  }

  // 2. Get full database state
  if (pathname === '/api/data' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ version: serverVersion, data: serverData }));
    return;
  }

  // 3. Sync & save database state from client
  if (pathname === '/api/data' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      // Protect from extremely large payloads (> 50MB)
      if (body.length > 50 * 1024 * 1024) {
        req.destroy();
      }
    });

    req.on('end', () => {
      try {
        const payload = JSON.parse(body);
        if (payload && payload.data) {
          // Proteksi: Jangan biarkan payload dengan produk lebih sedikit menghapus produk yang sudah ada di server
          if (serverData && Array.isArray(serverData.products) && serverData.products.length > 0) {
            const incProds = Array.isArray(payload.data.products) ? payload.data.products : [];
            const prodMap = new Map();
            incProds.forEach(p => { if (p && p.id) prodMap.set(p.id, p); });
            serverData.products.forEach(p => {
              if (p && p.id && !prodMap.has(p.id)) {
                prodMap.set(p.id, p);
              }
            });
            payload.data.products = Array.from(prodMap.values());
          }

          serverData = payload.data;
          ensureStandardUsers(serverData);
          serverVersion = (serverVersion || 1) + 1;

          // Write to persistent JSON file asynchronously with safety
          fs.writeFile(DB_FILE, JSON.stringify(serverData, null, 2), 'utf8', (err) => {
            if (err) console.error('[DB] Error writing database.json:', err);
          });

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: true, version: serverVersion }));
          return;
        }
      } catch (e) {
        console.error('[API] Error parsing body payload:', e.message);
      }

      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: 'Invalid payload' }));
    });
    return;
  }

  // ==================== STATIC FILE SERVING ====================
  let filePath = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    }
  });
});

const os = require('os');

function getLocalIP() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if ((net.family === 'IPv4' || net.family === 4) && !net.internal) {
        return net.address;
      }
    }
  }
  return '127.0.0.1';
}

server.listen(PORT, '0.0.0.0', () => {
  const localIP = getLocalIP();
  console.log(`========================================================`);
  console.log(`IZDIIHAR CELL Server & Real-Time Sync running:`);
  console.log(`- Akses Laptop       : http://localhost:${PORT}`);
  console.log(`- Akses HP (WiFi Toko): http://${localIP}:${PORT}`);
  console.log(`========================================================`);
});
