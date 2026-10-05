# Idle Brew

A tiny macOS menu bar app that keeps your Mac looking active by wiggling the mouse cursor 1px every 30 seconds. No Dock icon, no windows — just a coffee-cup icon in the menu bar.

## Install

Requires macOS 13 or later, on Apple silicon or Intel.

1. Download the DMG from the [latest release](https://github.com/SyntaxFisher/idle-brew/releases/latest).
2. Open it and drag **Idle Brew** to **Applications**.
3. Launch Idle Brew from Applications and allow it in **System Settings → Privacy & Security → Accessibility**.

The release app and DMG are Developer ID signed, notarized by Apple, and stapled. The installed app checks GitHub for updates hourly and downloads updates automatically. Updates normally install when the app quits; Sparkle can prompt to restart if the app stays open. Right-click the menu bar icon to check immediately or turn off automatic updates. Run the app from Applications, since it cannot update itself inside the read-only DMG.

## Build from source

Requires the Xcode Command Line Tools (`xcode-select --install`), Python 3, and internet access for the pinned Sparkle dependency.

```sh
git clone https://github.com/SyntaxFisher/idle-brew.git
cd idle-brew
make
```

This compiles `main.swift` directly with `swiftc`, bundles and ad-hoc signs the app, installs it to `/Applications`, and launches it. There is no Xcode project or Swift package. Local builds have the public updater disabled so a release does not overwrite development work. Use `make MODE=build` to build and verify without installing.

## Usage

The menu bar coffee-cup icon is white while inactive and green while idling. While the Accessibility permission is missing it shows an orange `!` badge instead (idling can't work without it).

- **Left click** — toggles idling on/off.
- **Right click** (or control-click) — opens the menu:
  - **Start/Stop Idling**
  - **Launch at Login** — registers the app as a login item.
  - **Grant Accessibility…** — only shown while permission is missing; jumps to the right Settings pane.
  - **Check for Updates…** — checks for a new GitHub release (release builds).
  - **Automatic Updates** — enables or disables automatic checking and installation (release builds).
  - **Quit**

If idling was on when the app quit, it resumes automatically on the next launch.

## Rebuilding

Local builds are ad-hoc signed, so after a **rebuild** (`make`) macOS may silently stop honoring the existing Accessibility grant even though it still shows as enabled. Switching from a local build to the signed release may also need a fresh grant. Fix: toggle Idle Brew off and on in Privacy & Security → Accessibility, or reset the permission and relaunch:

```sh
tccutil reset Accessibility com.jona.idle-brew
make
```

Day-to-day use without rebuilds is unaffected. To uninstall, quit Idle Brew and delete it from `/Applications`.

## Releasing

Agents can use the repository's [release-idle-brew skill](.agents/skills/release-idle-brew/SKILL.md) for preparation, verification, publication, and recovery.

Releases are built on a Mac using the signing certificate in its Keychain and Apple's notarization API. No signing secrets are uploaded to GitHub. Full Xcode (for `notarytool` and `stapler`), Python 3, and authenticated [GitHub CLI](https://cli.github.com/) access to this repository are required.

### One-time setup

Install a **Developer ID Application** certificate and its private key in the login Keychain. Check it with `security find-identity -v -p codesigning`.

Create `~/.config/idle-brew-release/config.json` with permissions `0600`:

```json
{
  "apple": {
    "key_id": "YOUR_APP_STORE_CONNECT_API_KEY_ID",
    "issuer_id": "YOUR_ISSUER_ID",
    "key_path": "/absolute/private/path/AuthKey_KEYID.p8"
  },
  "signing": {
    "identity": "Developer ID Application: Your Name (TEAM_ID)"
  }
}
```

The API key must support notarization. The same team API configuration used for another app can be reused via `NOTARY_CONFIG=/path/to/config.json`; supply `SIGN_IDENTITY` if it does not include `signing.identity`. Alternatively use `NOTARY_PROFILE` for credentials saved by `xcrun notarytool store-credentials`, together with `SIGN_IDENTITY`.

Sparkle's update signing key is stored in the login Keychain under account `com.jona.idle-brew`. Its public key is committed in `Info.plist`. Back up the private key securely using Sparkle's `generate_keys --account com.jona.idle-brew -x /private/backup/path`, and import it on another release Mac with `-f`. Never create a replacement key casually, commit it, or put it in release assets. Changing this key or the Apple signing team requires a planned migration.

### Each release

1. Increase `CFBundleShortVersionString` (three parts, e.g. `1.0.1`) and `CFBundleVersion` (strictly increasing integer) in `Info.plist`.
2. Write user-facing notes in `releases/<version>.md`.
3. Run `make MODE=build`, review the change, commit with a conventional commit, and push to `origin/main`.
4. Run `make MODE=release`. It builds both architectures, signs the app and Sparkle helpers with Hardened Runtime and timestamps, notarizes and staples the app and DMG, checks Gatekeeper, and generates and verifies an EdDSA-signed appcast.
5. Review `build/releases/<version>/` and test the app from the DMG. Run `make MODE=publish` to tag the exact source commit, upload the DMG, `appcast.xml`, and `SHA256SUMS` to a draft GitHub release, download and compare their bytes, then publish it as latest.

`make` remains the only public Make target; `MODE` selects the operation. Publication uses the already verified artifacts and refuses changed source or artifacts and existing public versions. Failed builds stay on disk for diagnosis; move their version directory aside before rebuilding. Notarization results, the source manifest, and the app bundle are retained locally, while only the DMG, update feed, and checksums are uploaded.

Every release must include its signed `appcast.xml`, because installed apps use GitHub's `releases/latest/download/appcast.xml`. Keep earlier release assets available for feed history. Do not manually edit the signed feed after generating it. A plain GitHub release without these assets is not an update.

The build pins [Sparkle](https://sparkle-project.org/documentation/) 2.10.0 and verifies its distribution SHA-256 before extraction. Update its version and checksum together in `scripts/build.py`. Sparkle's license is included in the app bundle. Apple's [notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow) describes the signing and ticket requirements.

The DMG uses a plain grey background, a drag instruction, and an arrow between Idle Brew and Applications. `scripts/dmg-background.swift` draws the artwork at standard and Retina resolutions; it is bundled inside the app before signing so no loose image appears in the installer. `scripts/dmg-settings.py` and `scripts/dmg-layout.py` set the Finder layout. Release packaging installs the hash-pinned tools in `scripts/dmg-requirements.txt` into an isolated environment under `build/dependencies/`.
