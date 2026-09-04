# AutoBuildFriendlyWrt

简体中文 | [English](README_en.md)

通过 GitHub Actions 云端编译 [FriendlyWrt](https://github.com/friendlyarm/friendlywrt) 固件：在网页上点选机型、版本，按需增删软件包，得到一个**更纯净**的 FriendlyWrt 系统。

- 流水线基于 [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt)（FriendlyElec 官方两段式编译方案：先编译 rootfs，再按 CPU 编译内核/uboot 并打包镜像）
- 交互方式参考 [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder)：无需改代码，网页填参数即可
- 与官方预编译固件相比，可自由**剔除官方预装的大量软件**、**按需追加插件**、**修改管理后台 IP** 等

触发方式三选一：**🌐 GitHub Pages 网页点选（推荐，见下文）** / 🛠️ Actions 页面手动运行 / ⭐ 所有者点 Star。

## 支持的设备

| 主控 (CPU) | 代表机型 | 镜像名 |
| --- | --- | --- |
| rk3328 | NanoPi R2S / R2C | R2S-R2C-Series |
| rk3528 | NanoPi R28S / Zero2 / NEO3-Plus | R28S-Zero2-NEO3Plus-Series |
| rk3399 | NanoPi R4S / R4SE、NanoPC-T4 | R4S-Series |
| rk3566 | NanoPi R3S | R3S-Series |
| rk3568 | NanoPi R5S / R5C | R5S-R5C-Series |
| rk3576 | NanoPi R76S / M5 | M5-R76S-Series |
| rk3588 | NanoPi R6S / R6C、NanoPC-T6 / M6 | T6-R6S-R6C-M6-Series |

## 🌐 方式一：GitHub Pages 网页触发（推荐）

本仓库提供了一个部署在 GitHub Pages 上的**纯静态网页控制台**，不用进 Actions 页面翻参数，点选即可触发编译：

**👉 [https://feamcoco.github.io/AutoBuildFriendlyWrt/](https://feamcoco.github.io/AutoBuildFriendlyWrt/)**

页面功能：

- 点选机型 / 版本 / 是否集成 Docker / 管理后台 IP
- **勾选剔除官方预装插件**（整组剔除，列表实时读取 [scripts/package_groups.txt](scripts/package_groups.txt)）
- **勾选追加知名插件**（HomeProxy、ZeroTier、Tailscale、WireGuard、FRP、AdGuard Home 等，均为官方源码内插件）
- 一键触发编译、自动跟踪构建进度，完成后到 [Releases](https://github.com/FeamCoco/AutoBuildFriendlyWrt/releases) 下载固件

> 🔐 **只有仓库所有者能触发编译**：网页触发需要填写具有 Actions 写权限的 Personal Access Token（他人拿不到你的 Token），工作流还会在服务端二次校验触发者必须是仓库所有者，非所有者触发会被直接拒绝。
> 想为自己编译固件？请按下面的 **Fork 教程** 搭建你自己的构建页面，全程约 10 分钟，公开仓库完全免费。

## 🔱 Fork 教程：搭建你自己的构建页面

本仓库的页面只有仓库所有者能操作。想自己编译固件，只需 Fork 一份仓库，给你的 Fork 也开启一个网页控制台：

### 第 1 步 · Fork 本仓库

1. 点击本仓库右上角 **Fork** → **Create a new fork**，仓库会复制到你的账号下
2. 保持仓库为 **Public**（重要：私有仓库会消耗 Actions 分钟数配额，且 Pages 需要付费计划；公开仓库两者都免费）

### 第 2 步 · 启用 Actions

Fork 出来的仓库默认不运行 Actions：

1. 进入你 Fork 仓库的 **Actions** 标签页
2. 点击 **I understand my workflows, go ahead and enable them**

### 第 3 步 · 创建 Personal Access Token（触发编译的「钥匙」）

网页通过 GitHub 官方 API 触发编译，需要一个 Token。推荐使用**细粒度 Token**，权限最小化：

1. GitHub 右上角头像 → **Settings** → 左侧最底部 **Developer settings**
2. **Personal access tokens → Fine-grained tokens** → **Generate new token**
3. 按下表填写：

| 配置项 | 填写值 |
| --- | --- |
| Token name | `friendlywrt-builder`（随意） |
| Expiration | 按需选择（到期后重新生成即可） |
| Resource owner | 选择**你自己的用户名** |
| Repository access | **Only select repositories** → 勾选你 Fork 的仓库 |
| Permissions → Repository permissions → **Actions** | **Read and write** |

4. 点击 **Generate token**，复制生成的 Token（`github_pat_` 开头，**只显示一次**，请妥善保存）

> 也可以用经典 Token（勾选 `repo` 作用域），但权限过大，不推荐。

### 第 4 步 · 开启 GitHub Pages

1. 进入你 Fork 仓库的 **Settings → Pages**
2. **Build and deployment → Source** 选择 **Deploy from a branch**
3. **Branch** 选择 `main` + `/docs` 目录，点击 **Save**

### 第 5 步 · 打开你自己的构建页面

等待 1~3 分钟部署，然后访问（地址规则：`https://<你的用户名>.github.io/<仓库名>/`）：

```
https://<你的用户名>.github.io/AutoBuildFriendlyWrt/
```

例如你的用户名是 `tom`，则访问 `https://tom.github.io/AutoBuildFriendlyWrt/`。页面会自动识别出这是**你自己的**仓库，无需改任何代码。

### 第 6 步 · 触发编译

1. 在页面上粘贴第 3 步的 Token → 点击 **校验并连接**
2. 点选机型 / 版本，勾选要**剔除**的官方预装插件、要**追加**的插件（下方实时预览生成的 `packages` 清单）
3. 点击 **🚀 触发编译**，页面自动显示构建进度
4. 等待约 **4 ~ 6 小时**，到你 Fork 仓库的 **Releases** 下载固件

### 常见问题（FAQ）

| 问题 | 原因与解决 |
| --- | --- |
| 打开页面 404 | Pages 刚开启需等待几分钟；确认 Source 是 `main` + `/docs`；确认地址中用户名 / 仓库名拼写正确 |
| 提示 Token 无效（401） | Token 复制不完整或已过期，重新生成 |
| 提示无权限（403） | Token 未勾选 **Actions: Read and write**；或 Token 不属于仓库所有者（触发仅限所有者） |
| Actions 里找不到构建记录 | 未完成上面第 2 步，Actions 未启用 |
| 构建日志出现 `[WARN] 软件包 xxx 未能启用` | 勾选的插件在所选版本的源中不存在，已自动跳过，不影响其他功能 |
| 能加 OpenClash / PassWall 吗 | 不能。它们不在 FriendlyWrt 官方源码内（需要额外 feed），本仓库仅支持官方源内插件 |
| 一次构建要多久 / 收费吗 | 单机型约 4~6 小时，选 `all` 更久；公开仓库 Actions 完全免费 |

### Token 与安全说明

- Token 只保存在你浏览器本地的 localStorage 中，**只发送给 GitHub 官方 API（api.github.com）**；页面是纯静态文件，部署在 `*.github.io` 上，没有任何后端
- 细粒度 Token 只授权**一个仓库 + Actions 读写**，即使泄露影响也可控，随时可在 GitHub 设置中吊销
- 工作流在服务端二次校验触发者必须是仓库所有者：其他人即使拿到可用的 Token，也无法触发你的仓库编译

## 🛠️ 方式二：Actions 页面手动触发

1. 进入本仓库的 **Actions** → 左侧选择 **Build FriendlyWrt** → **Run workflow**
2. 按需填写参数（见下表），点击运行
3. 等待约 **4 ~ 6 小时**（rootfs 编译约 4.5 小时，各 CPU 镜像打包并行约 1 小时；实测 rk3399 单机型全程约 5.5 小时）
4. 到 **Releases** 页面下载固件

> 💡 仓库所有者也可以直接点一下仓库的 **Star** 触发构建（使用默认参数：25.12 / rk3399 / 不带 Docker）。
> 💡 建议仓库保持 **Public**：私有仓库会消耗 Actions 分钟数配额，单机型一次构建计费约 320+ 分钟，选 `all` 会成倍增加。
> 💡 Release 在构建开始时就会创建，固件文件要等全部编译打包完成后才会出现在里面；若构建失败且未产生任何固件，该空 Release 会被自动清理。

## 构建参数说明

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| version | FriendlyWrt 版本（对应 OpenWrt 25.12 / 24.10） | 25.12 |
| cpu | 主控芯片，选 `all` 可一次构建全部 7 种 | rk3399 |
| include_docker | 是否集成 Docker（体积和编译时间都会明显增加） | no |
| packages | 软件包增删清单，如 `-adblock -samba4 +luci-theme-argon`（语法见下文；网页触发时由页面勾选项自动生成，也可在「自定义清单」中手工补充） | 空 |
| lan_ip | 管理后台 IP（留空保持官方默认 `192.168.2.1`） | 空 |

## 软件包增删语法（packages 参数）

`packages` 参数统一管理软件包的剔除与追加，空格或逗号分隔，逐项按前缀解析：

| 写法 | 含义 |
| --- | --- |
| `-组别名` | **整组剔除**官方预装插件（luci 前端界面 + 后端守护进程 + 中文语言包，对应关系见下表） |
| `-包名` | 剔除单个软件包；`luci-app-xxx` 会自动联动剔除中文语言包 `luci-i18n-xxx-zh-cn` |
| `+包名` | 追加软件包（无前缀视为追加） |

示例：`-adblock -samba4 -extra_themes +luci-theme-argon` 表示剔除广告过滤、Samba、多余主题，并确保 Argon 主题启用；同一包名先后出现在 `-` 与 `+` 中时，后写的生效。

### 可用组别名

| 组别名 | 剔除的软件 |
| --- | --- |
| `adblock` | 广告过滤（adblock / luci-app-adblock） |
| `aria2` | 下载工具（aria2 / luci-app-aria2） |
| `minidlna` | DLNA 媒体服务器（minidlna / luci-app-minidlna） |
| `samba4` | Samba 文件共享（samba4-server / luci-app-samba4） |
| `smartdns` | SmartDNS（smartdns / luci-app-smartdns） |
| `sqm` | SQM 智能队列 QoS（sqm-scripts / luci-app-sqm） |
| `statistics` | 状态统计图表（luci-app-statistics / collectd） |
| `nlbwmon` | 流量统计（nlbwmon / luci-app-nlbwmon） |
| `ddns` | 动态域名 DDNS（ddns-scripts / luci-app-ddns） |
| `upnp` | UPnP（miniupnpd / luci-app-upnp） |
| `ttyd` | 网页终端（ttyd / luci-app-ttyd） |
| `watchcat` | 定时重启（watchcat / luci-app-watchcat） |
| `hd_idle` | 硬盘休眠（hd-idle / luci-app-hd-idle） |
| `diskman` | 磁盘管理 + SMART（luci-app-diskman / smartmontools） |
| `misc_tools` | 杂项工具（coremark / bind-dig / batctl / pciutils / luci-app-commands） |
| `extra_themes` | 多余主题，保留 Argon（material / bootstrap / openwrt-2020） |

说明：

- 组别名与软件包的对应关系维护在 [scripts/package_groups.txt](scripts/package_groups.txt)（唯一数据源，包名取自官方 `configs/rockchip` 配置片段，24.10 与 25.12 通用）；调整分组或新增组别名直接编辑该文件即可
- 组别名未覆盖的包，用 `-包名` 直接剔除
- 若某包仍被其它组件依赖，剔除不会生效，构建日志会有 `[WARN]` 提示；被剔除组件的附属包（如 collectd 的各模块）会随依赖自动消失
- 想知道官方到底预装了什么，可在构建日志里查看 `custome_config.sh` 打印的 **luci 应用清单** 和 **组别名清单**
- `luci-app-openclash`、`luci-app-ssr-plus` 等第三方插件不在官方源码内，请勿通过本仓库添加（需要额外 feed/内核支持）

## 默认系统信息

- 用户名：`root`
- 密码：`password`（请登录后立即修改）
- 后台 IP：`192.168.2.1`（可通过 `lan_ip` 参数修改）

## 固件产物说明

Releases 中每个机型包含两个文件：

- `XXX.img.gz`：完整固件镜像，解压后写入 SD 卡即可启动；也可在 FriendlyWrt 后台 **系统 → eMMC 刷机助手** 中直接上传刷入 eMMC
- `images-XXX.tgz`：升级包，仅供 eMMC 刷机助手做**小版本升级**使用，不能直接写卡

> 大版本升级（如 24.10 → 25.12）建议先备份配置，再用 `XXX.img.gz` 全量刷入。

## 自定义进阶

- **网页控制台**：[docs/index.html](docs/index.html) —— 纯静态页面，通过 GitHub API 触发本工作流；「剔除官方预装」列表实时读取 `scripts/package_groups.txt`，新增组别名后无需改动页面
- **软件包增删逻辑**：[scripts/custome_config.sh](scripts/custome_config.sh) —— 解析 `packages` 清单（`+`/`-` 前缀 + 组别名），直接修改 `friendlywrt/.config` 后通过 `make defconfig` 重新求解依赖
- **插件分组表**：[scripts/package_groups.txt](scripts/package_groups.txt) —— 增删组别名、调整整组剔除的软件包，改这一个文件即可
- **内核参数**：编辑 [scripts/custome_kernel_config.sh](scripts/custome_kernel_config.sh) 中的 `CONFIGS` 数组（该脚本在镜像打包阶段、编译内核前执行）
- **修改参数默认值**：编辑 [.github/workflows/build.yml](.github/workflows/build.yml) 中 `workflow_dispatch.inputs` 的 `default` 值

## 工作流原理

```
gate           触发者校验（仅限仓库所有者，其他人触发直接失败）
   │
prepare        计算参数（版本/CPU/Docker），创建 Release
   │
build_rootfs   拉取 friendlywrt 源码 → 生成 .config → 按 packages 清单
               增删软件包 → make 编译 rootfs → 上传中间产物(artifact)
   │
build_img      按 CPU 拉取内核/uboot 源码 → 下载 rootfs 产物
               → 编译内核与 uboot → 打包 SD/eMMC 镜像 → 上传到 Release
   │
cleanup        构建失败/取消且 Release 无任何产物时，自动删除空 Release
```

rootfs 只编译一次（与 CPU 无关），各 CPU 镜像并行打包，节省大量时间；中间产物使用 `actions/artifact` 传递（保留 1 天），不污染 Release。

## 致谢

- [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) — 官方编译流水线
- [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder) — 交互设计参考
- [friendlyarm/friendlywrt](https://github.com/friendlyarm/friendlywrt) — FriendlyElec 官方 FriendlyWrt
