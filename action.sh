#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 MysticalDevil

# Auto-detect root environment
MODDIR=${0%/*}
SAVE_FILE="$MODDIR/original_spl"

if [ "$KSU" = "true" ]; then
    RESETPROP="/data/adb/ksu/bin/resetprop"
else
    RESETPROP="resetprop"
fi

# ── Source extraction ──
SRC=""
SPL=""

if [ -f /data/ota_package/metadata.pb ]; then
    SPL=$(strings /data/ota_package/metadata.pb | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    [ -n "$SPL" ] && SRC="OTA metadata"
fi

if [ -z "$SPL" ]; then
    SPL=$(logcat -d -s update_engine:E 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    [ -n "$SPL" ] && SRC="update_engine log"
fi

if [ -z "$SPL" ]; then
    SPL=$(logcat -d 2>/dev/null | sed -n 's/.*Target build SPL \([0-9-]*\).*/\1/p' | tail -1)
    [ -n "$SPL" ] && SRC="logcat fallback"
fi

# ── No SPL found ──
if [ -z "$SPL" ]; then
    echo ''
    echo '  SPL Fix for OTA'
    echo '  ──────────────'
    echo ''
    echo '  No OTA package detected.'
    echo ''
    echo '  Please download the system update first:'
    echo '    Settings > System > System Update > Download'
    echo ''
    echo '  Then tap this action again.'
    echo ''
    exit 1
fi

# ── Got SPL ──
CURRENT=$(getprop ro.build.version.security_patch)

echo ''
echo '  SPL Fix for OTA'
echo '  ──────────────'
echo ''
echo "  Source       $SRC"
echo "  Target SPL   $SPL"
echo "  Current SPL  $CURRENT"
echo ''

if [ "$SPL" = "$CURRENT" ]; then
    echo '  Already matching. No change needed.'
    echo ''
    exit 0
fi

# ── Save original SPL for uninstall (only once) ──
if [ ! -f "$SAVE_FILE" ]; then
    echo "$CURRENT" > "$SAVE_FILE"
fi

# ── Apply ──
$RESETPROP -n ro.build.version.security_patch "$SPL"
VERIFY=$(getprop ro.build.version.security_patch)

if [ "$VERIFY" = "$SPL" ]; then
    echo "  Patched      $CURRENT  -->  $SPL"
    echo ''
    echo '  The system update can now proceed.'
    echo '  KernelSU will auto-patch the new slot after OTA.'
    echo ''
    if [ "$KSU" = "true" ]; then
        ksud module config set override.description "Last fix: $CURRENT -> $SPL" 2>/dev/null || true
    fi
else
    echo '  Patch failed. Please try again.'
    echo ''
    exit 1
fi
