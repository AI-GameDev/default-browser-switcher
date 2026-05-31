# SetBrowser

Native macOS app and CLI for changing the default browser.

Current version: `0.1.1`

## Requirements

- macOS 26+

## What It Does

SetBrowser only changes the default macOS browser for web links. The app and
CLI discover compatible browsers installed in `/Applications` and
`~/Applications`, then ask macOS to update the default application for `http`
and `https` links.

Changing the default browser may show a macOS confirmation dialog. You need to
approve that dialog for the change to take effect.

## Privacy

SetBrowser is a local app and CLI. It does not collect, store, transmit, or sell
personal information. It does not include telemetry or analytics, and it does
not read or transmit browsing history, opened URLs, account information,
cookies, credentials, or browser data.

See [PRIVACY.md](PRIVACY.md) for details.

## Build

```sh
swift build
```

## CLI

```sh
swift run setbrowser list
swift run setbrowser chrome
swift run setbrowser 1
```

## App

Run the SwiftUI app from SwiftPM:

```sh
swift run SetBrowserApp
```

Build a local `.app` bundle:

```sh
./scripts/build-app-bundle.sh
open dist/SetBrowser.app
```

The app bundle uses `Assets/AppIcon/setbrowser-icon.png` to generate
`SetBrowser.icns` during bundling.

Open `SetBrowser > Settings...` to enable alerts only for real failures or
quit the app automatically after a successful browser change.

## Install CLI

```sh
./scripts/install-cli.sh
```

Set `PREFIX` to install elsewhere:

```sh
PREFIX="$HOME/.local/bin" ./scripts/install-cli.sh
```

## Release

Build release zip files for the app and CLI:

```sh
./scripts/build-release.sh
```

Release artifacts are written to `dist/release/<version>/`.

## Distribution Notes

Release builds are not Developer ID signed or notarized yet. macOS Gatekeeper
may warn on first launch when the app is downloaded from GitHub.

Only open release builds if you downloaded them from this repository and trust
the artifact.

To open the app release:

1. Unzip `SetBrowser-<version>-macOS-app.zip`.
2. Move `SetBrowser.app` to `/Applications`.
3. Try opening `SetBrowser.app` once.
4. If macOS blocks it, open `System Settings > Privacy & Security`.
5. Find the SetBrowser warning and choose `Open Anyway`.

If macOS says `SetBrowser.app` is damaged and must be moved to the Trash, the
downloaded app may still have a quarantine attribute. If you trust the artifact,
remove the quarantine attribute for this app only:

```sh
xattr -dr com.apple.quarantine /Applications/SetBrowser.app
open /Applications/SetBrowser.app
```

Do not disable Gatekeeper globally.

For the CLI release, unzip `setbrowser-<version>-macOS-cli.zip` and install the
binary manually:

```sh
cd setbrowser-cli-<version>
cp setbrowser /usr/local/bin/
```

If macOS blocks the downloaded CLI binary because it is unsigned, prefer
building the CLI from source:

```sh
swift build -c release --product setbrowser
```

If you still want to run the downloaded CLI binary directly, remove the
quarantine attribute for that binary only:

```sh
xattr -d com.apple.quarantine ./setbrowser
./setbrowser list
```

SetBrowser is not affiliated with, endorsed by, or sponsored by Apple, Google,
Dia, The Browser Company, or any browser vendor.

## License

SetBrowser is released under the MIT License. It is provided as-is, without
warranty of any kind. See [LICENSE](LICENSE).
