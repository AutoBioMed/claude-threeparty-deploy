# claude-switch: 无GUI多供应商 / 多模型槽位映射切换器 (Claude Code)
# 由 install.sh 部署到 ~/.config/claude-switch/ccx.sh, 并被 shell 启动文件自动加载。
# 支持供应商: 硅基流动 / 智谱官方(BigModel) / DeepSeek官方 / 官方Claude
CCX_VERSION="1.1.0"
CCX_DIR="$HOME/.config/claude-switch"
CCX_CURRENT="$CCX_DIR/current"
CCX_KEYFILE="$CCX_DIR/keys.env"

[ -f "$CCX_KEYFILE" ] && . "$CCX_KEYFILE"

# 清空所有相关变量(单模型 + 多槽位 + 元数据 + CC 控制变量)
_ccx_clear() {
  unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_API_KEY \
        ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL \
        ANTHROPIC_DEFAULT_OPUS_MODEL   ANTHROPIC_DEFAULT_OPUS_MODEL_NAME   ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION   ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES \
        ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL_NAME ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES \
        ANTHROPIC_DEFAULT_HAIKU_MODEL  ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME  ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION  ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES \
        ANTHROPIC_CUSTOM_MODEL_OPTION  ANTHROPIC_CUSTOM_MODEL_OPTION_NAME  ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION  ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES \
        CLAUDE_CODE_SUBAGENT_MODEL CLAUDE_CODE_AUTO_COMPACT_WINDOW CLAUDE_CODE_EFFORT_LEVEL
}

# 硅基流动公共(如需国际站改成 https://api.siliconflow.com)
_ccx_sf_common() {
  export ANTHROPIC_BASE_URL="https://api.siliconflow.cn"
  export ANTHROPIC_AUTH_TOKEN="$SILICONFLOW_KEY"
}

_ccx_apply() {
  case "$1" in
    # ---------------- 硅基流动 ----------------
    glm)                      # 单模型: GLM-5.2 (已核实)
      _ccx_sf_common
      export ANTHROPIC_MODEL="zai-org/GLM-5.2"
      export ANTHROPIC_SMALL_FAST_MODEL="zai-org/GLM-5.2" ;;
    glmv)                     # 单模型: GLM-4.5V 多模态 (已核实)
      _ccx_sf_common
      export ANTHROPIC_MODEL="zai-org/GLM-4.5V"
      export ANTHROPIC_SMALL_FAST_MODEL="zai-org/GLM-4.5V" ;;
    kimi)                     # 单模型: Kimi (slug以模型页为准)
      _ccx_sf_common
      export ANTHROPIC_MODEL="moonshotai/Kimi-K2-Instruct"
      export ANTHROPIC_SMALL_FAST_MODEL="moonshotai/Kimi-K2-Instruct" ;;
    multi)                    # ★硅基流动 多槽位映射
      _ccx_sf_common
      export ANTHROPIC_DEFAULT_OPUS_MODEL="zai-org/GLM-5.2"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="GLM-5.2 旗舰"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="强编码/长程推理"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="tools,thinking"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="zai-org/GLM-4.5V"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="GLM-4.5V 多模态"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="看图/GUI/文档视觉"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="vision,tools"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="zai-org/GLM-4.1V-9B-Thinking"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="GLM-4.1V 轻量"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="低成本/快速/可看图"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES="vision,tools"
      export ANTHROPIC_SMALL_FAST_MODEL="zai-org/GLM-4.1V-9B-Thinking"
      export ANTHROPIC_CUSTOM_MODEL_OPTION="Qwen/Qwen3-VL-32B-Instruct"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_NAME="Qwen3-VL 大上下文"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION="262K上下文/多模态"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES="vision,tools" ;;

    # ---------------- 智谱官方 (BigModel) ----------------
    zhipu)                    # ★智谱官方 多槽位映射
      export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
      export ANTHROPIC_AUTH_TOKEN="$ZHIPU_KEY"
      export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"   # 配合 [1m] 1M上下文
      export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="GLM-5.2 旗舰(1M)"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="强编码/长程/1M上下文"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="tools,thinking"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.6"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="GLM-4.6 日常"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="日常编码/更快更省"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="tools"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="GLM-4.7 轻量"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="背景任务/低成本"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES="tools"
      export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7"
      export CLAUDE_CODE_SUBAGENT_MODEL="glm-4.7"
      export ANTHROPIC_CUSTOM_MODEL_OPTION="glm-4.5v"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_NAME="GLM-4.5V 多模态"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION="看图/GUI/文档视觉"
      export ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES="vision,tools" ;;

    # ---------------- DeepSeek 官方 ----------------
    deepseek)                 # ★DeepSeek官方 多槽位映射 (无多模态)
      export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
      export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_KEY"
      export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"   # 配合 [1m] 1M上下文
      export CLAUDE_CODE_EFFORT_LEVEL="max"              # 官方推荐
      export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="DeepSeek-V4-Pro(1M)"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="旗舰/1M/深度推理"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="tools,thinking"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-flash"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="DeepSeek-V4-Flash"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="快/便宜/日常"
      export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="tools"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="DeepSeek-V4-Flash 轻量"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="背景任务"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES="tools"
      export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash"
      export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash" ;;

    # ---------------- 官方 Claude ----------------
    official)                 # 切回官方 Claude 登录(OAuth)
      : ;;
    *) return 1 ;;
  esac
}

ccx() {
  case "$1" in
    ""|status|current)
      echo "当前配置: $(cat "$CCX_CURRENT" 2>/dev/null || echo official)"
      echo "BASE_URL = ${ANTHROPIC_BASE_URL:-<官方登录>}"
      if [ -n "$ANTHROPIC_MODEL" ]; then
        echo "MODEL    = $ANTHROPIC_MODEL"
      elif [ -n "$ANTHROPIC_DEFAULT_OPUS_MODEL" ]; then
        echo "多槽位映射 (进 claude 后用 /model 切换):"
        echo "  Opus   -> $ANTHROPIC_DEFAULT_OPUS_MODEL"
        echo "  Sonnet -> $ANTHROPIC_DEFAULT_SONNET_MODEL"
        echo "  Haiku  -> $ANTHROPIC_DEFAULT_HAIKU_MODEL"
        [ -n "$ANTHROPIC_CUSTOM_MODEL_OPTION" ] && echo "  自定义 -> $ANTHROPIC_CUSTOM_MODEL_OPTION"
      else
        echo "MODEL    = <官方默认>"
      fi ;;
    list)
      echo "硅基流动:    glm  glmv(多模态)  kimi  multi(映射)"
      echo "智谱官方:    zhipu(映射)"
      echo "DeepSeek官方: deepseek(映射)"
      echo "官方Claude:  official"
      echo "当前:        $(cat "$CCX_CURRENT" 2>/dev/null || echo official)" ;;
    glm|glmv|kimi|multi|zhipu|deepseek|official)
      _ccx_clear
      _ccx_apply "$1"
      mkdir -p "$CCX_DIR"; echo "$1" > "$CCX_CURRENT"
      # 缺 Key 提醒
      case "$1" in
        glm|glmv|kimi|multi) [ -z "$SILICONFLOW_KEY" ] && echo "⚠️  未设置 SILICONFLOW_KEY，请编辑 $CCX_KEYFILE" ;;
        zhipu)               [ -z "$ZHIPU_KEY" ]       && echo "⚠️  未设置 ZHIPU_KEY，请编辑 $CCX_KEYFILE" ;;
        deepseek)            [ -z "$DEEPSEEK_KEY" ]    && echo "⚠️  未设置 DEEPSEEK_KEY，请编辑 $CCX_KEYFILE" ;;
      esac
      echo "✅ 已切换到: $1   (重启 claude 生效)" ;;
    help|-h|--help)
      echo "ccx v$CCX_VERSION  —  Claude Code 供应商/模型映射切换器"
      echo "用法: ccx <模式|命令>"
      echo
      ccx list
      echo
      echo "命令: list(列表)  status(当前)  version(版本)  help(帮助)"
      echo "切换后需重启 claude 生效。Key 配置: $CCX_KEYFILE" ;;
    version|-v|--version)
      echo "ccx (claude-provider-switch) v$CCX_VERSION" ;;
    *)
      echo "未知参数: $1"
      echo "用法: ccx [glm|glmv|kimi|multi|zhipu|deepseek|official|list|status|help]" ; return 1 ;;
  esac
}

# 新终端自动套用上次选择
if [ -f "$CCX_CURRENT" ]; then
  _ccx_apply "$(cat "$CCX_CURRENT" 2>/dev/null)" 2>/dev/null
fi
