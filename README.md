# idle-typing

Keeps your Mac awake/active by wiggling the mouse one pixel every 30 seconds.

## Setup

On a fresh machine, just run the launcher once:

```sh
./idle
```

The first run sets up everything: it creates a virtualenv in `.venv/`,
installs all dependencies, and symlinks `idle` onto your `PATH` (into
`/opt/homebrew/bin` or `/usr/local/bin`) so you can call it from anywhere.
`./idle install` re-creates the symlink if you ever need to.

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
