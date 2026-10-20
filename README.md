# Hyprland Client Picker

Search open Hyprland clients and choose one to focus or fetch.

## Requirements

- Omarchy shell with third-party plugin support
- Hyprland and `hyprctl` on `PATH`

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

## Development

Run the model checks with Node.js:

```sh
node HyprlandClientPickerModel.test.js
```

The marketplace requires a license file; add the chosen license before publishing.
