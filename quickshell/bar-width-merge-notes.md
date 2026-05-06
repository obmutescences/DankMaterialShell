# Bar Width Merge Notes

This fork adds a minimal fixed-width option for horizontal bars.

## Intent

- `barWidth: 0` keeps the current full-width behavior.
- `barWidth > 0` gives the top or bottom bar a fixed centered width.
- Left and right bars stay unchanged.
- Popouts and tray menus reuse the same width math through `getBarBounds()`.

## Touched Files

- `Common/SettingsData.qml`
- `Common/settings/SettingsSpec.js`
- `Common/settings/SettingsStore.js`
- `Modules/DankBar/DankBarWindow.qml`
- `Modules/Settings/DankBarTab.qml`

## Merge-Sensitive Areas

- `Modules/DankBar/DankBarWindow.qml`
  Horizontal bars now switch from full width to fixed width when `barConfig.barWidth > 0`.
  Positioning is centered with `WlrLayershell.margins.left`.

- `Common/SettingsData.qml`
  `getBarBounds()` now returns the same centered fixed width for top and bottom bars when `barWidth > 0`.

- `Common/settings/SettingsStore.js`
  Added `barConfigs[].barWidth` normalization and a version `12` migration.

- `Modules/Settings/DankBarTab.qml`
  Added a horizontal-bar-only width slider and ensured `createNewBar()` copies `barWidth`.

## Rebase Notes

- If upstream changes `DankBarWindow.qml` horizontal anchor logic, keep the `barWidth > 0` branch together with `implicitWidth` and `WlrLayershell.margins.left`.
- If upstream changes `getBarBounds()`, preserve the centered width override for top and bottom bars.
- If upstream changes `barConfigs` defaults or migrations, keep `barWidth` in both places.
