import { storeLinks } from '@/data/site';
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
 * Asset names are set by the private release workflow: the Windows installer
 * is renamed to `arkie-<version>-windows-setup.exe`, and each Debian package
 * keeps the Flutter package name with an `-<arch>.deb` suffix appended.
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

function macOsDownload(): PlatformDownload {
  const store = storeLinks.find((link) => link.platform === 'macOS');

  if (!store?.available) {
    return {
      platform: 'macOS',
      format: 'Mac App Store',
      href: null,
      note: 'Coming soon',
      size: null,
    };
  }

  return {
    platform: 'macOS',
    format: 'Mac App Store',
    href: store.href,
    note: null,
    size: null,
  };
}

/**
 * Every platform Arkie is built for, in the order they are offered — macOS
 * first because it is the only one that goes through a store, and the Linux
 * architectures last because a reader has to pick between them.
 */
export async function platformDownloads(): Promise<PlatformDownload[]> {
  const release = await latestRelease();

  if (!release) {
    return [macOsDownload()];
  }

  return [
    macOsDownload(),
    installer('Windows', '.exe installer', findAsset(release, '-windows-setup.exe')),
    installer('Linux', '.deb package · amd64', findAsset(release, '-linux-amd64.deb')),
    installer('Linux', '.deb package · arm64', findAsset(release, '-linux-arm64.deb')),
  ];
}

export function formatBytes(bytes: number): string {
  return `${Math.round(bytes / 1_000_000)} MB`;
}
