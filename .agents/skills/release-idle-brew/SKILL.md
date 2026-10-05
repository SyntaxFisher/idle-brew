---
name: release-idle-brew
description: "Prepare, verify, publish, or troubleshoot Idle Brew's signed and notarized macOS DMG releases and Sparkle update feed on GitHub. Use for Idle Brew release work in this repository, not other apps or App Store submission."
---

# Release Idle Brew

Use the existing `make` workflow from the repository root. Read [AGENTS.md](../../../AGENTS.md), the [Releasing section of README.md](../../../README.md#releasing), and the current [release script](../../../scripts/build.py) before changing the workflow. The script is the source of truth for supported options; do not create a second release implementation in this skill.

## Scope and identity

- A request to prepare, inspect, or document a release does not authorize publication. A request to release or publish does; carry the authorized work through verification without adding a redundant confirmation step.
- Public repository: `SyntaxFisher/idle-brew`. App: `Idle Brew.app`; executable: `IdleBrew`; bundle ID: `com.jona.idle-brew`. Preserve these identities and the signing team across updates.
- Keep app logic in `main.swift`, compile directly with `swiftc`, and retain one public Make target. `MODE` selects operations; there is no Xcode project or Swift Package Manager configuration.
- `make` without a mode installs and launches an ad-hoc development build with automatic updates disabled. Use `make MODE=build` for build verification without installation. To test the public install flow, use the released DMG.
- This is GitHub distribution using Developer ID and notarization, not Mac App Store submission. Wallpaper Motion's separate release script is a reference for the account setup, not the tool to run for this app.

## Local signing setup

Check existing setup before asking for credentials: `gh auth status`, `security find-identity -v -p codesigning`, and `xcrun --find notarytool`. The release needs full Xcode, Python 3, GitHub CLI access to the repository, and the certificate's private key in the login Keychain.

The established Developer ID identity is `Developer ID Application: Jona Bihl (94DW6CHJD7)`. Confirm its current validity. `~/.config/idle-brew-release/config.json` (permissions `0600`) contains `signing.identity` and `apple.key_id`, `apple.issuer_id`, and `apple.key_path`. It references the same team API key used by `~/.config/wallpaper-motion-release/config.json`. Resolve the key from the local configuration; do not embed private-key contents or tokens in this repository, tool output, release assets, or Knowledge Base. See README for `SIGN_IDENTITY`, `NOTARY_CONFIG`, and `NOTARY_PROFILE` alternatives.

Sparkle's EdDSA private key is in the login Keychain under account `com.jona.idle-brew`; `SUPublicEDKey` in `Info.plist` is its public counterpart. Reuse the existing key. Missing access is not a reason to generate a replacement. Consult README for secure backup/import and plan any key rotation separately.

If a signing command pauses on a macOS Keychain prompt for `generate_appcast` or `sign_update`, ask the user to approve the actual system prompt and keep the command pending. Computer Use may block SecurityAgent; explain that specific limitation instead of trying another route around it. An approval for one tool or invocation may not cover another prompt.

For account history, search Knowledge Base for “Apple Developer account and macOS release setup”, “Idle Brew”, or “Wallpaper Motion release procedure”. Saved history is context; current configuration and verification determine readiness.

## Prepare and verify

1. Inspect the working tree, fetch remote changes, and inspect published releases. Preserve unrelated changes. Choose the next three-part `CFBundleShortVersionString` and strictly increasing integer `CFBundleVersion`; compare against the latest published feed. Never reuse a public version.
2. Update `Info.plist` and write concise user-facing notes in `releases/<version>.md`. Run `make MODE=build` and check the diff. Commit the finished source using a conventional commit, then push to `origin/main`. The release requires a clean tree.
3. Run `make MODE=release`. It checks the Sparkle key, builds arm64 and x86_64, signs nested components and the app with Hardened Runtime and timestamps, notarizes/staples the app, then packages, signs, notarizes, and staples the DMG. It verifies Gatekeeper and creates/verifies an EdDSA-signed appcast.
4. Inspect `build/releases/<version>/manifest.json` and both notarization results; both must report `Accepted`. The manifest must name the intended source commit and exact artifact hashes. Mount the DMG read-only to check the app and `/Applications` link; validate the packaged app's signature, staple, and architectures. Unmount afterward.

Useful checks on the actual packaged app:

```sh
codesign --verify --deep --strict "/path/to/Idle Brew.app"
xcrun stapler validate "/path/to/Idle Brew.app"
spctl --assess --type execute --verbose=2 "/path/to/Idle Brew.app"
lipo "/path/to/Idle Brew.app/Contents/MacOS/IdleBrew" -verify_arch arm64 x86_64
```

Keep source and artifacts unchanged between preparation and publication. Even a documentation commit changes the manifest's expected HEAD. If a concurrent source change must enter the release, reconcile it and rebuild the candidate; do not edit the manifest to pretend the old binary came from the new commit.

## Publish and verify the public result

When publication is in scope, run `make MODE=publish`. This uses the existing verified artifacts, requires the manifest commit to equal HEAD and `origin/main`, creates/pushes the annotated version tag, uploads to a draft, downloads and compares asset hashes, and then publishes it as Latest. There is no supported draft-only or dry-run publish mode; stop before this command for preparation-only requests.

The public release must contain:

- `Idle-Brew-<version>-macOS-universal.dmg`
- `appcast.xml`
- `SHA256SUMS`

Verify the release is public and stable using `gh release view`, and fetch the public [latest appcast](https://github.com/SyntaxFisher/idle-brew/releases/latest/download/appcast.xml) to compare it with the verified local feed. Keep earlier release assets available. Never edit a signed feed afterward or replace an already-public version's assets.

When testing updates, distinguish signature/feed validation, update discovery, and an actual download/install/relaunch. A read-only Sparkle probe from an isolated older bundle checks discovery without installing. A complete update test requires an older installed release and a newer published candidate. Report only the stages actually verified; do not modify the user's installed app just to manufacture a test unless installation/testing is authorized.

Release apps check hourly while running and online, download automatically, and normally install on quit; Sparkle can offer a restart if the app stays running. The menu exposes manual checks and an automatic-update toggle. A pre-Sparkle/ad-hoc installation needs a one-time DMG installation. macOS 13+ is required; first use needs Accessibility permission, which can need reapproval when switching from ad-hoc to Developer ID signing.

## Recover and record

- A failed preparation leaves its version directory for diagnosis. Preserve it, inspect notarization output/logs and the current Apple submission status, then move the failed directory aside before rebuilding. Do not resubmit repeatedly when the prior submission's outcome is still unknown.
- An interrupted publication can leave a tag/draft or may already be public. Inspect remote state first. Rerun `make MODE=publish` only when the source, manifest, tag, and unpublished candidate still match. Do not force-move tags or overwrite public releases to bypass a mismatch.
- Sparkle is pinned with its distribution SHA-256 in `scripts/build.py`. Update version and checksum together from the official release, and validate the new dependency before shipping.
- After completion, update the existing Idle Brew Knowledge Base memory with version/build, source commit, release URL, verification results, and whether the app was installed or removed. Link this skill as the repository procedure; keep secrets out. Describe remaining user action, such as a Keychain prompt or Accessibility grant, only when it actually applies.
