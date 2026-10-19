# YouTube API proxy

This Node.js 18+ server keeps the YouTube Data API key out of the Flutter app.
It proxies only the `search`, `videos`, and `commentThreads` resources, and
provides `GET /api/health` for diagnostics. Search requests always require
embeddable and syndicated videos.

PowerShell:

```powershell
$env:YOUTUBE_API_KEY = 'your-restricted-youtube-data-api-key'
node backend/server.mjs
```

Then open `http://127.0.0.1:3000/api/health`. Android emulator clients use
`http://10.0.2.2:3000`; web clients use `http://127.0.0.1:3000`. For a physical
device or deployment, set `YOUTUBE_API_BASE_URL` to the reachable backend URL
when starting Flutter. Restrict the key to YouTube Data API v3. The health
route reports key errors and checks embedding and Mexico availability; the key
is never returned to the client.
