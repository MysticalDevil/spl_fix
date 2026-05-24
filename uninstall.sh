#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 MysticalDevil

MODDIR=${0%/*}
SAVE_FILE="$MODDIR/original_spl"

if [ "$KSU" = "true" ]; then
    RESETPROP="/data/adb/ksu/bin/resetprop"
else
    RESETPROP="resetprop"
fi

if [ -f "$SAVE_FILE" ]; then
    ORIGINAL=$(cat "$SAVE_FILE")
    $RESETPROP -n ro.build.version.security_patch "$ORIGINAL" 2>/dev/null
    rm -f "$SAVE_FILE"
fi
