// Mole Heist co-op relay server.
//
// This is the public "middle" that lets two players on different networks
// connect without port forwarding. Both the host and the joiner open an
// OUTBOUND WebSocket to this server; the server pairs them by a short room
// code and then blindly forwards game packets between them.
//
// It understands only a tiny control protocol (JSON text frames):
//   client -> server : {"action":"host"}            -> server replies {"type":"hosted","code":"ABCD"}
//   client -> server : {"action":"join","code":"ABCD"} -> {"type":"joined"} (+ host gets {"type":"peer_joined"})
//                                                      or {"type":"error","reason":"no_room"|"room_full"}
//   server -> host   : {"type":"peer_left"}   when the guest disconnects
//   server -> guest  : {"type":"host_left"}   when the host disconnects
// Everything else (binary frames) is raw Godot multiplayer traffic and is
// forwarded verbatim to the other member of the room.
//
// Run locally:  PORT=8080 node relay.js   (then use ws://localhost:8080 in the game)
// Deploy:       see README.md (Render / Fly.io free tier).

const http = require('http');
const { WebSocketServer } = require('ws');

const PORT = process.env.PORT || 8080;

// code -> { host: ws, guest: ws|null }
const rooms = new Map();

// No ambiguous characters (no 0/O, 1/I) so codes are easy to read out loud.
const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function makeCode() {
  let code;
  do {
    code = '';
    for (let i = 0; i < 4; i++) {
      code += CODE_ALPHABET[Math.floor(Math.random() * CODE_ALPHABET.length)];
    }
  } while (rooms.has(code));
  return code;
}

function sendJSON(ws, obj) {
  if (ws && ws.readyState === ws.OPEN) {
    ws.send(JSON.stringify(obj));
  }
}

// Plain HTTP server so platform health checks (Render/Fly) get a 200.
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('mole-heist relay ok\n');
});

const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  ws.role = null; // 'host' | 'guest'
  ws.code = null;
  ws.isAlive = true;
  ws.on('pong', () => { ws.isAlive = true; });

  ws.on('message', (data, isBinary) => {
    if (!isBinary) {
      let msg;
      try { msg = JSON.parse(data.toString()); } catch (_) { return; }
      handleControl(ws, msg);
      return;
    }
    // Binary = game traffic. Forward to the other member of the room.
    const room = ws.code ? rooms.get(ws.code) : null;
    if (!room) return;
    const other = ws.role === 'host' ? room.guest : room.host;
    if (other && other.readyState === other.OPEN) {
      other.send(data, { binary: true });
    }
  });

  ws.on('close', () => handleClose(ws));
  ws.on('error', () => { /* close handler does the cleanup */ });
});

function handleControl(ws, msg) {
  if (!msg || typeof msg !== 'object') return;

  if (msg.action === 'host') {
    // Re-hosting on the same socket: drop the old room first.
    if (ws.code && rooms.get(ws.code) && rooms.get(ws.code).host === ws) {
      rooms.delete(ws.code);
    }
    const code = makeCode();
    ws.role = 'host';
    ws.code = code;
    rooms.set(code, { host: ws, guest: null });
    sendJSON(ws, { type: 'hosted', code });
    console.log(`[host] room ${code} created`);
    return;
  }

  if (msg.action === 'join') {
    const code = String(msg.code || '').toUpperCase().trim();
    const room = rooms.get(code);
    if (!room || !room.host || room.host.readyState !== room.host.OPEN) {
      sendJSON(ws, { type: 'error', reason: 'no_room' });
      return;
    }
    if (room.guest) {
      sendJSON(ws, { type: 'error', reason: 'room_full' });
      return;
    }
    ws.role = 'guest';
    ws.code = code;
    room.guest = ws;
    sendJSON(ws, { type: 'joined' });
    sendJSON(room.host, { type: 'peer_joined' });
    console.log(`[join] guest joined room ${code}`);
    return;
  }
}

function handleClose(ws) {
  const room = ws.code ? rooms.get(ws.code) : null;
  if (!room) return;
  if (ws.role === 'host') {
    if (room.guest) sendJSON(room.guest, { type: 'host_left' });
    rooms.delete(ws.code);
    console.log(`[close] host left, room ${ws.code} removed`);
  } else if (ws.role === 'guest') {
    if (room.guest === ws) room.guest = null;
    if (room.host) sendJSON(room.host, { type: 'peer_left' });
    console.log(`[close] guest left room ${ws.code}`);
  }
}

// Keep sockets alive and reap dead ones (free hosts drop idle TCP).
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (!ws.isAlive) return ws.terminate();
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

server.listen(PORT, () => console.log(`Mole Heist relay listening on :${PORT}`));
