# dotfiles

个人 macOS/Linux Shell 与 Vim 配置。

## 安装约定

- 仓库可以放在任意目录；安装脚本会自动定位仓库。本文示例使用 `~/.dotfiles`。
- `.zshrc` 与 `.vimrc` 复制到 Home，不使用符号链接。
- 已有目标文件与仓库版本不同时，安装脚本先将原文件移动为带时间戳的备份，再复制新版本。
- `~/.zshrc.local` 保存机器私有配置；脚本只在它不存在时创建，永不覆盖。
- Oh My Zsh 和两个插件通过 Git 克隆；脚本不会执行下载得到的远程安装脚本。

## 前置条件

安装前需要：

- Git
- Zsh
- Vim
- 可以访问 GitHub

检查：

```bash
git --version
zsh --version
vim --version | head -n 1
```

## 首次安装

### 1. 克隆仓库

在完成 GitHub SSH 配置后执行：

```bash
git clone git@github.com:wangbowww/dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
```

如果仓库已经存在，不要再次克隆：

```bash
cd "$HOME/.dotfiles"
git status --short
```

### 2. 审阅并安装 Zsh 配置

```bash
less install-zsh.sh
less .zshrc
bash -n install-zsh.sh
zsh -n .zshrc
./install-zsh.sh
```

该脚本会安装或保留：

- Oh My Zsh
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `~/.zshrc`
- `~/.zshrc.local`

验证：

```bash
zsh -n "$HOME/.zshrc"
exec zsh
```

### 3. 审阅并安装 Vim 配置

```bash
cd "$HOME/.dotfiles"
less install-vim.sh
less .vimrc
bash -n install-vim.sh
vim -Nu .vimrc -n -es -c 'qall' </dev/null
./install-vim.sh
```

验证：

```bash
vim -Nu "$HOME/.vimrc"
```

### 4. 设置默认 Shell

确认新 Zsh 配置正常后再执行：

```bash
chsh -s "$(command -v zsh)"
```

重新登录后检查：

```bash
printf '%s\n' "$SHELL"
```

## 机器本地配置

```bash
chmod 600 "$HOME/.zshrc.local"
vim "$HOME/.zshrc.local"
```

适合放在这里的内容包括：

- uv 等工具的机器本地存储路径
- 代理变量
- CUDA 路径
- 私有环境变量
- 只适用于当前机器的 alias

代理配置格式示例：

```bash
export http_proxy=...
export https_proxy=...
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost"
export no_proxy="$NO_PROXY"
```

不要把真实代理地址、令牌或其他凭据提交到本仓库。

## 更新 dotfiles

先查看远端变化，再合并并重新运行安装脚本：

```bash
cd "$HOME/.dotfiles"
git fetch origin
git log --oneline HEAD..origin/master
git diff HEAD..origin/master
git merge --ff-only origin/master
./install-zsh.sh
./install-vim.sh
```

如果目标文件已经与仓库版本一致，脚本会直接跳过复制，不创建多余备份。

Oh My Zsh 已关闭自动更新。需要更新时单独审阅：

```bash
omz update
git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" pull --ff-only
git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" pull --ff-only
```

## 备份与恢复

覆盖不同的已有配置前，脚本会创建类似文件：

```text
~/.zshrc.backup.20260827-120000.12345
~/.vimrc.backup.20260827-120000.12345
```

恢复前先比较内容：

```bash
diff -u "$HOME/.zshrc" "$HOME/.zshrc.backup.ACTUAL_TIMESTAMP"
diff -u "$HOME/.vimrc" "$HOME/.vimrc.backup.ACTUAL_TIMESTAMP"
```

确认后再将选定的备份复制回对应目标文件。
