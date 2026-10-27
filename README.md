# Hyprland Client Picker

Search open Hyprland clients and choose one to focus, move, or fetch.

## Requirements

- Omarchy shell with third-party plugin support
- Hyprland and `hyprctl` on `PATH`
- Quickshell's Hyprland and Wayland screencopy support for live client previews; application icons remain visible when a window cannot be captured

## Install

Once this directory is published as the root of a public Git repository:

```sh
omarchy plugin add <git-repository-url> --enable
```

The plugin ID is `sjb.hyprland-client-picker`.

## Hyprland Lua helpers

The picker calls `sjb_client_picker.focus_or_launch`, `.fetch_or_launch`, and `.move_to_monitor` via `hyprctl eval`. Add this to `~/.config/hypr/hyprland.lua` **after** loading Omarchy's defaults and your own modules:

```lua
if not (sjb_client_picker and sjb_client_picker.focus_or_launch
    and sjb_client_picker.fetch_or_launch and sjb_client_picker.move_to_monitor) then
    dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/sjb.hyprland-client-picker/client-picker.lua")
end
```

The bundled helpers fill only missing entries in their own namespace; existing global functions (including those from `sjb.client-picker` in sjb's dotfiles) remain untouched. Run `hyprctl reload` and `hyprctl configerrors` after editing the config. The plugin does not modify your Hyprland config on install.

## Use

- Fuzzy-search window titles and application classes; letters can be non-adjacent, spaces split query words, and word-start matches rank higher.
- Enter focuses it in place.
- Ctrl+Enter moves it to the same workspace slot on the active monitor.
- Alt+Enter fetches the selected client onto the current workspace.
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
lua client-picker.test.lua
```

The marketplace requires a license file; add the chosen license before publishing.
