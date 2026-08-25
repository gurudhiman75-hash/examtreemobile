const rawBase = process.env.EXAMTREE_API_BASE_URL?.trim();
if (!rawBase) throw new Error('EXAMTREE_API_BASE_URL is required');

const base = new URL(rawBase.endsWith('/') ? rawBase : `${rawBase}/`);
if (base.pathname !== '/api/') {
  throw new Error(`Expected production API base path /api/, got ${base.pathname}`);
}

const targets = [
  { name: 'health', url: new URL('/health', base), expectArray: false },
  { name: 'tests', url: new URL('tests', base), expectArray: true, requireNonEmpty: true },
  { name: 'categories', url: new URL('categories', base), expectArray: true },
  { name: 'subcategories', url: new URL('subcategories', base), expectArray: true },
];

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function fetchWithRetry(target) {
  let lastError;
  for (let attempt = 1; attempt <= 5; attempt += 1) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 30_000);
    try {
      const response = await fetch(target.url, {
        headers: {
          accept: 'application/json',
          'x-examtree-device': 'github-production-preflight',
        },
        signal: controller.signal,
      });
      const text = await response.text();
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${text.slice(0, 300)}`);
      }

      let body = null;
      if (target.expectArray) {
        try {
          body = JSON.parse(text);
        } catch {
          throw new Error(`Expected JSON from ${target.url}`);
        }
        if (!Array.isArray(body)) {
          throw new Error(`Expected JSON array from ${target.url}`);
        }
        if (target.requireNonEmpty && body.length === 0) {
          throw new Error(`Expected non-empty array from ${target.url}`);
        }
      }

      console.log(JSON.stringify({
        name: target.name,
        url: target.url.toString(),
        status: response.status,
        count: Array.isArray(body) ? body.length : null,
      }));
      return;
    } catch (error) {
      lastError = error;
      console.error(`${target.name} attempt ${attempt}/5 failed: ${error}`);
      if (attempt < 5) await sleep(5_000);
    } finally {
      clearTimeout(timeout);
    }
  }
  throw lastError;
}

for (const target of targets) {
  await fetchWithRetry(target);
}
