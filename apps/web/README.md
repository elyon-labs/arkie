# Arkie site

The public site at [arkie.elyon-labs.com](https://arkie.elyon-labs.com): a landing page, the
downloads, the release notes, the privacy policy and the terms of use. Static Astro, no client
JavaScript, no UI framework.

## Running it

```sh
pnpm web:dev          # http://localhost:4321
pnpm web:build
pnpm web:preview
pnpm web:typecheck
```

The repository is public, so a build reads its releases from the GitHub API without a token. CI
runners share an unauthenticated rate limit, so the workflows pass one anyway; locally you only
need it if you hit that limit:

```sh
GITHUB_TOKEN="$(gh auth token)" pnpm web:build
```

## Releases and downloads

`/releases` and the download links on `/download` are both built from the repository's GitHub
releases, so nothing is written by hand. `src/lib/releases.ts` reads the API once per build and
both pages share the result.

Four things shape what a reader sees:

- Pull request titles are conventional commits, and `src/lib/changes.ts` publishes only the `feat`
  and `fix` ones, with the type stripped back off. Everything else — `chore`, `docs`, `refactor`,
  `test`, `build`, `ci` — is work on the app rather than a change to it. A version left with
  nothing to say is skipped on `/releases`, though `releases()` keeps it so `/download` still has
  its installers. The `PR Title` check keeps titles in the shape this depends on; it is spelled
  out in this repository rather than called out of `elyon-labs/workflows`, because a public
  repository cannot use a private one's reusable workflows.
- A pull request labelled `internal` is kept out of the notes altogether, by `.github/release.yml`.
  The type already hides the plumbing, so this is for a `feat` or `fix` that should not be
  announced at all.
- Only the first `##` section of a release body survives. `generate_release_notes` writes the
  changes under `## What's Changed` and then a `## New Contributors` list, which belongs on GitHub
  rather than on a release notes page. Within that section only `*` or `-` list items are read, so
  a body rewritten by hand has to keep its changes as bullets.
- `firstPublicVersion` in `src/data/site.ts` is the earliest version the page will show. Raise it
  to drop older history.

`src/lib/downloads.ts` picks installers out of the latest release by filename suffix
(`-macos.dmg`, `-windows-setup.exe`, `-linux-amd64.deb`, `-linux-arm64.deb`). Those names are set
by the private deployment repository's release workflow; if it renames an asset, a platform
silently falls back to "Not in the latest release" rather than linking at something that 404s.

Every desktop platform is served from the release, macOS included — there is no store listing to
link at and no `available` flag gating one. The mobile app is the exception: it ships through the
App Store, so `storeListings` in the same file names it by hand, and a listing with no `href` shows
a "Coming soon to the App Store" badge in place of a download button.

Because both pages are read at build time, a release going out is what makes them stale. The
deploy is chained onto the end of the release pipeline for exactly that reason — see
**Deploying** below. Editing a release body by hand afterwards does not redeploy anything; run
the deploy yourself if you need the correction published.

If the API read fails the build fails with it, rather than quietly publishing pages that read as
though nothing has ever shipped.

## Theme

Colours, spacing, radii and the type scale live in `src/styles/tokens.css`, transcribed from the
apps' shared Dart theme — `ArkieTheme.desktopDark` in `packages/ui/lib/src/arkie_theme.dart`, and
`Sizes` from the Elyon Labs design package.
There is no shared package between a Flutter app and an Astro site, so a colour changed there has
to be changed here too. The site is dark only; the app offers both, but a landing page is read
once and dark is what Arkie is recognised by.

Everything else — page widths, display type sizes, the layouts this site uses — lives in
`src/styles/global.css`.

## Fonts

Space Mono, the face the app renders in, is self-hosted from `public/fonts` rather than fetched
from Google Fonts. The two files are subsets of the TTFs the app ships
(`packages/ui/assets/fonts`), about 14 KB each. Regenerate them only if those change:

```sh
pip install 'fonttools[woff]' brotli

for weight in Regular Bold; do
  pyftsubset "packages/ui/assets/fonts/SpaceMono-$weight.ttf" \
    --unicodes='U+0000-00FF,U+2000-206F,U+2190-21FF,U+2212,U+2215' \
    --layout-features=kern,liga,calt \
    --flavor=woff2 --desubroutinize \
    --output-file="apps/web/public/fonts/space-mono-$(echo "$weight" | tr '[:upper:]' '[:lower:]').woff2"
done
```

The subset covers Latin, punctuation and arrows. Space Mono has no glyphs for the Mac modifier
symbols, so copy spells shortcuts out — "Cmd-T", not "⌘T" — or they render in a fallback face
mid-word.

## Icon, social card and screenshot

`public/icon.svg` is a copy of `apps/front_end/assets/icon.svg`, which is the source of truth for
every Arkie icon — the launcher icons on all three desktops are rendered from it too. Copy it
across again if it changes; there is no build step that does it for you. It serves as the
favicon, the header mark and the hero image.

`pnpm web:assets:render` rasterises it into `public/apple-touch-icon.png` and the 1200x630
`public/og-image.png` using headless Chrome, overriding `#plate` to square off the touch icon.
Both PNGs are committed, so a build never needs it to have run.

`public/screenshot.webp` is `apps/front_end/images/arkie.png`, cropped to the window and
re-encoded:

```sh
cwebp -q 80 -crop 54 50 3140 2019 -resize 1600 0 \
  apps/front_end/images/arkie.png -o apps/web/public/screenshot.webp
```

## Typechecking

`pnpm web:typecheck` is `astro sync && tsc --noEmit`, which covers the `.ts` files and the
generated route types. `astro check`, which would also typecheck `.astro` frontmatter and template
expressions, is not wired up — it would pull `@astrojs/check` in for a five-page site. Astro still
reports accessibility problems during dev and build.

## Writing prose in templates

Astro follows JSX whitespace rules, so a newline between text and an inline element is collapsed
away entirely rather than to a space. This renders as `email atsupport@...`:

```astro
<p>
  ... email at
  <a href={supportMailtoUrl}>{site.supportEmail}</a>.
</p>
```

Keep the word before an inline `<a>` or `<strong>` on the same line as the tag and reflow the rest.

## Deploying

The deploy does not live in this repository. The Cloudflare credentials are organisation secrets
scoped to private repositories, and `CONTRIBUTING.md` asks that workflows requiring secrets stay
out of the public tree, so `web_deploy.yml` lives in the private `elyon-labs/arkie-deployment`
repository alongside the rest of the release automation.

It builds this directory and uploads `dist/` to Cloudflare as a static-assets Worker
(`arkie-web`, configured in `wrangler.jsonc`). There is no Worker code — just the assets and a
custom domain binding for `arkie.elyon-labs.com`, which needs `elyon-labs.com` to be a zone on
that Cloudflare account.

It runs two ways:

- Automatically after a release is published, chained onto the end of that repository's
  `deploy.yml`. The releases page and the download links are built from the releases themselves,
  so this is the moment they would otherwise go stale.
- By hand, by running **Web Deploy** there, for a change to the site's own content. It takes the
  ref of this repository to build, defaulting to `main`.

Either way it builds the default branch of this repository rather than a tag, so a site change
merged since the last release is not rolled back by deploying one.

What does run here is `.github/workflows/web_checks.yml`, which typechecks and builds the site on
every pull request that touches it. It needs no secrets, so it works from a fork.

`pnpm web:deploy` does the same thing from a laptop, against whatever Cloudflare account
`wrangler login` is holding.
