# SPL Fix for OTA

[English](README.md)

`ro.build.version.security_patch` (SPL) 不匹配时，OTA 系统更新会拒绝安装。本模块将
SPL 临时修改为已下载 OTA 包中的目标值，使更新可以继续。

同时支持 **KernelSU** 和 **Magisk**，运行时自动检测 root 环境。

## 用户指南

### 什么时候需要

已 root 的设备在执行 OTA 增量更新时，系统会校验当前系统分区的 SPL 是否与更新包一致。
如果刷入了自定义内核 / 修补了 `init_boot` / 更换了 slot 等，SPL 可能与更新包期望不符，
导致 OTA 安装失败。

### 安装

1. 从 [Releases](../../releases) 下载 `spl_fix-v*.zip`
2. 打开 KernelSU / Magisk 管理器
3. 模块 → 从存储安装 → 选择 zip

无需重启。

### 使用

**操作按钮（推荐）：**

1. 先下载 OTA 更新包（设置 → 系统 → 系统更新 → 下载更新）
2. 在 KernelSU / Magisk 管理器中点击本模块的**操作按钮**
3. 看到 `Patched xxx -> xxx` 即成功，随后可开始系统更新

**手动执行：**

```sh
su -c sh /data/adb/modules/spl_fix/fix.sh
```

也可直接调用 `action.sh`，效果相同。

### 卸载

在 KernelSU / Magisk 管理器中移除模块，卸载脚本会自动恢复原始 SPL 值。

---

## 项目结构

### 文件

| 文件            | 说明                                    |
|-----------------|-----------------------------------------|
| `module.prop`   | 模块元数据                              |
| `action.sh`     | 主逻辑 — 检测目标 SPL 并修改系统属性    |
| `fix.sh`        | 便捷包装，供手动执行                    |
| `uninstall.sh`  | 卸载时恢复原始 SPL 值                   |
| `.gitignore`    | Git 忽略规则                            |
| `.ignore`       | fd/rg 忽略规则                          |

### `action.sh` 工作流程

**SPL 来源检测（按顺序）：**

1. `/data/ota_package/metadata.pb` — 扫描 `YYYY-MM-DD` 格式日期
2. `logcat -s update_engine:E` — 同上格式
3. 完整 logcat — 搜索 `Target build SPL <date>` 模式

**执行流程：**

```
检测目标 SPL → 对比当前值 → 保存原始值 → resetprop 修改 → 验证
```

- 如果 `--未找到 SPL--`：提示先下载 OTA 更新包
- 如果 `--已匹配--`：无需修改，直接退出
- 如果 `--不匹配--`：将当前值保存到 `original_spl`，然后修改属性
- `uninstall.sh` 从 `original_spl` 读取并恢复原始值，之后删除该文件

### 环境兼容

通过 `$KSU` 环境变量自动切换：

| 变量        | KernelSU                          | Magisk          |
|-------------|-----------------------------------|-----------------|
| `$KSU`      | `true`                            | 未设置          |
| resetprop   | `/data/adb/ksu/bin/resetprop`     | 内置 `resetprop`|
| 动态描述    | `ksud module config set`          | 不可用，跳过    |

## License

[GPL-3.0-or-later](LICENSE) © 2026 MysticalDevil
