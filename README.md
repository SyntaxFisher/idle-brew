# Idle Brew

A tiny macOS menu bar app that keeps your Mac looking active by wiggling the mouse cursor 1px every 30 seconds. No Dock icon, no windows — just a coffee-cup icon in the menu bar.

## Install

Requires macOS 13+ and the Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/SyntaxFisher/idle-brew.git
cd idle-brew
make
```

This builds the app, installs it to `/Applications`, and launches it. On first launch macOS immediately asks for **Accessibility** permission (needed to move the cursor): click *Open System Settings* and enable **Idle Brew** under Privacy & Security → Accessibility.

## Usage

The menu bar coffee-cup icon is white while inactive and green while idling. While the Accessibility permission is missing it shows an orange `!` badge instead (idling can't work without it).

- **Left click** — toggles idling on/off.
- **Right click** (or control-click) — opens the menu:
  - **Start/Stop Idling**
  - **Launch at Login** — registers the app as a login item.
  - **Grant Accessibility…** — only shown while permission is missing; jumps to the right Settings pane.
  - **Quit**

If idling was on when the app quit, it resumes automatically on the next launch.

## Rebuilding

The app is ad-hoc signed, so after a **rebuild** (`make`) macOS may silently stop honoring the existing Accessibility grant even though it still shows as enabled. Fix: toggle Idle Brew off and on in Privacy & Security → Accessibility, or reset the permission and run `make` again:

```sh
tccutil reset Accessibility com.jona.idle-brew
make
```

Day-to-day use without rebuilds is unaffected. To uninstall, quit Idle Brew and delete it from `/Applications`.
