#!/bin/bash
# =====================================================================
# FriendlyWrt 内核参数自定义脚本
#
# 用法（在 GitHub Actions 中，project 目录下执行，位于编译内核之前）：
#   cd project && source ../scripts/custome_kernel_config.sh
#
# 按需编辑下方 CONFIGS 数组即可，例：
#   CONFIGS=(
#     "CONFIG_NET_ACT_CT=m"
#     "CONFIG_TCP_CONG_BBR=y"
#   )
# =====================================================================

CONFIGS=(
  # "CONFIG_NET_ACT_CT=m"
  # "CONFIG_NET_ACT_CTINFO=m"
)

if [ ${#CONFIGS[@]} -eq 0 ]; then
  echo "[INFO] 未配置内核自定义参数，跳过（编辑 scripts/custome_kernel_config.sh 的 CONFIGS 数组启用）"
  return 0 2>/dev/null || exit 0
fi

source .current_config.mk
KCFG=kernel/arch/arm64/configs/$(awk '{print $1}' <<< "$TARGET_KERNEL_CONFIG")

for CFG in "${CONFIGS[@]}"; do
  KEY=${CFG%%=*}
  if grep -q "^#\?${KEY}=" "${KCFG}"; then
    sed -i "s@^#\?${KEY}=.*@${CFG}@g" "${KCFG}"
  else
    echo "$CFG" >> "${KCFG}"
  fi
done

echo "[INFO] 内核参数已写入 ${KCFG}: ${CONFIGS[*]}"
