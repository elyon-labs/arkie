export const site = {
  name: 'Arkie',
  wordmark: 'arkie',
  tagline: 'Run your CS2 server without launching the game.',
  description:
    'Arkie is an open-source RCON client for Counter-Strike 2. Save your servers, send commands, change maps and manage players from a desktop app on macOS, Windows and Linux. No account, no telemetry.',
  url: 'https://arkie.elyon-labs.com',
  repository: 'elyon-labs/arkie',
  supportEmail: 'support@elyon-labs.com',
  vendor: 'Elyon Labs, LLC',
  copyrightYear: 2026,
  license: 'MIT',
} as const;

export const repositoryUrl = `https://github.com/${site.repository}`;
export const issuesUrl = `${repositoryUrl}/issues/new/choose`;
export const releasesUrl = `${repositoryUrl}/releases`;

export type SitePage = {
  path: string;
  includeInSitemap: boolean;
};

export const sitePages: readonly SitePage[] = [
  { path: '/', includeInSitemap: true },
  { path: '/download', includeInSitemap: true },
  { path: '/releases', includeInSitemap: true },
  { path: '/privacy', includeInSitemap: true },
  { path: '/terms-of-use', includeInSitemap: true },
];

/**
 * The earliest version the release notes page will show.
 *
 * Everything below it predates the site, and its notes were generated against
 * a repository with no `internal` label to keep the plumbing out of them.
 */
export const firstPublicVersion = '0.0.28';

/** Shown on the legal pages so a reader can tell how current they are. */
export const legalLastUpdated = '24 October 2026';

export const navLinks = [
  { label: 'Features', href: '/#features' },
  { label: 'Download', href: '/download' },
  { label: 'Releases', href: '/releases' },
  { label: 'Source', href: repositoryUrl },
] as const;
