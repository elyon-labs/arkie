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

Three things shape what a reader sees:

- A pull request labelled `internal` is kept out of the notes altogether, by `.github/release.yml`.
  Label the plumbing — CI, build config, dependency bumps — or it is published as a user-facing
  change.
- Only the first `##` section of a release body survives. `generate_release_notes` writes the
  changes under `## What's Changed` and then a `## New Contributors` list, which belongs on GitHub
  rather than on a release notes page. Within that section only `*` or `-` list items are read, so
  a body rewritten by hand has to keep its changes as bullets.
- `firstPublicVersion` in `src/data/site.ts` is the earliest version the page will show. Raise it
  to drop older history that was generated before the `internal` label existed.

`src/lib/downloads.ts` picks installers out of the latest release by filename suffix
(`-windows-setup.exe`, `-linux-amd64.deb`, `-linux-arm64.deb`). Those names are set by the private
deployment repository's release workflow; if it renames an asset, a platform silently falls back to
"Not in the latest release" rather than linking at something that 404s.

A release does not touch `apps/web`, so publishing one cannot deploy the site through the path
filter. `web_deploy.yml` runs on the `release` event instead, for `published`, `edited` and
`deleted`.

If the API read fails the build fails with it, rather than quietly publishing pages that read as
though nothing has ever shipped.

## Store links

`storeLinks` in `src/data/site.ts` holds the Mac App Store URL with `available: false`, and the
placeholder app id it carries is not a real listing. Nothing links to the store until that flag is
flipped; until then the download page shows a plain "Coming soon" instead. Fill in the real id and
flip the flag the day the listing goes public.

## Theme

Colours, spacing, radii and the type scale live in `src/styles/tokens.css`, transcribed from the
app's Dart theme in `apps/front_end/lib/core_ui/` — `colors.dart`, `sizes.dart` and `text.dart`.
There is no shared package between a Flutter app and an Astro site, so a colour changed there has
to be changed here too. The site is dark only; the app offers both, but a landing page is read
once and dark is what Arkie is recognised by.

Everything else — page widths, display type sizes, the layouts this site uses — lives in
`src/styles/global.css`.

## Fonts

Space Mono, the face the app renders in, is self-hosted from `public/fonts` rather than fetched
from Google Fonts. The two files are subsets of the TTFs the app ships
(`apps/front_end/assets/fonts`), about 14 KB each. Regenerate them only if those change:

```sh
pip install 'fonttools[woff]' brotli

for weight in Regular Bold; do
  pyftsubset "apps/front_end/assets/fonts/SpaceMono-$weight.ttf" \
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

`public/icon.svg` is the site's own mark: the app's accent purple on its background colour. It
serves as the favicon, the header mark and the hero image. `pnpm web:assets:render` rasterises it
into `public/apple-touch-icon.png` and the 1200x630 `public/og-image.png` using headless Chrome.
Both PNGs are committed, so a build never needs it to have run.

The mark deliberately does not match the launcher icon the app currently ships
(`apps/front_end/assets/rcon_icon.png`), which is green and reads "RCON" — it predates both the
Arkie name and the purple accent. When that icon is redrawn, bring this one in line with it.

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

Pushes to `main` that touch `apps/web` run `.github/workflows/web_deploy.yml`, which builds the
site and uploads `dist/` to Cloudflare as a static-assets Worker (`arkie-web`, configured in
`wrangler.jsonc`). There is no Worker code — just the assets and a custom domain binding for
`arkie.elyon-labs.com`.

Two repository secrets are required:

| Secret | What it is |
| --- | --- |
| `CLOUDFLARE_API_TOKEN` | API token with the **Workers Scripts: Edit** permission |
| `CLOUDFLARE_ACCOUNT_ID` | The Cloudflare account the Worker lives in |

The custom domain in `wrangler.jsonc` needs `elyon-labs.com` to be a zone on that account.
`arkie.elyon-labs.com` previously pointed at GitHub Pages, so **delete that DNS record before the
first deploy** — Cloudflare will not bind a custom domain over an existing record, and the deploy
fails until it is gone.

`pnpm web:deploy` does the same thing from a laptop, against whatever Cloudflare account
`wrangler login` is holding.
