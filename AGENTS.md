# Agent instructions

- This is a single-file macOS menu bar app: all logic lives in `main.swift`, compiled directly with `swiftc` — no Xcode project, no Swift Package Manager. Keep it that way.
- `make` is the whole toolchain: it builds, bundles, ad-hoc signs, installs to `/Applications`, and launches. Keep it as the only public Make target.
- Bundle identity is `com.jona.idle-typing` / `IdleTyping.app`; UserDefaults and `tccutil` key off that identifier — don't change it casually.
- Cursor movement via CGEvent requires the Accessibility (TCC) grant; `CGEvent.post` silently no-ops without it. The app prompts at launch via `AXIsProcessTrustedWithOptions`.
- Use conventional commits.
