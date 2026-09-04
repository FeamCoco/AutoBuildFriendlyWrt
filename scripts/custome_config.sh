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
#   REMOVE_PACKAGES  需要剔除的官方预装软件包，空格分隔
#                    例: "adblock luci-app-adblock aria2 luci-app-aria2 coremark"
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
REMOVE_LIST=$(normalize "${REMOVE_PACKAGES:-}")

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
