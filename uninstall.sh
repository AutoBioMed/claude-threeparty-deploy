#!/usr/bin/env bash
# 卸载 ccx 切换器 (不会卸载 Claude Code 本体)
set -u
CCX_DIR="$HOME/.config/claude-switch"

echo "==== 卸载 claude-switch ===="

# 1) 从 shell 启动文件移除挂载块
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$RC" ] || continue
  if grep -q 'claude-switch/ccx.sh' "$RC" 2>/dev/null; then
    # 删除 >>> claude-switch >>> 到 <<< claude-switch <<< 之间的块
    sed -i.ccxbak '/# >>> claude-switch >>>/,/# <<< claude-switch <<</d' "$RC"
    echo "✔ 已从 $(basename "$RC") 移除挂载 (备份: ${RC}.ccxbak)"
  fi
done

# 2) 删除配置目录 (含 Key)
if [ -d "$CCX_DIR" ]; then
  printf "删除配置目录 %s (含 API Key)? [y/N] " "$CCX_DIR"
  read -r a </dev/tty 2>/dev/null || a=""
  case "$a" in
    y|Y) rm -rf "$CCX_DIR"; echo "✔ 已删除 $CCX_DIR" ;;
    *)   echo "! 已保留 $CCX_DIR" ;;
  esac
fi

echo "完成。Claude Code 本体未改动。重开终端生效。"
