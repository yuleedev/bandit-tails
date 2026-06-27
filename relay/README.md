# Mole Heist co-op relay

This is the little server that makes co-op work **across different networks**
(no port forwarding, no "type my IP"). Host and joiner both connect out to this
server; it pairs them by a 4-letter room code and forwards game traffic between
them. It works for both the desktop build and the web build.

You deploy this **once**, then paste its URL into the game.

---

## 1. Test it locally first (optional)

```bash
cd relay
npm install
npm start          # listens on http://localhost:8080
```

In `Scripts/sm.gd` temporarily set:

```gdscript
const RELAY_URL := "ws://localhost:8080"
```

Run two copies of the game on the same machine (one Host, one Join with the
code). If that works, deploy for real and switch the URL to `wss://...`.

---

## 2. Deploy for free (pick one)

You need somewhere with a public address. Both options below have a free tier
and give you HTTPS/`wss://` automatically.

### Option A — Render (easiest, web UI)

1. Push this repo to GitHub (the `relay/` folder is enough).
2. Go to <https://render.com> → **New** → **Web Service** → connect your repo.
3. Settings:
   - **Root Directory:** `relay`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance Type:** Free
4. Deploy. Render gives you a URL like `https://mole-heist-relay.onrender.com`.
5. In the game, use the `wss://` form of that host:

   ```gdscript
   const RELAY_URL := "wss://mole-heist-relay.onrender.com"
   ```

   (Same hostname, just `wss://` instead of `https://`, no path.)

> Note: Render's free tier sleeps after ~15 min idle, so the very first
> connection after a while can take ~30 s to wake up. Fine for playing with
> friends; upgrade the instance if you want it always-on.

### Option B — Fly.io (CLI, no sleep)

```bash
cd relay
fly launch --no-deploy        # creates fly.toml; pick a name + region
fly deploy
```

Make sure `fly.toml` exposes the internal port as 8080 and forces HTTPS:

```toml
[http_service]
  internal_port = 8080
  force_https = true
```

Your URL is `wss://<app-name>.fly.dev`.

---

## 3. Point the game at it

Edit **`Scripts/sm.gd`**, line near the top:

```gdscript
const RELAY_URL := "wss://YOUR-RELAY-URL-HERE"
```

Re-export the game. Done — Host shows a code, the other player types it, and
you're connected from anywhere.

---

## How it works (1 paragraph)

The game's networking goes through `RelayMultiplayerPeer`
(`Scripts/relay_multiplayer_peer.gd`), a custom Godot `MultiplayerPeer` that
opens a WebSocket to this relay instead of a direct ENet/UDP socket. The host is
still peer `1` (the authoritative server) and the joiner is peer `2`, exactly
like before — so all existing RPCs, spawners and authority logic are unchanged.
The relay only pairs the two sockets by room code and copies bytes between them;
it never inspects or runs game logic, so one cheap instance can host many
simultaneous games.
