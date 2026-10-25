import { site } from '@/data/site';

export const supportMailtoUrl = `mailto:${site.supportEmail}`;

/**
 * Canonical URLs are the no-trailing-slash form, matching how links are
 * written in the pages themselves. Astro's `build.format: 'directory'` makes
 * `Astro.url.pathname` come back as `/privacy/`, so normalise here and let
 * both the <link rel="canonical"> tags and the sitemap go through this
 * function — otherwise the two disagree about which URL is the real one.
 */
export function canonicalUrl(path: string): string {
  const normalized = path.replace(/\/+$/, '') || '/';

  return new URL(normalized, site.url).href;
}
