import { sitePages } from '@/data/site';
import { canonicalUrl } from '@/lib/urls';

import type { APIRoute } from 'astro';

/**
 * Hand-rolled rather than using @astrojs/sitemap: the site is five pages, and
 * `sitePages` already has to exist for the routes to be listed in one place.
 */
export const GET: APIRoute = () => {
  const urls = sitePages
    .filter((page) => page.includeInSitemap)
    .map((page) => `  <url><loc>${canonicalUrl(page.path)}</loc></url>`)
    .join('\n');

  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>
`;

  return new Response(body, {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
};
