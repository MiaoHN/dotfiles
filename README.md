# Dotfiles

Linux 下的配置文件

## 支持的配置

- nvim
- vim
- zsh
- conda
- tmux
- ranger

**注意**：如果使用 conda，请在 `.zshrc` 中将 `CONDA_PATH` 设为合适的值

## 一键安装

1. 全部安装：

```bash
git clone https://github.com/MiaoHN/dotfiles.git ~/.config/dotfiles && cd ~/.config/dotfiles && ./install.sh all
```

2. 只安装 `vim`：

```bash
git clone https://github.com/MiaoHN/dotfiles.git ~/.config/dotfiles && cd ~/.config/dotfiles && ./install.sh vim
```

:star: 原有的配置文件会被移到 `.backup` 中，如果原配置就是软连接则将其删除

