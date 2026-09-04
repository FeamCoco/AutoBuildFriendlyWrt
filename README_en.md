# AutoBuildFriendlyWrt

[简体中文](README.md) | English

Build [FriendlyWrt](https://github.com/friendlyarm/friendlywrt) firmware in the cloud with GitHub Actions: pick your device and version on a web page, add or remove packages as needed, and get a **cleaner** FriendlyWrt system.

- Pipeline based on [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) (FriendlyElec's official two-stage build: compile the rootfs once, then build kernel/uboot and pack images per CPU)
- UX inspired by [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder): no code changes required, just fill in the form
- Compared with official prebuilt firmware, you can freely **remove the many preinstalled packages**, **add plugins on demand**, **change the admin IP**, and more

## Supported Devices

| SoC (CPU) | Representative boards | Image name |
| --- | --- | --- |
| rk3328 | NanoPi R2S / R2C | R2S-R2C-Series |
| rk3528 | NanoPi R28S / Zero2 / NEO3-Plus | R28S-Zero2-NEO3Plus-Series |
| rk3399 | NanoPi R4S / R4SE, NanoPC-T4 | R4S-Series |
| rk3566 | NanoPi R3S | R3S-Series |
| rk3568 | NanoPi R5S / R5C | R5S-R5C-Series |
| rk3576 | NanoPi R76S / M5 | M5-R76S-Series |
| rk3588 | NanoPi R6S / R6C, NanoPC-T6 / M6 | T6-R6S-R6C-M6-Series |

## Usage

1. Go to **Actions** → select **Build FriendlyWrt** in the sidebar → **Run workflow**
2. Fill in the parameters as needed (see the table below) and start the run
3. Wait about **4 ~ 6 hours** (rootfs build takes ~4.5 hours; per-CPU image packing runs in parallel, ~1 hour; measured ~5.5 hours end-to-end for a single rk3399 build)
4. Download the firmware from the **Releases** page

> 💡 Clicking the repo's **Star** also triggers a build with default parameters (25.12 / rk3399 / no Docker).
> 💡 Keep the repository **Public**: private repos consume Actions minutes — a single-device build bills ~320+ minutes, and choosing `all` multiplies that.
> 💡 The Release is created when the build starts; firmware files only appear in it once everything has finished building. If a build fails without producing any firmware, the empty Release is cleaned up automatically.

## Build Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| version | FriendlyWrt version (based on OpenWrt 25.12 / 24.10) | 25.12 |
| cpu | SoC to build for; choose `all` to build all 7 at once | rk3399 |
| include_docker | Include Docker (significantly increases image size and build time) | no |
| packages | Package add/remove list, e.g. `-adblock -samba4 +luci-theme-argon` (syntax below) | empty |
| lan_ip | Admin UI IP address (leave empty to keep the official default `192.168.2.1`) | empty |

## Package Add/Remove Syntax (packages parameter)

The `packages` parameter manages both removal and inclusion of packages, separated by spaces or commas and parsed per token:

| Syntax | Meaning |
| --- | --- |
| `-group` | Remove a **whole group** of official preinstalled plugins (luci frontend + backend daemon + Chinese language pack, see table below) |
| `-package` | Remove a single package; `luci-app-xxx` also removes the Chinese language pack `luci-i18n-xxx-zh-cn` |
| `+package` | Add a package (no prefix = add) |

Example: `-adblock -samba4 -extra_themes +luci-theme-argon` removes ad filtering, Samba and extra themes while making sure the Argon theme is enabled. If the same package appears with both `-` and `+`, the last one wins.

### Available group aliases

| Group | Packages removed |
| --- | --- |
| `adblock` | Ad filtering (adblock / luci-app-adblock) |
| `aria2` | Downloader (aria2 / luci-app-aria2) |
| `minidlna` | DLNA media server (minidlna / luci-app-minidlna) |
| `samba4` | Samba file sharing (samba4-server / luci-app-samba4) |
| `smartdns` | SmartDNS (smartdns / luci-app-smartdns) |
| `sqm` | SQM queueing QoS (sqm-scripts / luci-app-sqm) |
| `statistics` | Status charts (luci-app-statistics / collectd) |
| `nlbwmon` | Traffic stats (nlbwmon / luci-app-nlbwmon) |
| `ddns` | Dynamic DNS (ddns-scripts / luci-app-ddns) |
| `upnp` | UPnP (miniupnpd / luci-app-upnp) |
| `ttyd` | Web terminal (ttyd / luci-app-ttyd) |
| `watchcat` | Scheduled reboot (watchcat / luci-app-watchcat) |
| `hd_idle` | Disk standby (hd-idle / luci-app-hd-idle) |
| `diskman` | Disk manager + SMART (luci-app-diskman / smartmontools) |
| `misc_tools` | Misc tools (coremark / bind-dig / batctl / pciutils / luci-app-commands) |
| `extra_themes` | Extra themes, keeps Argon (material / bootstrap / openwrt-2020) |

Notes:

- The group-to-package mapping is maintained in [scripts/package_groups.txt](scripts/package_groups.txt) (single source of truth; package names come from the official `configs/rockchip` fragments and apply to both 24.10 and 25.12). Adjust groups or add new ones by editing that file
- Packages not covered by any group can be removed directly via `-package`
- If a package is still required by other components, removal won't take effect — the build log will show a `[WARN]`; helper packages of a removed component (e.g. the collectd modules) disappear automatically via dependency resolution
- To see everything the official firmware preinstalls, check the **luci app list** and **group alias list** printed by `custome_config.sh` in the build log
- Third-party plugins such as `luci-app-openclash` and `luci-app-ssr-plus` are not part of the official source and cannot be added via this repo (they need extra feeds/kernel support)

## Default System Info

- Username: `root`
- Password: `password` (change it immediately after first login)
- Admin IP: `192.168.2.1` (can be changed via the `lan_ip` parameter)

## Firmware Artifacts

Each device gets two files in Releases:

- `XXX.img.gz`: full firmware image; decompress and write to an SD card to boot, or upload it directly in FriendlyWrt under **System → eMMC Flasher** to flash eMMC
- `images-XXX.tgz`: upgrade package for **minor-version upgrades** via the eMMC Flasher only; not meant to be written to a card directly

> For major version upgrades (e.g. 24.10 → 25.12), back up your configuration first and do a full install with `XXX.img.gz`.

## Advanced Customization

- **Package add/remove logic**: [scripts/custome_config.sh](scripts/custome_config.sh) — parses the `packages` list (`+`/`-` prefixes + group aliases), edits `friendlywrt/.config` and re-resolves dependencies with `make defconfig`
- **Plugin group table**: [scripts/package_groups.txt](scripts/package_groups.txt) — add/remove group aliases or adjust the packages a group removes, all in one file
- **Kernel parameters**: edit the `CONFIGS` array in [scripts/custome_kernel_config.sh](scripts/custome_kernel_config.sh) (runs during the image stage, before the kernel is compiled)
- **Change parameter defaults**: edit the `default` values of `workflow_dispatch.inputs` in [.github/workflows/build.yml](.github/workflows/build.yml)

## How the Workflow Works

```
prepare        Compute parameters (version/CPU/Docker) and create the Release
   │
build_rootfs   Fetch friendlywrt sources → generate .config → apply the
               packages list → make the rootfs → upload artifact
   │
build_img      Per CPU: fetch kernel/uboot sources → download the rootfs
               artifact → build kernel & uboot → pack SD/eMMC images → upload to Release
   │
cleanup        If the build fails or is cancelled and the Release has no assets, delete the empty Release
```

The rootfs is compiled only once (it is CPU-independent) and per-CPU images are packed in parallel, which saves a lot of time. Intermediate artifacts are passed via `actions/artifact` (kept for 1 day) so the Release stays clean.

## Credits

- [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) — official build pipeline
- [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder) — UX design reference
- [friendlyarm/friendlywrt](https://github.com/friendlyarm/friendlywrt) — FriendlyElec's official FriendlyWrt
