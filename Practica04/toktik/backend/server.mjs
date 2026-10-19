import { createServer } from 'node:http';

const host = process.env.HOST ?? '0.0.0.0';
const port = Number(process.env.PORT ?? 3000);
const healthVideoId = 'M7lc1UVf-VE';
const oembedCache = new Map();

async function isOembedAvailable(videoId) {
  const cached = oembedCache.get(videoId);
  if (cached !== undefined) return cached;

  const oembedUrl = new URL('https://www.youtube.com/oembed');
  oembedUrl.searchParams.set('url', `https://www.youtube.com/watch?v=${videoId}`);
  oembedUrl.searchParams.set('format', 'json');
  const verification = fetch(oembedUrl, { signal: AbortSignal.timeout(10000) })
    .then((response) => response.status === 200)
    .catch(() => false);
  oembedCache.set(videoId, verification);

  const available = await verification;
  oembedCache.set(videoId, available);
  return available;
}

function sendJson(response, status, body) {
  response.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
    'access-control-allow-origin': process.env.CORS_ORIGIN ?? '*',
    'access-control-allow-methods': 'GET, OPTIONS',
    'access-control-allow-headers': 'content-type',
  });
  response.end(JSON.stringify(body));
}

createServer(async (request, response) => {
  const url = new URL(request.url ?? '/', `http://${request.headers.host ?? host}`);
  if (request.method === 'OPTIONS') {
    response.writeHead(204, {
      'access-control-allow-origin': process.env.CORS_ORIGIN ?? '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'content-type',
    });
    response.end();
    return;
  }
  const resource = url.pathname.match(/^\/api\/youtube\/v3\/(search|videos|commentThreads)$/)?.[1];
  if (request.method === 'GET' && resource) {
    const apiKey = process.env.YOUTUBE_API_KEY;
    if (!apiKey) {
      sendJson(response, 503, { error: { message: 'Set YOUTUBE_API_KEY in the server environment.' } });
      return;
    }
    const allowed = resource === 'search'
      ? ['part', 'type', 'q', 'regionCode', 'maxResults', 'pageToken', 'videoCategoryId', 'videoEmbeddable', 'videoSyndicated', 'videoDuration']
      : resource === 'videos'
      ? ['part', 'id', 'hl']
      : ['part', 'videoId', 'order', 'maxResults', 'textFormat'];
    const params = new URLSearchParams();
    for (const name of allowed) {
      const value = url.searchParams.get(name);
      if (value) params.set(name, value);
    }
    if (resource === 'search') {
      params.set('type', 'video');
      params.set('videoEmbeddable', 'true');
      params.set('videoSyndicated', 'true');
    }
    params.set('key', apiKey);
    try {
      const upstreamUrl = new URL(`https://www.googleapis.com/youtube/v3/${resource}`);
      upstreamUrl.search = params.toString();
      const upstream = await fetch(upstreamUrl, { signal: AbortSignal.timeout(20000) });
      const payload = await upstream.json();
      if (resource === 'search' && upstream.ok && Array.isArray(payload.items)) {
        const available = await Promise.all(payload.items.map((item) => {
          const videoId = item?.id?.videoId;
          return typeof videoId === 'string' ? isOembedAvailable(videoId) : false;
        }));
        payload.items = payload.items.filter((_, index) => available[index]);
        if (payload.pageInfo) payload.pageInfo.resultsPerPage = payload.items.length;
      }
      sendJson(response, upstream.status, payload);
    } catch (error) {
      sendJson(response, 502, {
        error: { message: error instanceof Error ? error.message : 'YouTube API unavailable.' },
      });
    }
    return;
  }
  if (request.method !== 'GET' || url.pathname !== '/api/health') {
    sendJson(response, 404, { ok: false, message: 'Not found' });
    return;
  }

  const apiKey = process.env.YOUTUBE_API_KEY;
  if (!apiKey) {
    sendJson(response, 503, {
      ok: false,
      reason: 'missingApiKey',
      message: 'Set YOUTUBE_API_KEY in the server environment.',
    });
    return;
  }

  try {
    const apiUrl = new URL('https://www.googleapis.com/youtube/v3/videos');
    apiUrl.search = new URLSearchParams({
      part: 'status,contentDetails',
      id: healthVideoId,
      key: apiKey,
    }).toString();
    const apiResponse = await fetch(apiUrl, { signal: AbortSignal.timeout(10000) });
    const payload = await apiResponse.json();
    if (!apiResponse.ok) {
      const error = payload.error ?? {};
      const detail = error.errors?.[0] ?? {};
      sendJson(response, 502, {
        ok: false,
        reason: detail.reason ?? error.status ?? 'youtubeApiError',
        message: error.message ?? `YouTube API returned HTTP ${apiResponse.status}.`,
        statusCode: apiResponse.status,
      });
      return;
    }

    const video = payload.items?.[0];
    if (!video) {
      sendJson(response, 502, {
        ok: false,
        reason: 'videoNotFound',
        message: `YouTube returned no result for the public health-check video ${healthVideoId}.`,
      });
      return;
    }

    const status = video.status ?? {};
    const details = video.contentDetails ?? {};
    const restrictions = [];
    if (status.embeddable === false) restrictions.push('embeddingDisabled');
    if (details.contentRating?.ytRating === 'ytAgeRestricted') restrictions.push('ageRestricted');
    if (details.regionRestriction?.blocked?.includes('MX')) restrictions.push('blockedInMX');
    if (
      details.regionRestriction?.allowed &&
      !details.regionRestriction.allowed.includes('MX')
    ) restrictions.push('notAllowedInMX');

    sendJson(response, 200, {
      ok: true,
      youtubeApi: 'ok',
      videoId: healthVideoId,
      embeddable: status.embeddable ?? null,
      ageRestricted: details.contentRating?.ytRating === 'ytAgeRestricted',
      restrictions,
    });
  } catch (error) {
    sendJson(response, 502, {
      ok: false,
      reason: error?.name === 'TimeoutError' ? 'youtubeApiTimeout' : 'youtubeApiUnavailable',
      message: error instanceof Error ? error.message : 'Could not reach YouTube API.',
    });
  }
}).listen(port, host, () => {
  console.log(`YouTube diagnostics listening at http://${host}:${port}/api/health`);
});
