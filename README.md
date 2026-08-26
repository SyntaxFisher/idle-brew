# idle-typing

Keeps your Mac awake/active by wiggling the mouse one pixel every 30 seconds.

## Setup

On a fresh machine, just run the launcher — it creates a virtualenv in
`.venv/` and installs all dependencies automatically on first run:

```sh
./idle
```

To make it available everywhere, install it onto your `PATH` (symlinks into
`/opt/homebrew/bin` or `/usr/local/bin`):

```sh
./idle install
```

## Usage

```sh
idle          # run indefinitely (Ctrl+C to stop)
idle 25       # run for 25 minutes
```

## Notes

- Requires `python3` (`brew install python3` if missing).
- The first mouse wiggle will prompt macOS for Accessibility permission
  (System Settings → Privacy & Security → Accessibility); grant it to your
  terminal app.
