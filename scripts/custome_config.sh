#!/bin/bash
# =====================================================================
# FriendlyWrt 软件包自定义脚本
#
# 用法（在 GitHub Actions 中，project 目录下执行）：
#   cd project && source ../scripts/custome_config.sh
#
# 环境变量（由 workflow 注入，也可本地手动 export 后直接跑）：
#   ADD_PACKAGES     需要额外集成的软件包，空格分隔
#                    例: "luci-app-openclash luci-theme-argon"
#   REMOVE_PACKAGES  需要剔除的软件包，空格分隔（高级用法，作勾选项的补充）
#   RM_*             workflow 页面的「勾选剔除」开关（true/false），见下方 preset_group
#
# 执行时机：必须在 `DEBUG_DOT_CONFIG=1 ./build.sh friendlywrt` 之后。
# 该命令会根据 configs/rockchip* 配置片段生成 friendlywrt/.config 后停下，
# 本脚本直接修改该 .config，再通过 make defconfig 重新求解依赖关系。
#
# 注意：
#   1. 剔除 luci-app-xxx 时会自动同步剔除对应的中文语言包 luci-i18n-xxx-zh-cn
#   2. 若某包仍被其它组件依赖，剔除不会生效，日志中会有 WARN 提示
#   3. 添加的软件包必须存在于 friendlywrt 源码或已启用的 feeds 中，
#      否则 make defconfig 会将其静默丢弃，日志中会有 WARN 提示
# =====================================================================
set -eu

FW_DIR=friendlywrt
CFG=$FW_DIR/.config

if [ ! -f "$CFG" ]; then
  echo "[ERROR] 未找到 $CFG"
  echo "        请先在 project 目录执行: DEBUG_DOT_CONFIG=1 ./build.sh friendlywrt"
  exit 1
fi

normalize() {
  echo "$1" | tr '[:space:]' '\n' | sed '/^$/d' | sort -u
}

ADD_LIST=$(normalize "${ADD_PACKAGES:-}")

# ---------- 勾选式剔除开关（RM_* 布尔变量）→ 官方预装软件包组 ----------
# 每组包含: luci 前端界面 + 后端守护进程（中文语言包在下方循环中自动联动剔除）。
# 包名取自 friendlyarm/friendlywrt_configs 的 configs/rockchip 配置片段，
# 24.10 与 25.12 基本一致；个别包在某版本不存在时 sed 无命中，属安全空操作。
preset_group() {
  case "$1" in
    adblock)      echo "adblock luci-app-adblock" ;;
    aria2)        echo "aria2 aria2-openssl luci-app-aria2" ;;
    minidlna)     echo "minidlna luci-app-minidlna" ;;
    samba4)       echo "samba4-server samba4-libs luci-app-samba4" ;;
    smartdns)     echo "smartdns luci-app-smartdns" ;;
    sqm)          echo "sqm-scripts luci-app-sqm" ;;
    statistics)   echo "luci-app-statistics collectd" ;;
    nlbwmon)      echo "nlbwmon luci-app-nlbwmon" ;;
    ddns)         echo "ddns-scripts ddns-scripts-services luci-app-ddns" ;;
    upnp)         echo "miniupnpd luci-app-upnp" ;;
    ttyd)         echo "ttyd luci-app-ttyd" ;;
    watchcat)     echo "watchcat luci-app-watchcat" ;;
    hd_idle)      echo "hd-idle luci-app-hd-idle" ;;
    diskman)      echo "luci-app-diskman smartmontools" ;;
    misc_tools)   echo "coremark bind-dig bind-libs batctl-default pciutils pciids luci-app-commands" ;;
    extra_themes) echo "luci-theme-material luci-theme-bootstrap luci-theme-openwrt-2020" ;;
  esac
}

PRESET_REMOVE=""
for K in adblock aria2 minidlna samba4 smartdns sqm statistics nlbwmon \
         ddns upnp ttyd watchcat hd_idle diskman misc_tools extra_themes; do
  VAR="RM_${K^^}"
  if [ "${!VAR:-}" = "true" ]; then
    echo "==> 已勾选剔除: ${K}"
    PRESET_REMOVE="${PRESET_REMOVE} $(preset_group "$K")"
  fi
done

REMOVE_LIST=$(normalize "${REMOVE_PACKAGES:-} ${PRESET_REMOVE}")

echo "==> 官方默认预装的 luci 应用（可作为剔除参考）:"
grep -oE '^CONFIG_PACKAGE_(luci-app-[a-z0-9_-]+)=y' "$CFG" \
  | sed 's/^CONFIG_PACKAGE_//; s/=y$//' | sort || true
echo ""

# ---------- 剔除软件包 ----------
if [ -n "$REMOVE_LIST" ]; then
  echo "==> 将剔除以下预装软件包:"
  echo "$REMOVE_LIST"
  for P in $REMOVE_LIST; do
    # 主包（=y 或 =m 一并处理）
    sed -i -E "s/^CONFIG_PACKAGE_${P}=(y|m)\$/# CONFIG_PACKAGE_${P} is not set/" "$CFG"
    # luci-app-xxx 对应的中文语言包
    APP=${P#luci-app-}
    if [ "$APP" != "$P" ]; then
      sed -i -E "s/^CONFIG_PACKAGE_luci-i18n-${APP}-zh-cn=(y|m)\$/# CONFIG_PACKAGE_luci-i18n-${APP}-zh-cn is not set/" "$CFG"
    fi
  done
else
  echo "==> 未指定 REMOVE_PACKAGES，保留全部官方预装软件"
fi

# ---------- 追加软件包 ----------
if [ -n "$ADD_LIST" ]; then
  echo "==> 将额外集成以下软件包:"
  echo "$ADD_LIST"
  for P in $ADD_LIST; do
    if grep -qE "^# CONFIG_PACKAGE_${P} is not set\$" "$CFG"; then
      # 配置中存在但未启用，改为启用
      sed -i -E "s/^# CONFIG_PACKAGE_${P} is not set\$/CONFIG_PACKAGE_${P}=y/" "$CFG"
    elif ! grep -qE "^CONFIG_PACKAGE_${P}=y\$" "$CFG"; then
      # 配置中不存在（含当前为 =m 的情况），追加条目，交由 defconfig 求解依赖
      echo "CONFIG_PACKAGE_${P}=y" >> "$CFG"
    fi
  done
else
  echo "==> 未指定 ADD_PACKAGES，不额外集成软件"
fi

# ---------- 重新求解依赖 ----------
( cd "$FW_DIR" && make defconfig )

# ---------- 校验结果 ----------
for P in $ADD_LIST; do
  if ! grep -qE "^CONFIG_PACKAGE_${P}=y\$" "$CFG"; then
    echo "[WARN] 软件包 ${P} 未能启用：可能不存在于源码或 feeds 中，请检查名称"
  fi
done
for P in $REMOVE_LIST; do
  if grep -qE "^CONFIG_PACKAGE_${P}=(y|m)\$" "$CFG"; then
    echo "[WARN] 软件包 ${P} 仍被其它组件依赖，本次剔除不生效"
  fi
done

echo "==> 软件包自定义完成"
