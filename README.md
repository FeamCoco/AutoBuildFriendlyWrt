# AutoBuildFriendlyWrt

简体中文 | [English](README_en.md)

通过 GitHub Actions 云端编译 [FriendlyWrt](https://github.com/friendlyarm/friendlywrt) 固件：在网页上点选机型、版本，按需增删软件包，得到一个**更纯净**的 FriendlyWrt 系统。

- 流水线基于 [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt)（FriendlyElec 官方两段式编译方案：先编译 rootfs，再按 CPU 编译内核/uboot 并打包镜像）
- 交互方式参考 [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder)：无需改代码，网页填参数即可
- 与官方预编译固件相比，可自由**剔除官方预装的大量软件**、**按需追加插件**、**修改管理后台 IP** 等

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

## 使用方法

1. 进入本仓库的 **Actions** → 左侧选择 **Build FriendlyWrt** → **Run workflow**
2. 按需填写参数（见下表），点击运行
3. 等待约 **2.5 ~ 4 小时**（rootfs 编译约 2.5 小时，各 CPU 镜像打包并行约 1 小时）
4. 到 **Releases** 页面下载固件

> 💡 也可以直接点一下仓库的 **Star** 触发构建（使用默认参数：25.12 / rk3399 / 不带 Docker）。
> 💡 建议仓库保持 **Public**：私有仓库会消耗 Actions 分钟数配额，一次构建约需 400+ 分钟。

## 构建参数说明

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| version | FriendlyWrt 版本（对应 OpenWrt 25.12 / 24.10） | 25.12 |
| cpu | 主控芯片，选 `all` 可一次构建全部 7 种 | rk3399 |
| include_docker | 是否集成 Docker（体积和编译时间都会明显增加） | no |
| 预装插件勾选剔除 | 16 个勾选项，覆盖官方常用预装插件，勾选即整组剔除（见下文） | 不勾选 |
| add_packages | 额外集成的软件包，空格分隔 | 空 |
| remove_packages | 补充剔除（高级）：手动填写包名，一般无需使用 | 空 |
| lan_ip | 管理后台 IP（留空保持官方默认 `192.168.2.1`） | 空 |

## 官方预装插件勾选剔除

Run workflow 页面可以直接勾选要剔除的官方预装插件，**勾选即整组剔除**（luci 前端界面 + 后端守护进程 + 中文语言包）：

| 勾选项 | 剔除的软件 |
| --- | --- |
| 广告过滤 adblock | adblock / luci-app-adblock |
| 下载工具 aria2 | aria2 / luci-app-aria2 |
| DLNA 媒体服务器 | minidlna / luci-app-minidlna |
| Samba 文件共享 | samba4-server / luci-app-samba4 |
| SmartDNS | smartdns / luci-app-smartdns |
| SQM 智能队列 (QoS) | sqm-scripts / luci-app-sqm |
| 状态统计图表 | luci-app-statistics / collectd |
| 流量统计 nlbwmon | nlbwmon / luci-app-nlbwmon |
| 动态域名 DDNS | ddns-scripts / luci-app-ddns |
| UPnP | miniupnpd / luci-app-upnp |
| 网页终端 ttyd | ttyd / luci-app-ttyd |
| 定时重启 watchcat | watchcat / luci-app-watchcat |
| 硬盘休眠 hd-idle | hd-idle / luci-app-hd-idle |
| 磁盘管理 + SMART | luci-app-diskman / smartmontools |
| 杂项工具 | coremark / bind-dig / batctl / pciutils / luci-app-commands |
| 多余主题（保留 Argon） | material / bootstrap / openwrt-2020 |

说明：

- 勾选项与软件包的对应关系维护在 [scripts/custome_config.sh](scripts/custome_config.sh) 的 `preset_group` 函数中，包名取自官方 `configs/rockchip` 配置片段，24.10 与 25.12 通用
- 若某包仍被其它组件依赖，剔除不会生效，构建日志会有 `[WARN]` 提示；被剔除组件的附属包（如 collectd 的各模块）会随依赖自动消失
- 勾选项未覆盖的包，可通过 `remove_packages` 手动补充
- 想知道官方到底预装了什么，可在构建日志里查看 `custome_config.sh` 打印的 **luci 应用清单**
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

- **软件包增删逻辑**：[scripts/custome_config.sh](scripts/custome_config.sh) —— 直接修改 `friendlywrt/.config` 后通过 `make defconfig` 重新求解依赖
- **内核参数**：编辑 [scripts/custome_kernel_config.sh](scripts/custome_kernel_config.sh) 中的 `CONFIGS` 数组（该脚本在镜像打包阶段、编译内核前执行）
- **修改参数默认值**：编辑 [.github/workflows/build.yml](.github/workflows/build.yml) 中 `workflow_dispatch.inputs` 的 `default` 值

## 工作流原理

```
prepare        计算参数（版本/CPU/Docker），创建 Release
   │
build_rootfs   拉取 friendlywrt 源码 → 生成 .config → 按 add/remove 参数
               增删软件包 → make 编译 rootfs → 上传中间产物(artifact)
   │
build_img      按 CPU 拉取内核/uboot 源码 → 下载 rootfs 产物
               → 编译内核与 uboot → 打包 SD/eMMC 镜像 → 上传到 Release
```

rootfs 只编译一次（与 CPU 无关），各 CPU 镜像并行打包，节省大量时间；中间产物使用 `actions/artifact` 传递（保留 1 天），不污染 Release。

## 致谢

- [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) — 官方编译流水线
- [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder) — 交互设计参考
- [friendlyarm/friendlywrt](https://github.com/friendlyarm/friendlywrt) — FriendlyElec 官方 FriendlyWrt
