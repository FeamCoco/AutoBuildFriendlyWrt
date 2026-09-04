# AutoBuildFriendlyWrt

[简体中文](README.md) | English

Build [FriendlyWrt](https://github.com/friendlyarm/friendlywrt) firmware in the cloud with GitHub Actions: pick your device and version on a web page, add or remove packages as needed, and get a **cleaner** FriendlyWrt system.

- Pipeline based on [friendlyarm/Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) (FriendlyElec's official two-stage build: compile the rootfs once, then build kernel/uboot and pack images per CPU)
- UX inspired by [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder): no code changes required, just fill in the form
- Compared with official prebuilt firmware, you can freely **remove the many preinstalled packages**, **add plugins on demand**, **change the admin IP**, and more

Three ways to trigger a build: **🌐 GitHub Pages web console (recommended, see below)** / 🛠️ manual run from the Actions page / ⭐ owner clicks Star.

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

## 🌐 Option 1: Trigger via GitHub Pages Web Console (recommended)

This repo ships a **purely static web console** hosted on GitHub Pages — no need to dig through the Actions page; pick options and click to build:

**👉 [https://feamcoco.github.io/AutoBuildFriendlyWrt/](https://feamcoco.github.io/AutoBuildFriendlyWrt/)**

Features:

- Pick the SoC / version / Docker / admin IP
- **Check off preinstalled plugins to remove** (whole groups; the list is read live from [scripts/package_groups.txt](scripts/package_groups.txt))
- **Check off well-known plugins to add** (HomeProxy, ZeroTier, Tailscale, WireGuard, FRP, AdGuard Home, etc. — all available in the official source)
- Trigger the build with one click, track progress automatically, then download the firmware from [Releases](https://github.com/FeamCoco/AutoBuildFriendlyWrt/releases)

> 🔐 **Only the repository owner can trigger builds**: the web console requires a Personal Access Token with Actions write permission (which others don't have), and the workflow double-checks server-side that the triggerer is the repository owner — anyone else is rejected.
> Want to build firmware for yourself? Follow the **Fork tutorial** below to set up your own build page — about 10 minutes, completely free for public repos.

## 🔱 Fork Tutorial: Set Up Your Own Build Page

The console in this repo can only be operated by the repository owner. To build firmware for yourself, fork this repo and enable a web console for your fork:

### Step 1 · Fork this repository

1. Click **Fork** in the top-right corner → **Create a new fork**; the repo is copied to your account
2. Keep the repo **Public** (important: private repos consume Actions minutes and require a paid plan for Pages; public repos get both for free)

### Step 2 · Enable Actions

Forked repos don't run Actions by default:

1. Open the **Actions** tab of your fork
2. Click **I understand my workflows, go ahead and enable them**

### Step 3 · Create a Personal Access Token (the "key" that triggers builds)

The page triggers builds through the official GitHub API and needs a token. A **fine-grained token** is recommended for least privilege:

1. GitHub avatar (top-right) → **Settings** → **Developer settings** at the bottom of the left sidebar
2. **Personal access tokens → Fine-grained tokens** → **Generate new token**
3. Fill in as follows:

| Setting | Value |
| --- | --- |
| Token name | `friendlywrt-builder` (anything) |
| Expiration | As you like (regenerate when it expires) |
| Resource owner | **Your own username** |
| Repository access | **Only select repositories** → pick your fork |
| Permissions → Repository permissions → **Actions** | **Read and write** |

4. Click **Generate token** and copy the token (starts with `github_pat_`, **shown only once** — keep it safe)

> A classic token with the `repo` scope also works, but it grants far more access than needed — not recommended.

### Step 4 · Enable GitHub Pages

1. Open your fork's **Settings → Pages**
2. Under **Build and deployment → Source**, choose **Deploy from a branch**
3. Set **Branch** to `main` + the `/docs` folder, then click **Save**

### Step 5 · Open your own build page

Wait 1–3 minutes for deployment, then visit (URL pattern: `https://<your-username>.github.io/<repo-name>/`):

```
https://<your-username>.github.io/AutoBuildFriendlyWrt/
```

For example, if your username is `tom`: `https://tom.github.io/AutoBuildFriendlyWrt/`. The page auto-detects that it now belongs to **your** fork — no code changes needed.

### Step 6 · Trigger a build

1. Paste the token from Step 3 → click **校验并连接 / Connect**
2. Pick the SoC / version, check the preinstalled plugins to **remove** and the plugins to **add** (the generated `packages` list is previewed live)
3. Click **🚀 触发编译 / Trigger build** — the page then shows build progress automatically
4. After about **4–6 hours**, download the firmware from your fork's **Releases**

### FAQ

| Problem | Cause & fix |
| --- | --- |
| Page shows 404 | Pages needs a few minutes after enabling; make sure Source is `main` + `/docs`; check the username / repo name in the URL |
| "Token invalid" (401) | Token copied incompletely or expired — regenerate it |
| "No permission" (403) | Token lacks **Actions: Read and write**; or the token doesn't belong to the repository owner (only the owner can trigger) |
| No build run appears in Actions | Step 2 was missed — Actions isn't enabled yet |
| Build log shows `[WARN] package xxx could not be enabled` | The checked plugin doesn't exist in the selected version's feeds; it's skipped automatically and the build is unaffected |
| Can I add OpenClash / PassWall? | No. They aren't part of the official FriendlyWrt source (they need extra feeds); only official-feed plugins are supported |
| How long / how much? | ~4–6 hours for one SoC, longer with `all`; Actions is free for public repos |

### Token & Security Notes

- The token is stored only in your browser's localStorage and is **sent only to the official GitHub API (api.github.com)**; the page is a static file hosted on `*.github.io` with no backend at all
- A fine-grained token grants access to **one repo with Actions read/write only**, so even a leaked token has limited impact and can be revoked anytime in GitHub settings
- The workflow double-checks server-side that the triggerer is the repository owner: even someone with a working token cannot trigger builds on your repo

## 🛠️ Option 2: Trigger Manually from the Actions Page

1. Go to **Actions** → select **Build FriendlyWrt** in the sidebar → **Run workflow**
2. Fill in the parameters as needed (see the table below) and start the run
3. Wait about **4 ~ 6 hours** (rootfs build takes ~4.5 hours; per-CPU image packing runs in parallel, ~1 hour; measured ~5.5 hours end-to-end for a single rk3399 build)
4. Download the firmware from the **Releases** page

> 💡 The repository owner can also click the repo's **Star** to trigger a build with default parameters (25.12 / rk3399 / no Docker).
> 💡 Keep the repository **Public**: private repos consume Actions minutes — a single-device build bills ~320+ minutes, and choosing `all` multiplies that.
> 💡 The Release is created when the build starts; firmware files only appear in it once everything has finished building. If a build fails without producing any firmware, the empty Release is cleaned up automatically.

## Build Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| version | FriendlyWrt version (based on OpenWrt 25.12 / 24.10) | 25.12 |
| cpu | SoC to build for; choose `all` to build all 7 at once | rk3399 |
| include_docker | Include Docker (significantly increases image size and build time) | no |
| packages | Package add/remove list, e.g. `-adblock -samba4 +luci-theme-argon` (syntax below; auto-generated from the checkboxes when triggered via the web console, extendable in the raw list box) | empty |
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

- **Web console**: [docs/index.html](docs/index.html) — pure static page that triggers this workflow via the GitHub API; the "remove preinstalled" list is read live from `scripts/package_groups.txt`, so new group aliases need no page changes
- **Package add/remove logic**: [scripts/custome_config.sh](scripts/custome_config.sh) — parses the `packages` list (`+`/`-` prefixes + group aliases), edits `friendlywrt/.config` and re-resolves dependencies with `make defconfig`
- **Plugin group table**: [scripts/package_groups.txt](scripts/package_groups.txt) — add/remove group aliases or adjust the packages a group removes, all in one file
- **Kernel parameters**: edit the `CONFIGS` array in [scripts/custome_kernel_config.sh](scripts/custome_kernel_config.sh) (runs during the image stage, before the kernel is compiled)
- **Change parameter defaults**: edit the `default` values of `workflow_dispatch.inputs` in [.github/workflows/build.yml](.github/workflows/build.yml)

## How the Workflow Works

```
gate           Trigger check (repository owner only; anyone else is rejected)
   │
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
