const rawBase = process.env.EXAMTREE_API_BASE_URL?.trim();
if (!rawBase) throw new Error('EXAMTREE_API_BASE_URL is required');

const base = new URL(rawBase.endsWith('/') ? rawBase : `${rawBase}/`);
if (base.pathname !== '/api/') {
  throw new Error(`Expected production API base path /api/, got ${base.pathname}`);
}

const targets = [
  { name: 'health', url: new URL('/health', base), kind: 'json' },
  { name: 'tests', url: new URL('tests', base), kind: 'array' },
  { name: 'categories', url: new URL('categories', base), kind: 'array' },
  { name: 'subcategories', url: new URL('subcategories', base), kind: 'array' },
  { name: 'testSeries', url: new URL('test-series', base), kind: 'series' },
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
      try {
        body = JSON.parse(text);
      } catch {
        throw new Error(`Expected JSON from ${target.url}`);
      }

      if (target.kind === 'array' && !Array.isArray(body)) {
        throw new Error(`Expected JSON array from ${target.url}`);
      }

      if (target.kind === 'series') {
        const series = body && typeof body === 'object' ? body.series : null;
        if (!Array.isArray(series)) {
          throw new Error(`Expected { series: [] } from ${target.url}`);
        }
      }

      const count = target.kind === 'array'
        ? body.length
        : target.kind === 'series'
          ? body.series.length
          : null;

      console.log(JSON.stringify({
        name: target.name,
        url: target.url.toString(),
        status: response.status,
        count,
      }));
      return body;
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

const standaloneTestCount = Array.isArray(result.tests) ? result.tests.length : 0;
const seriesCount = Array.isArray(result.testSeries?.series)
  ? result.testSeries.series.length
  : 0;

if (standaloneTestCount === 0 && seriesCount === 0) {
  throw new Error(
    'Production catalogue has neither standalone tests nor published test series',
  );
}
