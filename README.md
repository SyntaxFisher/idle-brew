# Idle Brew

Keep your Mac looking active with a tiny app that lives in your menu bar. Idle Brew moves the pointer one pixel and back every 30 seconds while enabled.

[Download the latest release](https://github.com/SyntaxFisher/idle-brew/releases/latest)

## Features

- Start or stop with one click on the menu bar icon.
- See at a glance whether idling is active.
- Optionally launch when you sign in to your Mac.
- Resume idling on the next launch if it was enabled when you quit.
- Receive automatic updates, with the option to turn them off.

## Requirements

- macOS 13 or later, on Apple silicon or Intel.
- Accessibility permission, which lets Idle Brew move the pointer.

## Install

1. Download the DMG from the [latest release](https://github.com/SyntaxFisher/idle-brew/releases/latest).
2. Open it and drag **Idle Brew** to **Applications**.
3. Launch Idle Brew from Applications.
4. Allow it in **System Settings → Privacy & Security → Accessibility**.

The release app and installer are signed with Developer ID and notarized by Apple. Idle Brew appears in the menu bar; it has no main window or Dock icon.

## Use

**Click the coffee-cup icon** to start or stop idling. It is green while active and white while inactive. An orange warning means Accessibility permission is missing.

**Right-click or Control-click the icon** to open the menu. From there you can start or stop idling, enable **Launch at Login**, manage updates, or quit. If permission is missing, choose **Grant Accessibility…** to open the relevant settings.

If you revoke Accessibility permission, idling stops. After granting it again, click the icon to restart.

## Privacy and permissions

Idle Brew uses Accessibility access to move the pointer. Your preferences are stored on your Mac. Release builds contact GitHub to check for and download updates.

## Updates and uninstall

The app checks for updates hourly and downloads them automatically. Updates normally install when you quit; you may also be offered a restart. Use **Check for Updates…** to check immediately or turn off **Automatic Updates** in the menu.

Run Idle Brew from Applications so it can update itself.

To uninstall, turn off **Launch at Login** if enabled, quit Idle Brew, and delete it from Applications.

## Support

[Open an issue](https://github.com/SyntaxFisher/idle-brew/issues/new) with your macOS version, Mac model, app version, and what happened. For a pointer that does not move, check Accessibility permission first.

If you built the app yourself or switched from a local build to a release, see [Accessibility after rebuilding](docs/development.md#rebuilding).

## Development

See [build instructions](docs/development.md) and the [release guide](docs/releasing.md).
