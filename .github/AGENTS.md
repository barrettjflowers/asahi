# Repository Guide

## Purpose and environment

- This is the home-directory dotfiles repository for an M2 MacBook Air running Fedora Linux Asahi Remix with Hyprland and KDE/Wayland applications.
- The repository root is the user's home directory. Configuration is tracked in place under `~/.config`; there is no Stow, chezmoi, or deployment layer.
- `.gitignore` ignores everything by default and lists every tracked file by exact path, with no wildcards. A new file, even inside an already-tracked directory, stays ignored until its own `!/path` line is added.
- Read `.github/README.md` before changing desktop configuration. It describes the intended theme, applications, and major config areas.

## Editing conventions

- Preserve the existing visual language and the Apple Silicon/Asahi-specific settings.
- Prefer focused edits to hand-authored configuration. Do not normalize or clean unrelated application-generated files.
- Do not stage the entire repository blindly. Inspect `git status` and stage only intended paths. Most credential and volatile application-state paths under `.config` are intentionally ignored; add a file's line to the root `.gitignore` only when the user explicitly asks to track that file, and only after checking its contents. Never use `git add -f` or wildcard rules to get around it.
- The repo is public. Work-specific aliases go in the untracked `~/.zshrc.local` (sourced by `.zshrc`) and work scripts in `~/.local/bin/work/`; never commit them. Secrets and IDs (`TG_TOKEN`, `TG_CHAT_ID`) come from `~/.zshenv`, which is untracked.
- Many files contain absolute paths under `/home/barrettjflowers`, monitor name `eDP-1`, mount UUIDs, audio device IDs, or remote-host details. Treat these as machine-specific.

## Generated configuration

- `~/.config/colors/colors.sh` is the palette source of truth. Edit its five color values and run it rather than independently changing generated palette outputs.
- The color script generates `colors.css`, `colors.rasi`, `hyprland-colors.conf`, `~/.config/swaync/style.css`, and `~/.config/swaync/config.json`. It also rewrites the hex in the calendar `today` markup in `~/.config/waybar/config` with `SURFACE` (`BACKGROUND` lightened 10%), since Pango markup cannot read `@define-color`.
- The five palette values in `colors.sh` are taken from the kitty theme in `~/.config/kitty/current-theme.conf` (currently Base2Tone Cave Dark): `BACKGROUND` = `background`, `TEXT` = `foreground`, `INACTIVE` = `selection_background`, `URGENT` = `bell_border_color`; `ACCENT` is chosen by the user. When the kitty theme changes, update these values, run `colors.sh`, and regenerate the solid wallpaper (`~/Pictures/wallpapers/solid/solid-<BACKGROUND>-6000x4000.png`, referenced from `~/.config/hypr/hyprpaper.conf`).
- `~/.config/waybar/scripts/select.sh` replaces `~/.config/waybar/config` and `style.css` from files under `~/.config/waybar/themes`.
- `~/.config/waybar/config` is an array of two half-width bars, `left` and `right`, that meet at the screen centre so modules hug the hardware notch (2560x1664 at scale 1.6 = 1600 logical, so each bar has an 800px outer margin). The 124px notch padding lives in `style.css` (`window#waybar.left .modules-right`, `window#waybar.right .modules-left`). Only `left` reserves space; `right` is `"exclusive": false` with `"margin-top": -27`, which equals the left bar's top margin (6) minus its reserved height (33 = `height` 31 + `margin-top` 6 + `margin-bottom` -4). Changing either bar's `height` or margins requires recomputing that value, or the halves stack or misalign. Both bars need `"fixed-center": false`, or the side groups are capped at half the bar width and the window title is truncated. The `left` bar uses `"spacing": 0` with `margin-left` on each module in `style.css` (except `#window`, which has none and squared inner corners so it shares one background with `#workspaces`), and `hyprland/window` adds its `›` prefix via `rewrite`, where a second rule caps the class at 7 chars plus `… ` (jsoncpp sorts rewrite keys and every matching rule applies in turn, so the cap key must sort before the prefix rule `^(.+)$` and must not add the prefix itself), so with no focused window the module is empty and takes no gap; GTK3 ignores negative margins, so bar spacing cannot be cancelled in CSS; the `right` bar instead wraps `cpu`, `custom/memory` and `custom/weather` in `group/metrics` (no spacing inside a group), and the background sits on `#metrics`. `network` has no `rewrite`, so its SSID uses a 15-char cap via `"max-length": 18` (icon + space + 15 + `…`; GTK ellipsizes by width; the Propo font keeps text monospace but icons are wider than one cell, so the cap can cut a character or two early). GTK cannot put a space after its `…`, so `#network` instead always has one extra character (8px) of right padding in `style.css`.
- SwayNC files and selected Waybar files are rendered outputs; change their producer when the desired change should survive regeneration.

## System snapshots

- `~/.config/asahi` stores host snapshots refreshed by the user's crontab every 15 minutes.
- `crontab` mirrors `crontab -l`; `grub` mirrors `/etc/default/grub`; `fstab` mirrors `/etc/fstab`.
- `systemd` lists enabled system unit files. `packages` is a sorted inventory of installed RPM package names, versions, releases, and architectures.
- Snapshot files describe current state; they are not restoration scripts and should not be edited directly.
- To change snapshot jobs, edit `~/.config/asahi/crontab` and immediately install it with `crontab ~/.config/asahi/crontab`; otherwise the next snapshot may overwrite the edit.

## Systemd configuration

- User units and enablement links are under `~/.config/systemd/user`. They are local only and intentionally untracked; do not re-add them.
- Enablement symlinks under `*target.wants` may target local units, `/usr/lib/systemd/user`, or `/dev/null`; preserve symlinks when editing or copying.
- Sunshine is the only remote desktop service; WayVNC and noVNC were removed. Remote desktop units can expose network services. Do not change bind addresses, startup behavior, or enablement without explicit approval.
- After user-unit changes, verify with `systemd-analyze --user verify <unit>` where applicable, then run `systemctl --user daemon-reload` only when applying the change is intended.

## Sensitive and application-owned state

- Never print, summarize, or casually modify credential material under `~/.config/rclone`, `~/.config/sunshine/credentials`, `~/.config/pulse/cookie`, Go telemetry tokens, OBS service settings, or OBS WebSocket settings.
- Treat browser profiles, crash reports, recent-file histories, Aseprite sessions/logs, Audacity registries, `~/.config/dconf/user`, Go telemetry state, OBS logs/profiler data, and Neovim's pack lock as application-owned unless the task explicitly targets them.
- `~/.config/vivaldi-snapshot` is ignored local state and should remain untracked.
