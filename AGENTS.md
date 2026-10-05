# Agent instructions

- This is a single-file macOS menu bar app: all logic lives in `main.swift`, compiled directly with `swiftc` — no Xcode project, no Swift Package Manager. Keep it that way.
- `make` is the whole toolchain: it builds, bundles, ad-hoc signs, installs to `/Applications`, and launches. Keep it as the only public Make target.
- Bundle identity is `com.jona.idle-brew` / `Idle Brew.app`; UserDefaults and `tccutil` key off the identifier — don't change it casually.
- Cursor movement via CGEvent requires the Accessibility (TCC) grant; `CGEvent.post` silently no-ops without it. The app prompts at launch via `AXIsProcessTrustedWithOptions`.
- Use conventional commits.
- Release with `make MODE=release`, then `make MODE=publish`; follow README.md. Bump both version strings/build number and add `releases/<version>.md` first. Release tooling lives in `scripts/build.py`; app logic stays in `main.swift`.
- For release preparation, publication, or recovery, use the repository skill at `.agents/skills/release-idle-brew/SKILL.md`.
- Release credentials are local (`~/.config/idle-brew-release/config.json` and Keychain), never in Git. Sparkle's EdDSA account is `com.jona.idle-brew`; preserve its key and publish the signed `appcast.xml` with every release. Consult Knowledge Base for the Apple/Wallpaper Motion release context.
