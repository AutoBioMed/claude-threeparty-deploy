# 更新日志

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-07-06
### 新增
- 智谱官方 (BigModel) 多槽位映射模式 `ccx zhipu`（GLM-5.2/4.6/4.7/4.5V）
- DeepSeek 官方 多槽位映射模式 `ccx deepseek`（V4-Pro/V4-Flash）
- `ccx help` / `ccx version` 命令
- `LICENSE`、`.gitignore`、`CHANGELOG.md`

### 变更
- `keys.env` 支持三家独立 Key：`SILICONFLOW_KEY` / `ZHIPU_KEY` / `DEEPSEEK_KEY`
- 切换时清理新增的 `CLAUDE_CODE_*` 控制变量，避免供应商间串味

## [1.0.0] - 2026-07-05
### 新增
- 无 GUI / 无 sudo 的 Claude Code 供应商切换器 `ccx`
- 硅基流动单模型模式：`glm` / `glmv` / `kimi`
- 硅基流动多槽位映射模式 `multi`，支持会话内 `/model` 实时切换与多模态 (vision)
- 一键安装/卸载脚本、README、图文版 HTML 指南
