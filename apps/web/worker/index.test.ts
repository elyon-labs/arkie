import { describe, expect, it, vi } from 'vitest';

import worker from './index';

function assets() {
  return { fetch: vi.fn(async () => new Response('the site')) };
}

async function get(url: string, env = { ASSETS: assets() }) {
  const response = await worker.fetch(new Request(url), env);

  return { response, env };
}

describe('the www redirect', () => {
  it('sends www to the canonical host', async () => {
    const { response, env } = await get('https://www.arkie.elyon-labs.com/');

    expect(response.status).toBe(301);
    expect(response.headers.get('location')).toBe('https://arkie.elyon-labs.com/');
    expect(env.ASSETS.fetch).not.toHaveBeenCalled();
  });

  it('keeps the path and the query string', async () => {
    const { response } = await get('https://www.arkie.elyon-labs.com/releases?from=mail');

    expect(response.headers.get('location')).toBe('https://arkie.elyon-labs.com/releases?from=mail');
  });

  it('serves the canonical host from the assets', async () => {
    const { response, env } = await get('https://arkie.elyon-labs.com/privacy');

    expect(response.status).toBe(200);
    expect(env.ASSETS.fetch).toHaveBeenCalledOnce();
  });

  // `www` is only the leading label; a path or a host that merely contains it
  // is not a request for the www site.
  it('leaves a path that starts with www alone', async () => {
    const { response, env } = await get('https://arkie.elyon-labs.com/www/report');

    expect(response.status).toBe(200);
    expect(env.ASSETS.fetch).toHaveBeenCalledOnce();
  });
});
