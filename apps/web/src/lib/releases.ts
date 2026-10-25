import { GITHUB_TOKEN } from 'astro:env/server';

import { firstPublicVersion, site } from '@/data/site';

export interface ReleaseAsset {
  name: string;
  url: string;
  /** Bytes, as GitHub reports them. */
  size: number;
}

/** A published version, with everything a reader can do with it. */
export interface Release {
  version: string;
  /** Anchor the release notes page uses, matching the version line it shows. */
  id: string;
  tag: string;
  publishedAt: Date;
  changes: readonly string[];
  assets: readonly ReleaseAsset[];
}

interface GitHubAsset {
  name: string;
  browser_download_url: string;
  size: number;
}

interface GitHubRelease {
  tag_name: string;
  body: string | null;
  draft: boolean;
  prerelease: boolean;
  published_at: string | null;
  assets: GitHubAsset[];
}

const TAG_PATTERN = /^v(\d+)\.(\d+)\.(\d+)$/;

type VersionOrder = readonly [number, number, number];

function parseTag(tag: string): { version: string; order: VersionOrder } | null {
  const match = TAG_PATTERN.exec(tag);

  if (!match) {
    return null;
  }

  const [, major, minor, patch] = match;

  return {
    version: `${major}.${minor}.${patch}`,
    order: [Number(major), Number(minor), Number(patch)],
  };
}

function compareOrder(a: VersionOrder, b: VersionOrder): number {
  for (let index = 0; index < a.length; index += 1) {
    if (a[index] !== b[index]) {
      return a[index] - b[index];
    }
  }

  return 0;
}

function isPublic(order: VersionOrder): boolean {
  const earliest = parseTag(`v${firstPublicVersion}`);

  return earliest ? compareOrder(order, earliest.order) >= 0 : false;
}

/**
 * Pulls the change lines out of a release body, leaving everything the release
 * carries for us rather than for a reader.
 *
 * The body is whatever `generate_release_notes` wrote: a `## What's Changed`
 * list of pull request titles, then a `## New Contributors` list and a compare
 * link. Only the first section's list items are kept, and each is trimmed back
 * to the title — a reader wants to know what changed, not who was thanked for
 * it. A body with no headings at all is read whole, so one rewritten by hand
 * still works.
 */
function parseChanges(body: string | null): string[] {
  if (!body) {
    return [];
  }

  const changes: string[] = [];
  let sections = 0;

  for (const line of body.split('\n').map((candidate) => candidate.trim())) {
    if (line.startsWith('##')) {
      sections += 1;

      if (sections > 1) {
        break;
      }

      continue;
    }

    if (!line.startsWith('* ') && !line.startsWith('- ')) {
      continue;
    }

    const change = line
      .slice(2)
      .replace(/\s+by @[\w-]+(?:\s+with @[\w-]+)*\s+in https:\/\/\S+$/, '')
      .trim();

    if (change.length > 0) {
      changes.push(change);
    }
  }

  return changes;
}

async function fetchReleases(): Promise<GitHubRelease[]> {
  const headers: Record<string, string> = {
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  if (GITHUB_TOKEN) {
    headers.Authorization = `Bearer ${GITHUB_TOKEN}`;
  }

  const response = await fetch(
    `https://api.github.com/repos/${site.repository}/releases?per_page=100`,
    { headers },
  );

  if (!response.ok) {
    throw new Error(
      `Could not read releases from ${site.repository}: ${response.status} ${response.statusText}.`,
    );
  }

  return (await response.json()) as GitHubRelease[];
}

async function loadReleases(): Promise<Release[]> {
  return (await fetchReleases())
    .filter((release) => !release.draft && !release.prerelease && release.published_at)
    .flatMap((release) => {
      const parsed = parseTag(release.tag_name);

      if (!parsed || !isPublic(parsed.order)) {
        return [];
      }

      return [
        {
          release,
          parsed,
          value: {
            version: parsed.version,
            id: `v${parsed.version}`,
            tag: release.tag_name,
            publishedAt: new Date(release.published_at as string),
            changes: parseChanges(release.body),
            assets: release.assets.map((asset) => ({
              name: asset.name,
              url: asset.browser_download_url,
              size: asset.size,
            })),
          } satisfies Release,
        },
      ];
    })
    .sort((a, b) => compareOrder(b.parsed.order, a.parsed.order))
    .map((entry) => entry.value);
}

/**
 * Both the release notes and the download page are built from the same list,
 * so the API is read once per build rather than once per page.
 */
let pending: Promise<Release[]> | undefined;

/**
 * Every published version worth showing, newest first.
 *
 * A failure here stops the build on purpose. Deploying with an empty list
 * would read as "nothing has ever shipped" rather than as a broken build, and
 * the previous deploy is the better thing to leave up.
 */
export function releases(): Promise<Release[]> {
  pending ??= loadReleases();

  return pending;
}

export async function latestRelease(): Promise<Release | undefined> {
  return (await releases())[0];
}

export function formatReleaseDate(date: Date): string {
  return new Intl.DateTimeFormat('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(date);
}
