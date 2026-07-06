#!/usr/bin/env bash
# ============================================================
#  Claude Code × 硅基流动  一键部署脚本
#  用法:  bash install.sh
#  作用:  1) 安装 Claude Code CLI(若缺失)
#         2) 部署 ccx 多供应商/多模型切换器
#         3) 挂载到 shell 启动文件, 可选写入 API Key
#  支持:  Linux / macOS (bash 或 zsh)
# ============================================================
set -u

# ---------- 彩色输出 ----------
if [ -t 1 ]; then
  R='\033[0m'; B='\033[1m'; G='\033[32m'; Y='\033[33m'; C='\033[36m'; RED='\033[31m'
else R=''; B=''; G=''; Y=''; C=''; RED=''; fi
info(){ printf "${C}▶ %s${R}\n" "$*"; }
ok(){   printf "${G}✔ %s${R}\n" "$*"; }
warn(){ printf "${Y}! %s${R}\n" "$*"; }
err(){  printf "${RED}✘ %s${R}\n" "$*" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CCX_DIR="$HOME/.config/claude-switch"

printf "${B}==== Claude Code × 硅基流动 部署脚本 ====${R}\n\n"

# ============================================================
# 步骤 1: 安装 Claude Code CLI
# ============================================================
info "步骤 1/4  检查 Claude Code CLI"
if command -v claude >/dev/null 2>&1; then
  ok "已安装: $(claude --version 2>/dev/null || echo claude)"
else
  warn "未检测到 claude, 开始安装..."
  installed=0
  # 方式A: 官方安装脚本(推荐, 免 node, 装到 ~/.local/bin)
  if command -v curl >/dev/null 2>&1; then
    info "  尝试官方安装脚本: curl -fsSL https://claude.ai/install.sh | bash"
    if curl -fsSL https://claude.ai/install.sh | bash; then installed=1; fi
  fi
  # 方式B: 回退到 npm 全局安装(需 Node.js >= 18)
  if [ "$installed" -eq 0 ]; then
    if command -v npm >/dev/null 2>&1; then
      info "  回退 npm 安装: npm i -g @anthropic-ai/claude-code"
      if npm install -g @anthropic-ai/claude-code; then installed=1; fi
    else
      warn "  未找到 npm。请先安装 Node.js>=18 (见 README 步骤1), 再重跑本脚本。"
    fi
  fi
  # 把 ~/.local/bin 加进 PATH(官方脚本装这里)
  case ":$PATH:" in *":$HOME/.local/bin:"*) : ;; *) export PATH="$HOME/.local/bin:$PATH";; esac
  if command -v claude >/dev/null 2>&1; then
    ok "Claude Code 安装成功: $(claude --version 2>/dev/null)"
  else
    err "Claude Code 未安装成功, 但会继续部署切换器。请稍后手动安装 claude。"
  fi
fi
echo

# ============================================================
# 步骤 2: 部署 ccx 切换器
# ============================================================
info "步骤 2/4  部署 ccx 切换器到 $CCX_DIR"
mkdir -p "$CCX_DIR"
cp "$SCRIPT_DIR/ccx.sh" "$CCX_DIR/ccx.sh"
ok "已复制 ccx.sh"

if [ ! -f "$CCX_DIR/keys.env" ]; then
  cp "$SCRIPT_DIR/keys.env.example" "$CCX_DIR/keys.env"
  chmod 600 "$CCX_DIR/keys.env"
  ok "已创建 keys.env (占位, 权限600)"
else
  chmod 600 "$CCX_DIR/keys.env"
  warn "keys.env 已存在, 保留你原有的 Key"
fi
echo

# ============================================================
# 步骤 3: 挂载到 shell 启动文件 (bash & zsh, 幂等)
# ============================================================
info "步骤 3/4  挂载到 shell 启动文件"
HOOK='[ -f "$HOME/.config/claude-switch/ccx.sh" ] && . "$HOME/.config/claude-switch/ccx.sh"'
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  # 仅当对应 shell 的 rc 已存在, 或它是当前 shell 时才写
  if [ -f "$RC" ]; then
    if grep -q 'claude-switch/ccx.sh' "$RC" 2>/dev/null; then
      warn "$(basename "$RC") 已挂载, 跳过"
    else
      printf '\n# >>> claude-switch >>>\n%s\n# <<< claude-switch <<<\n' "$HOOK" >> "$RC"
      ok "已写入 $(basename "$RC")"
    fi
  fi
done
# 若两者都不存在, 至少写 .bashrc
if [ ! -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
  printf '\n# >>> claude-switch >>>\n%s\n# <<< claude-switch <<<\n' "$HOOK" >> "$HOME/.bashrc"
  ok "已创建并写入 .bashrc"
fi
echo

# ============================================================
# 步骤 4: 可选写入 API Key
# ============================================================
info "步骤 4/4  设置硅基流动 API Key"
CURKEY="$(grep -oE 'SILICONFLOW_KEY="[^"]*"' "$CCX_DIR/keys.env" 2>/dev/null | sed 's/.*="//;s/"$//')"
if printf '%s' "$CURKEY" | grep -q '^sk-' && ! printf '%s' "$CURKEY" | grep -q '在此粘贴'; then
  ok "已存在有效 Key, 跳过"
else
  printf "${Y}请粘贴硅基流动 API Key (sk- 开头), 直接回车可跳过稍后手填:${R} "
  read -r SFKEY </dev/tty 2>/dev/null || SFKEY=""
  if [ -n "$SFKEY" ]; then
    printf '# 硅基流动 API Key\nSILICONFLOW_KEY="%s"\n' "$SFKEY" > "$CCX_DIR/keys.env"
    chmod 600 "$CCX_DIR/keys.env"
    ok "Key 已写入 (权限600)"
  else
    warn "已跳过。稍后请编辑: $CCX_DIR/keys.env"
  fi
fi
echo

# ============================================================
# 完成
# ============================================================
printf "${B}${G}==== 部署完成 ====${R}\n\n"
cat <<'EOF'
下一步:
  1) 若刚才没填 Key, 编辑:  nano ~/.config/claude-switch/keys.env
  2) 新开一个终端 (或执行:  source ~/.bashrc )
  3) 选择模式并启动:
        ccx list        # 查看所有模式
        ccx glm         # 单模型 GLM-5.2
        ccx multi       # 多模型映射(进 claude 后用 /model 切换)
        claude          # 启动
  4) 验证 Key:
        source ~/.config/claude-switch/keys.env
        curl -s -H "Authorization: Bearer $SILICONFLOW_KEY" https://api.siliconflow.cn/v1/models | head -c 200; echo

  卸载:  bash uninstall.sh
  文档:  README.md  /  claude_siliconflow_配置指南.html
EOF
