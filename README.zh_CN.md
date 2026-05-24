# SPL Fix for OTA

KernelSU / Magisk 模块。将 `ro.build.version.security_patch` 修改为已下载
OTA 包的目标 SPL，使系统更新可以继续。

来自 `module.prop`：

> Action-button OTA SPL bypass. Click to fix, no boot impact.

## 兼容性

同时支持 KernelSU 和 Magisk，运行时自动检测 root 环境。

## 文件

| 文件            | 用途                                   |
|-----------------|----------------------------------------|
| `module.prop`   | 模块元数据                             |
| `action.sh`     | 操作按钮脚本 — 检测并修改 SPL          |
| `fix.sh`        | 便捷包装，供手动 `adb shell` / 终端调用|
| `uninstall.sh`  | 卸载时恢复原始 SPL 值                  |

## `action.sh` 工作流程

1. 从以下来源提取目标 SPL 日期（按顺序尝试）：
   - `/data/ota_package/metadata.pb`（扫描 `YYYY-MM-DD` 格式）
   - `logcat -s update_engine:E`（同上日期格式）
   - 完整 logcat，搜索 `Target build SPL <date>`
2. 若未找到 SPL，输出错误信息并退出。
3. 将找到的 SPL 与当前值比较。
4. 若不同，保存当前值并应用修改。

## 卸载

卸载脚本会恢复保存的原始 SPL 值。

## 许可证

[GPL-3.0-or-later](LICENSE) © 2026 MysticalDevil
