import { latestRelease, type Release, type ReleaseAsset } from '@/lib/releases';

export interface PlatformDownload {
  platform: string;
  /** What the reader actually gets, e.g. `.deb installer · arm64`. */
  format: string;
  /** Null until there is something real to link to. */
  href: string | null;
  /** Stands in for the link when there is none. */
  note: string | null;
  size: number | null;
}

/**
 * Asset names are set by the private release workflow: the macOS disk image
 * and the Windows installer are renamed to `arkie-<version>-macos.dmg` and
 * `arkie-<version>-windows-setup.exe`, and each Debian package keeps the
 * Flutter package name with an `-<arch>.deb` suffix appended.
 */
function findAsset(release: Release, suffix: string): ReleaseAsset | undefined {
  return release.assets.find((asset) => asset.name.endsWith(suffix));
}

function installer(
  platform: string,
  format: string,
  asset: ReleaseAsset | undefined,
): PlatformDownload {
  if (!asset) {
    return { platform, format, href: null, note: 'Not in the latest release', size: null };
  }

  return { platform, format, href: asset.url, note: null, size: asset.size };
}

/**
 * Every platform Arkie is built for, in the order they are offered, with the
 * Linux architectures last because a reader has to pick between them.
 *
 * The macOS image is universal: one download covers Apple silicon and Intel,
 * so it needs no choice made about it the way the Debian packages do.
 */
export async function platformDownloads(): Promise<PlatformDownload[]> {
  const release = await latestRelease();

  if (!release) {
    return [];
  }

  return [
    installer('macOS', '.dmg · Apple silicon and Intel', findAsset(release, '-macos.dmg')),
    installer('Windows', '.exe installer', findAsset(release, '-windows-setup.exe')),
    installer('Linux', '.deb package · amd64', findAsset(release, '-linux-amd64.deb')),
    installer('Linux', '.deb package · arm64', findAsset(release, '-linux-arm64.deb')),
  ];
}

export interface StoreListing {
  platform: string;
  /** What the reader gets, e.g. `iOS app`. */
  format: string;
  store: string;
  /** Null until the listing is live; the page shows a "coming soon" badge instead. */
  href: string | null;
}

/**
 * The mobile app is distributed through the stores rather than GitHub
 * releases, so its listings are written here rather than read from a release.
 */
export const storeListings: readonly StoreListing[] = [
  { platform: 'iPhone', format: 'iOS app', store: 'App Store', href: null },
];

export function formatBytes(bytes: number): string {
  return `${Math.round(bytes / 1_000_000)} MB`;
}
