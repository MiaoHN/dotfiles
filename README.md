# Dotfiles

Linux 下的配置文件。

## 支持的配置

- `nvim`（使用 LazyVim）
- `vim`（无插件）
- `zsh`（使用 Zinit）
- `conda`
- `tmux`（无插件）
- `ranger`

> 如果使用 conda，请在 `/home/runner/work/dotfiles/dotfiles/zsh/.zshrc` 中将 `CONDA_PATH` 改成你的实际路径。

## 快速开始

### 1) 克隆仓库

```bash
git clone https://github.com/MiaoHN/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
```

### 2) 首次安装

```bash
./install.sh install all
```

也可以只安装指定组件：

```bash
./install.sh install zsh nvim
```

兼容旧用法（等价于 `install`）：

```bash
./install.sh all
./install.sh vim
```

## 日常使用

### 查看支持的组件和可回滚版本

```bash
./install.sh list
```

### 查看当前状态

```bash
./install.sh status all
./install.sh status zsh
```

状态说明：

- `managed-link`：已正确链接到本仓库
- `symlink->...`：是软链接，但指向其它位置
- `file` / `directory`：普通文件或目录（未托管）
- `missing`：目标不存在

### 更新配置（拉取仓库并应用）

```bash
./install.sh update all
./install.sh update zsh nvim
```

更新流程：

1. 尝试 `git pull --ff-only` 同步仓库
2. 对冲突目标给出提示（可确认覆盖）
3. 生成时间戳快照备份并重新链接
4. 失败时尝试回滚到更新前快照

## 预演 / 确认 / 强制

### 预演（不真正改动文件）

```bash
./install.sh install all --dry-run
./install.sh update zsh --dry-run
./install.sh rollback --version <snapshot-id> --dry-run
```

### 非交互确认

```bash
./install.sh install all --yes
./install.sh update all --yes
```

### 强制覆盖冲突目标

```bash
./install.sh install zsh --force --yes
```

## 回滚

### 回滚到最近一次快照

```bash
./install.sh rollback all
```

### 回滚到指定版本

```bash
./install.sh rollback --version 20260919-120000-install all
./install.sh rollback --version 20260919-120000-install zsh
```

回滚支持按组件恢复，也支持整体恢复。

## 命令总览

```bash
./install.sh help
```

主要命令：

- `install`
- `update`
- `rollback`
- `status`
- `list`
- `help`

## 故障排查

### 1) 提示权限不足

检查目标目录权限（如 `~/.config`），确保当前用户可写。

### 2) 目标目录不存在

脚本会自动创建父目录；如果仍失败，检查 `$HOME` 是否正确。

### 3) 软链接冲突

用 `status` 查看冲突目标，按需选择：

- 手动备份后再安装
- 使用交互确认覆盖
- 使用 `--force --yes` 直接覆盖

### 4) 依赖缺失

- `update` 依赖 `git`
- shell 环境依赖 `zsh`、`starship`、`conda`、`nvm` 等由你本地环境决定

### 5) 回滚版本不存在

先执行 `./install.sh list` 查看可用快照 ID，再指定 `--version`。
