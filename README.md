# Hyprland Client Picker

Search open Hyprland clients and choose one to focus or fetch.

## Requirements

- Omarchy shell with third-party plugin support
- Hyprland and `hyprctl` on `PATH`
- Optional: `grim` on `PATH` for client thumbnails; application icons remain visible without it

## Install

Once this directory is published as the root of a public Git repository:

```sh
omarchy plugin add <git-repository-url> --enable
```

The plugin ID is `sjb.hyprland-client-picker`.

## Use

- Search by window title or application class.
- Enter focuses the selected client.
- Ctrl+Enter fetches the selected client.
- Escape closes the picker.

## Keybinding (Omarchy)

Add a binding to `~/.config/hypr/bindings.lua` using Omarchy's Lua `o.bind` helper:

```lua
o.bind("SUPER + SHIFT + W", "Hyprland client picker", "omarchy-shell shell summon sjb.hyprland-client-picker")
```

Replace the key combo with one you prefer. Omarchy reloads Hyprland config when saved; to apply or validate manually, run `hyprctl reload` and `hyprctl configerrors`.

## Development

Run the model checks with Node.js:

```sh
node HyprlandClientPickerModel.test.js
```

The marketplace requires a license file; add the chosen license before publishing.
