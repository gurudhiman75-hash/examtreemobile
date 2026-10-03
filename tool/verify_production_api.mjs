const rawBase = process.env.EXAMTREE_API_BASE_URL?.trim();
if (!rawBase) throw new Error('EXAMTREE_API_BASE_URL is required');

const base = new URL(rawBase.endsWith('/') ? rawBase : `${rawBase}/`);
if (base.pathname !== '/api/') {
  throw new Error(`Expected production API base path /api/, got ${base.pathname}`);
}

const targets = [
  { name: 'health', url: new URL('/health', base), shape: 'none' },
  { name: 'tests', url: new URL('tests', base), shape: 'array' },
  { name: 'categories', url: new URL('categories', base), shape: 'array' },
  { name: 'subcategories', url: new URL('subcategories', base), shape: 'array' },
  { name: 'testSeries', url: new URL('test-series', base), shape: 'series' },
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
          'cache-control': 'no-cache',
          'x-examtree-device': 'github-production-preflight',
        },
        signal: controller.signal,
      });
      const text = await response.text();
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${text.slice(0, 300)}`);
      }

      let body = null;
      let items = null;
      if (target.shape !== 'none') {
        try {
          body = JSON.parse(text);
        } catch {
          throw new Error(`Expected JSON from ${target.url}`);
        }
        items = target.shape === 'array' ? body : body?.series;
        if (!Array.isArray(items)) {
          throw new Error(
            target.shape === 'array'
              ? `Expected JSON array from ${target.url}`
              : `Expected JSON object with series[] from ${target.url}`,
          );
        }
      }

      console.log(JSON.stringify({
        name: target.name,
        url: target.url.toString(),
        status: response.status,
        count: Array.isArray(items) ? items.length : null,
      }));
      return items;
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

const result = {};
for (const target of targets) {
  result[target.name] = await fetchWithRetry(target);
}

if (result.categories.length === 0 || result.subcategories.length === 0) {
  throw new Error(
    'Production exam taxonomy is empty even though the mobile API is reachable',
  );
}

if (result.testSeries.length === 0 && result.tests.length === 0) {
  throw new Error(
    'Production catalogue has neither learner-visible test series nor standalone tests',
  );
}
