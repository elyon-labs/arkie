# App Store listing

Every field App Store Connect asks for, written out so the listing is reviewed here rather than in
a text box. The art it refers to is in [`assets/store`](../assets/store), produced by the two
scripts in [`tool`](../tool).

Nothing here is uploaded automatically. `elyon-labs/arkie-deployment` builds and ships the binary;
the listing is filled in by hand.

## App information

| Field | Value |
| --- | --- |
| Name | `Arkie` |
| Subtitle | `RCON console for CS2 servers` |
| Bundle ID | `com.elyon-labs.arkie` |
| Primary category | Utilities |
| Secondary category | Developer Tools |
| Price | Free |
| Copyright | `2026 Elyon Labs, LLC` |
| Support URL | `https://arkie.elyon-labs.com` |
| Marketing URL | `https://arkie.elyon-labs.com` |
| Privacy Policy URL | `https://arkie.elyon-labs.com/privacy` |

`Arkie` is 5 of the 30 characters a name may use, and the subtitle is 28 of its 30. If the name is
already taken, `Arkie Console` keeps the wordmark first; do not fall back to a name of the form
"Arkie for Counter-Strike", which Apple rejects for leading with somebody else's trademark.

## Promotional text

Editable without a new build, so it is the line that changes between releases.

```
Save your servers, keep each one's console a tap away, and change maps or kick a player without alt-tabbing into the game. No account, no telemetry.
```

148 of 170 characters, on one line — App Store Connect keeps any line break you paste in.

## Description

```
Arkie is an RCON client for Counter-Strike 2 servers. Save a server once and its console is a tap away — send commands, watch the replies, change the map, kick somebody — without launching the game or sitting at the machine you run it from.

A CONSOLE YOU CAN READ
Everything you sent and everything the server said back, in one scrolling transcript. Your commands carry the prompt and the accent colour; the server's output is left plain, so a long status dump still reads as output rather than noise.

COMPLETION FROM THE SERVER ITSELF
Start typing and Arkie runs find against the server you are connected to, then lists what came back with the help text the server returned. Tap one to send it. Nothing is hard-coded, so a server running mods offers its commands too.

KEEP THE COMMANDS YOU RETYPE
Long-press any command in the console to save it with a name that means something. It becomes a button in that server's tools, one tap from running again.

PLAYERS, WITHOUT THE STEAMIDS
The live roster with humans and bots counted separately. Kick anyone from the list, or ban them for an hour, a day, or for good.

CHANGE THE MAP BY TAPPING IT
Official maps and a vetted set of workshop maps, each with its own thumbnail, and the loaded one marked. One tap queues the change with a moment to cancel before it goes.

IT TELLS YOU WHEN IT DROPS
A ping every few seconds and an indicator that says whether the link is live, connecting or gone. Arkie picks the connection back up on its own when the server comes back.

NOTHING LEAVES YOUR PHONE
No account, no analytics, no telemetry, no backend. Servers and passwords are stored on the device, and the only machine Arkie connects to is the server whose address you typed. Arkie is open source under the MIT licence, so you can confirm that rather than take our word for it: github.com/elyon-labs/arkie

NOT SURE YET?
Add the demo server from the empty state. It runs inside the app and answers like a real one, so you can see the console, the map list and the roster before you have a server to point at.

WHAT YOU NEED
A Counter-Strike 2 server with rcon_password set, and a route to its RCON port from your phone. Arkie speaks the Source RCON protocol, so nothing has to be installed on the server. Source RCON is unencrypted, so across the open internet put the connection inside a VPN.

Arkie is also a desktop app for macOS, Windows and Linux, built from the same source.

Counter-Strike is a trademark of Valve Corporation. Arkie is not affiliated with or endorsed by Valve.
```

## Keywords

100 characters, comma separated, no spaces. Words already in the name and the subtitle are indexed
anyway, so none of them are repeated here.

```
counter-strike,srcds,source,admin,gameserver,dedicated,kick,ban,mapchange,scrim,remote,terminal,lan
```

`counter-strike` is somebody else's trademark, and a keyword that is one is grounds for a
rejection, descriptive or not. If review objects, drop it and use the 15 characters it frees:

```
srcds,source,admin,gameserver,dedicated,kick,ban,mapchange,scrim,remote,terminal,lan,match,config
```

## What's New

For the first release, where "what's new" is the app:

```
First release. Save your CS2 servers, keep a console on each one, change maps, and manage players from your phone.
```

## App Review Information

- **Sign-in required:** No.
- **Demo account:** Not applicable — Arkie has no account.

**Notes to the reviewer:**

```
Arkie is an RCON client. It connects to Counter-Strike 2 game servers the reviewer would have to run themselves, so the app ships with a demo server to review against.

On first launch, tap "Add a demo server" under the empty server list. It is answered inside the app rather than over the network, and it behaves like a real server: the console accepts commands and replies, the players tab lists a roster you can kick from, and the maps tab changes the loaded map. That exercises every screen without a Counter-Strike 2 server.

To add a real server instead: tap +, then enter a name, address, port and RCON password.

Arkie has no account, collects nothing, and connects to no service we run.
```

## Age rating

4+. Arkie shows no violence, no user-generated content feed, no web browser, no purchases and no
gambling. It administers a game server; it does not contain the game. Answer every questionnaire
item "None".

## App Privacy

**Data Not Collected.** Arkie has no SDKs, no analytics and no backend, which the
[privacy policy](https://arkie.elyon-labs.com/privacy) says in more detail. Saved servers,
passwords and saved commands are written to the device and go nowhere else.

## Export compliance

`ITSAppUsesNonExemptEncryption` is already `false` in `ios/Runner/Info.plist`, so App Store Connect
does not ask. Arkie uses no encryption: Source RCON is a plaintext protocol.

## Content rights

Arkie contains no third-party content, beyond map thumbnails of Counter-Strike 2's own maps shown
to identify the map being switched to.

## Screenshots

[`assets/store/screenshots`](../assets/store/screenshots), captured by
[`tool/capture_screenshots.dart`](../tool/capture_screenshots.dart) at **1206x2622**, for the
**iPhone 6.1"/6.3"** display set. One set is enough; App Store Connect scales it down for every
smaller iPhone itself.

A screenshot is only valid in the set it was sized for, and App Store Connect answers one from
another set with "File dimensions are invalid" rather than naming the set it wanted. What each set
takes, per Apple's [screenshot specifications][spec]:

| Set | Portrait sizes |
| --- | --- |
| 6.1"/6.3" | 1179x2556, **1206x2622** |
| 6.9" | 1260x2736, 1290x2796, 1320x2868 |

To move to the 6.9" set instead, change `target` at the top of the script to a simulator that
renders one of those natively — the alternatives are listed there — and run it again.

The files go up as bare RGB PNGs: no alpha, and no colour or density metadata. simctl writes RGBA,
and the `pHYs` ffmpeg replaces it with claims a horizontal resolution of zero, so the script keeps
only `IHDR`, `IDAT` and `IEND`.

[spec]: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/

Upload them in order; the first three are the ones shown in search results.

| File | What it shows |
| --- | --- |
| `01-console.png` | The console: commands sent, a full `status` dump back, the prompt at the foot. |
| `02-maps.png` | The map picker, thumbnails and all, with the loaded map marked. |
| `03-players.png` | The roster, humans and bots, with kick and ban on each row. |
| `04-saved.png` | Saved commands as buttons. |
| `05-servers.png` | The server list, including the demo server. |

The app targets iPhone only (`TARGETED_DEVICE_FAMILY = 1`), so no iPad set is required.

## Merchandising art

[`assets/store`](../assets/store), rendered by
[`tool/render_store_assets.dart`](../tool/render_store_assets.dart). Neither is part of the normal
submission; they are what Apple asks for when an app is nominated for featuring.

| File | Size | Use |
| --- | --- | --- |
| `product-page-header.png` | 3840x1646 (21:9) | Product page header. Apple draws the app name and the Get button over the lower band and crops the sides on narrow devices, so both are left empty. |
| `search-results.png` | 3840x2560 (3:2) | Search results. |

## Before submitting

- The marketing version is `0.1.0` in `pubspec.yaml`; a first App Store release should go out as
  `1.0.0`. `Mobile Deploy` in `elyon-labs/arkie-deployment` takes the version as an input.
- `storeListings` in `apps/web/src/lib/downloads.ts` shows "Coming soon to the App Store" until it
  is given an `href`. Give it the listing's URL and redeploy the site once the app is live.
