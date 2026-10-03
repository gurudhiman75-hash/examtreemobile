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
  { name: 'homeConfig', url: new URL('mobile/home-config', base), shape: 'object' },
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
        if (target.shape === 'array') {
          items = body;
          if (!Array.isArray(items)) {
            throw new Error(`Expected JSON array from ${target.url}`);
          }
        } else if (target.shape === 'series') {
          items = body?.series;
          if (!Array.isArray(items)) {
            throw new Error(`Expected JSON object with series[] from ${target.url}`);
          }
        } else if (target.shape === 'object') {
          if (!body || typeof body !== 'object' || Array.isArray(body)) {
            throw new Error(`Expected JSON object from ${target.url}`);
          }
          items = body;
        }
      }

      console.log(JSON.stringify({
        name: target.name,
        url: target.url.toString(),
        status: response.status,
        count: Array.isArray(items) ? items.length : null,
      }));
      return target.shape === 'object' ? body : items;
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

console.log(JSON.stringify({
  diagnostic: 'live-catalog',
  categories: result.categories.slice(0, 25).map((item) => ({
    id: item?.id ?? null,
    name: item?.name ?? null,
  })),
  subcategories: result.subcategories.slice(0, 50).map((item) => ({
    id: item?.id ?? null,
    categoryId: item?.categoryId ?? null,
    name: item?.name ?? null,
  })),
  testSeries: result.testSeries.slice(0, 25).map((item) => ({
    id: item?.id ?? null,
    code: item?.code ?? null,
    examCode: item?.examCode ?? null,
    name: item?.name ?? null,
    learnerVisibility: item?.learnerVisibility ?? null,
  })),
  homeConfig: {
    featuredExamFamilyIds: result.homeConfig?.configuration?.featuredExamFamilyIds ?? [],
    featuredTestSeriesIds: result.homeConfig?.configuration?.featuredTestSeriesIds ?? [],
    itemOverrides: result.homeConfig?.configuration?.itemOverrides ?? {},
  },
}));

if (result.testSeries.length === 0 && result.tests.length === 0) {
  throw new Error(
    'Production catalogue has neither learner-visible test series nor standalone tests',
  );
}
