# SPL Fix for OTA

KernelSU / Magisk module. Patches `ro.build.version.security_patch` to match the
target SPL of a downloaded OTA package, so the system update can proceed.

From `module.prop`:

> Action-button OTA SPL bypass. Click to fix, no boot impact.

## Compatibility

Supports both KernelSU and Magisk. Auto-detects the root environment at runtime.

## Files

| File           | Purpose                                              |
|----------------|------------------------------------------------------|
| `module.prop`  | Module metadata                                      |
| `action.sh`    | Action button script — detects and patches SPL       |
| `fix.sh`       | Convenience wrapper, for manual `adb shell` / terminal|
| `uninstall.sh` | Restores the original SPL value on module removal    |

## How `action.sh` Works

1. Extracts the target SPL date from (tried in order):
   - `/data/ota_package/metadata.pb` (strings scan for `YYYY-MM-DD`)
   - `logcat -s update_engine:E` (same date pattern)
   - Full logcat, looking for `Target build SPL <date>`
2. If no SPL is found, prints an error and exits.
3. Compares found SPL against current `ro.build.version.security_patch`.
4. If different, saves the current value and applies the patch.

## Uninstall

The `uninstall.sh` script restores the saved original SPL value.

## License

[GPL-3.0-or-later](LICENSE) © 2026 MysticalDevil
