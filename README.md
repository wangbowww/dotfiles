# dotfiles
my personal dotfiles for linux/macos

```
git clone git@github.com:wangbowww/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
zsh
```
测试正常后，可以设置默认 Shell：
```
chsh -s "$(command -v zsh)"
```

optional settings
```
vim ~/.zshrc.local

export http_proxy="http://10.0.0.11:17122"
export https_proxy="http://10.0.0.11:17122"

export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost"
export no_proxy="$NO_PROXY"
```