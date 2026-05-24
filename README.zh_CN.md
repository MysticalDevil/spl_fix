# SPL Fix for OTA

Patches `ro.build.version.security_patch` to match the pending OTA package so the
system update can proceed. Works with both **KernelSU** and **Magisk**.

## User Guide

### When You Need This

Rooted devices running incremental OTA updates may fail verification if the
current SPL doesn't match the update payload. Common causes: custom kernels,
patched `init_boot`, slot switches, or factory images with different patch
levels.

### Installation

1. Download `spl_fix-v*.zip` from [Releases](../../releases)
2. Open KernelSU / Magisk Manager
3. Modules → Install from storage → select the zip

No reboot required.

### Usage

**Action button (recommended):**

1. Download the OTA update first (Settings → System → System Update → Download)
2. Tap the module's **action button** in KSU / Magisk Manager
3. When you see `Patched xxx -> xxx`, proceed with the system update

**Manual:**

```sh
su -c sh /data/adb/modules/spl_fix/fix.sh
```

`action.sh` works the same way.

### Uninstall

Remove the module from the manager. The uninstall script restores the original
SPL.

---

## Project Structure

### Files

| File            | Description                            |
|-----------------|----------------------------------------|
| `module.prop`   | Module metadata                        |
| `action.sh`     | Main logic — detect and patch SPL      |
| `fix.sh`        | Convenience wrapper for manual invoke  |
| `uninstall.sh`  | Restores original SPL on removal       |
| `.gitignore`    | Git ignore rules                       |
| `.ignore`       | fd/rg ignore rules                     |

### How `action.sh` Works

**SPL detection sources (tried in order):**

1. `/data/ota_package/metadata.pb` — strings scan for `YYYY-MM-DD`
2. `logcat -s update_engine:E` — same pattern
3. Full logcat — `Target build SPL <date>` pattern

**Flow:**

```
Detect target SPL → Compare with current → Save original → resetprop → Verify
```

- `--no SPL found--`: prompts user to download the OTA first
- `--already matching--`: exits with no changes
- `--mismatch--`: saves current value to `original_spl`, then patches
- `uninstall.sh` restores from `original_spl` and removes the file

### Environment Detection

Auto-switches based on `$KSU`:

| Variable     | KernelSU                          | Magisk            |
|-------------|-----------------------------------|-------------------|
| `$KSU`      | `true`                            | unset             |
| resetprop   | `/data/adb/ksu/bin/resetprop`     | built-in `resetprop`|
| description | `ksud module config set`          | unavailable, skip |

## License

[GPL-3.0-or-later](LICENSE) © 2026 MysticalDevil
