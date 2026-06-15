# Kanata with kanata-tray on macOS

This setup runs [kanata-tray](https://github.com/rszyma/kanata-tray) as a user LaunchAgent. The tray app shows a menu bar icon for starting, stopping, and switching kanata configs. Kanata itself runs via `kanata-root.sh`, which invokes it with `sudo` (required for keyboard capture on macOS).

## Prerequisites

Install both binaries:

```bash
brew install kanata kanata-tray
```

Run `./setup.sh` (or link manually) so `~/.config/kanata` points at this directory. `./setup.sh` can also install kanata-tray when prompted.

## Quick Start

```bash
cd config/kanata
chmod +x kanata-tray-service.sh kanata-root.sh
./kanata-tray-service.sh install
```

The install command will:

1. Remove the legacy system LaunchDaemon (`com.user.kanata`) if present
2. Install a passwordless sudo rule for the kanata binary
3. Install and start the `com.user.kanata-tray` LaunchAgent

## Managing the Service

```bash
./kanata-tray-service.sh status
./kanata-tray-service.sh restart
./kanata-tray-service.sh logs
./kanata-tray-service.sh stop
./kanata-tray-service.sh uninstall
```

Logs are written to `~/Library/Logs/kanata-tray/`.

## Configuration

| File                           | Purpose                                                  |
| ------------------------------ | -------------------------------------------------------- |
| `kanata-tray/kanata-tray.toml` | Tray presets, autorun, icons                             |
| `kanata.kbd`                   | Kanata keymap                                            |
| `kanata-root.sh`               | Wrapper that runs kanata with sudo                       |
| `com.user.kanata-tray.plist`   | LaunchAgent template (paths filled in by install script) |

After changing `kanata-tray.toml`, restart the tray or use the menu bar to reload.

## Notes

- The tray runs as your user (menu bar visibility). Only kanata runs as root.
- If you upgrade kanata via Homebrew, re-run `./kanata-tray-service.sh install` to refresh the sudoers hash.
- The LaunchAgent uses `/opt/homebrew/bin/kanata-tray` or whatever `which kanata-tray` returns — not a hardcoded Cellar path.
