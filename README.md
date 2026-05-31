# SetBrowser

Native macOS app and CLI for changing the default browser.

Current version: `0.1.0`

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
