# Chezmoi 配置布局

本仓库使用 `home/` 作为 chezmoi source root。配置按“稳定源、平台入口、外部仓库、运行状态”分层。

## 稳定源

- `~/.config/rime`：三端共享的 Rime 配置源。
- `~/.config/mpv`：mpv 配置源；Windows Scoop 只创建入口链接。
- `~/.config/nvim`：Neovim 配置源；Windows 通过 `XDG_CONFIG_HOME` 使用。
- `~/.config/powershell/Profile.ps1`：Windows PowerShell 与 PowerShell 7 的共同配置源。
- `~/.config/windows-terminal/settings.json`：Windows Terminal 的稳定设置源。

Windows 的一次性环境脚本会设置 `XDG_CONFIG_HOME`、`XDG_DATA_HOME` 和 `XDG_CACHE_HOME`，使支持 XDG 的 Scoop 应用直接复用上述目录。

## 平台入口

| 配置 | Windows | macOS | Linux |
| --- | --- | --- | --- |
| Rime | `%APPDATA%/Rime` | `~/Library/Rime` | `~/.local/share/fcitx5/rime` |
| PowerShell | 两代 PowerShell profile | 暂无入口 | 暂无入口 |
| mpv | Scoop `portable_config` | 直接使用 XDG | 直接使用 XDG |
| Windows Terminal | Scoop persist 链接 | 不部署 | 不部署 |

平台入口都指向 `~/.config` 中的稳定源，不复制配置正文。

## 外部仓库

`~/.emacs.d` 由 `.chezmoiexternal.toml` 从 `git@github.com:Pilrymage/.emacs.d.git` 获取，主仓库不再复制其内容。

## 凭据

仓库不保存应用密钥。Navidrome 模板从以下环境变量渲染：

- `ND_LASTFM_APIKEY`
- `ND_LASTFM_SECRET`
- `ND_SPOTIFY_ID`
- `ND_SPOTIFY_SECRET`

`PTPIMG_API_KEY` 同样只应存在于用户环境或密码管理器中；PowerShell profile 不再写入它。

## 本机盘点后的纳入范围

本次额外纳入：

- `.wslconfig`
- XDG Git attributes/ignore
- Windows Terminal settings

暂不纳入：

- `.gitconfig`：含固定代理、拼写错误段名和项目虚拟环境绝对路径，需先单独整理。
- VS Code settings：含 Windows、Linux、macOS 的绝对 Neovim 路径，应在后续模板化。
- Scoop `config.json`：含 `last_update` 运行状态。
- Clash、浏览器、Obsidian、qBittorrent：可能含订阅、账户、历史或其他运行数据。
- Podman machine、lazygit state、tealdeer cache：属于可再生状态。

新增配置前先运行秘密扫描，并优先只添加稳定设置文件，不对整个应用数据目录执行 `chezmoi add` 或 `chezmoi re-add`。
