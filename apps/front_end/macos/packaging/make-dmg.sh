#!/usr/bin/env bash
#
# Builds, signs, notarises and staples the macOS app, leaving a .dmg that
# opens on any Mac without a Gatekeeper warning.
#
# Distribution is Developer ID rather than the Mac App Store, so nothing here
# waits on App Review: notarisation is an automated malware scan that usually
# answers within minutes. The trade-off is that updates are not delivered for
# us — the site links at the release, and the app has to tell its own users
# that a newer one exists.
#
# No credentials live in this repository. Everything below is read from the
# environment, which the private deployment repository fills from its secrets.
#
# The signing identity is found in the keychain on its own when there is
# exactly one Developer ID Application certificate, which is the normal case;
# APPLE_SIGNING_IDENTITY overrides that and is required when there are
# several.
#
# Notarisation takes an App Store Connect API key, the same one the deploy
# lane already holds, either as a file:
#
#   APPLE_API_KEY_PATH       path to the .p8 private key
#   APPLE_API_KEY_ID         the key id
#   APPLE_API_ISSUER         the issuer uuid
#
# or as content, raw or base64, under the names the workflow already sets:
#
#   APP_STORE_CONNECT_API_KEY_KEY
#   APP_STORE_CONNECT_API_KEY_KEY_ID
#   APP_STORE_CONNECT_API_KEY_ISSUER_ID
#
# Failing both, an Apple ID with an app-specific password, which is easier by
# hand:
#
#   APPLE_ID                 the Apple ID the Developer Program is under
#   APPLE_TEAM_ID            the 10-character team id
#   APPLE_APP_PASSWORD       an app-specific password, not the account password
#
# BUILD_NUMBER sets the build number when given; without it the one already
# in pubspec.yaml stands. Set SKIP_NOTARIZE=1 to stop after signing — the
# .dmg that produces is signed but not stapled, so it is good for checking a
# build and useless to ship.
#
# Usage: make-dmg.sh [version]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_dir="$(cd "$here/../.." && pwd)"

version="${1:-$(grep '^version:' "$app_dir/pubspec.yaml" | awk '{print $2}' | cut -d+ -f1)}"
app="$app_dir/build/macos/Build/Products/Release/Arkie.app"
dmg="$app_dir/build/arkie-$version-macos.dmg"
entitlements="$app_dir/macos/Runner/Release.entitlements"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

if [[ -z "${APPLE_SIGNING_IDENTITY:-}" ]]; then
  found="$(security find-identity -v -p codesigning |
    sed -n 's/.*"\(Developer ID Application:.*\)"$/\1/p')"
  case "$(printf '%s' "$found" | grep -c .)" in
    0) echo "No Developer ID Application certificate in the keychain." >&2; exit 1 ;;
    1) APPLE_SIGNING_IDENTITY="$found" ;;
    *) echo "Several Developer ID Application certificates; set APPLE_SIGNING_IDENTITY:" >&2
       printf '  %s\n' "$found" >&2; exit 1 ;;
  esac
fi
echo "==> Signing as $APPLE_SIGNING_IDENTITY"

echo "==> Building Arkie $version"
build_args=(macos --release "--build-name=$version")
[[ -n "${BUILD_NUMBER:-}" ]] && build_args+=("--build-number=$BUILD_NUMBER")
(cd "$app_dir" && flutter build "${build_args[@]}")

# Signing runs inside out because the signature of a bundle covers everything
# nested in it: re-signing a framework afterwards would invalidate the app.
# -depth is what walks the deepest matches first.
echo "==> Signing"
while IFS= read -r -d '' nested; do
  codesign --force --timestamp --options runtime \
    --sign "$APPLE_SIGNING_IDENTITY" "$nested"
done < <(find "$app/Contents/Frameworks" -depth \
  \( -name '*.framework' -o -name '*.dylib' \) -print0 2>/dev/null)

# --options runtime is the hardened runtime, which the notary service refuses
# a submission without.
codesign --force --timestamp --options runtime \
  --entitlements "$entitlements" \
  --sign "$APPLE_SIGNING_IDENTITY" "$app"

codesign --verify --deep --strict --verbose=2 "$app"

echo "==> Packaging"
staging="$work/dmg"
mkdir -p "$staging"
cp -R "$app" "$staging/"
ln -s /Applications "$staging/Applications"

rm -f "$dmg"
hdiutil create -volname Arkie -srcfolder "$staging" -ov -format UDZO "$dmg" >/dev/null
codesign --force --timestamp --sign "$APPLE_SIGNING_IDENTITY" "$dmg"

if [[ -n "${SKIP_NOTARIZE:-}" ]]; then
  echo "==> SKIP_NOTARIZE set, stopping at $dmg"
  exit 0
fi

if [[ -n "${APPLE_API_KEY_PATH:-}" ]]; then
  auth=(--key "$APPLE_API_KEY_PATH"
        --key-id "${APPLE_API_KEY_ID:?set APPLE_API_KEY_ID alongside APPLE_API_KEY_PATH}"
        --issuer "${APPLE_API_ISSUER:?set APPLE_API_ISSUER alongside APPLE_API_KEY_PATH}")
elif [[ -n "${APP_STORE_CONNECT_API_KEY_KEY:-}" ]]; then
  # The workflow carries the key as base64 for fastlane's sake, but hand-runs
  # may well paste the PEM itself, so take it either way.
  key="$work/notary.p8"
  if [[ "$APP_STORE_CONNECT_API_KEY_KEY" == -----BEGIN* ]]; then
    printf '%s\n' "$APP_STORE_CONNECT_API_KEY_KEY" > "$key"
  else
    printf '%s' "$APP_STORE_CONNECT_API_KEY_KEY" | base64 --decode > "$key"
  fi
  chmod 600 "$key"
  auth=(--key "$key"
        --key-id "${APP_STORE_CONNECT_API_KEY_KEY_ID:?set APP_STORE_CONNECT_API_KEY_KEY_ID}"
        --issuer "${APP_STORE_CONNECT_API_KEY_ISSUER_ID:?set APP_STORE_CONNECT_API_KEY_ISSUER_ID}")
else
  auth=(--apple-id "${APPLE_ID:?set an API key or APPLE_ID}"
        --team-id "${APPLE_TEAM_ID:?set APPLE_TEAM_ID alongside APPLE_ID}"
        --password "${APPLE_APP_PASSWORD:?set APPLE_APP_PASSWORD alongside APPLE_ID}")
fi

echo "==> Notarising"
xcrun notarytool submit "$dmg" "${auth[@]}" --wait

# Stapling writes the notarisation ticket into the .dmg itself, which is what
# lets a Mac that is offline, or behind a firewall that blocks Apple, open it
# without a warning.
echo "==> Stapling"
xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg"

echo "==> $dmg"
