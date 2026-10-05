# Developing Idle Brew

[Back to the product overview](../README.md)

## Build from source

Requires the Xcode Command Line Tools (`xcode-select --install`), Python 3, and internet access for the pinned Sparkle dependency.

```sh
git clone https://github.com/SyntaxFisher/idle-brew.git
cd idle-brew
make
```

This compiles `main.swift` directly with `swiftc`, bundles and ad-hoc signs the app, installs it to `/Applications`, and launches it. There is no Xcode project or Swift package. Local builds have the public updater disabled so a release does not overwrite development work. Use `make MODE=build` to build and verify without installing.

## Rebuilding

Local builds are ad-hoc signed, so after a **rebuild** (`make`) macOS may silently stop honoring the existing Accessibility grant even though it still shows as enabled. Switching from a local build to the signed release may also need a fresh grant. Fix: toggle Idle Brew off and on in Privacy & Security → Accessibility, or reset the permission and relaunch:

```sh
tccutil reset Accessibility com.jona.idle-brew
make
```

Day-to-day use without rebuilds is unaffected. To uninstall, quit Idle Brew and delete it from `/Applications`.
