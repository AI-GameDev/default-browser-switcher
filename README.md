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

SetBrowser is not affiliated with, endorsed by, or sponsored by Apple, Google,
Dia, The Browser Company, or any browser vendor.

## License

SetBrowser is released under the MIT License. It is provided as-is, without
warranty of any kind. See [LICENSE](LICENSE).
