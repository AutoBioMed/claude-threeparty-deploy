# ccx · Claude Code 多供应商 / 多模型切换器

> 一个让 **Claude Code 命令行**接入国产大模型（硅基流动 / 智谱 / DeepSeek）的小工具。
> 无需 GUI、无需 sudo，一条命令即可在多个模型、多模态之间自由切换。

![shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-89e051)
![platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)
![license](https://img.shields.io/badge/license-MIT-blue)
![version](https://img.shields.io/badge/version-1.1.0-orange)

---

## 这是什么？

[Claude Code](https://claude.ai) 是 Anthropic 官方的命令行编程助手，默认只能用 Claude 模型（需付费登录、且国内访问不便）。

本工具通过设置几个环境变量，把 Claude Code「接管」到**国产大模型**上，让你用更低的成本、国内网络直连，享受同样的命令行编程体验。核心是一个自制切换器 `ccx`，帮你一键切换供应商和模型。

## 功能与特点

- ✅ **一键接入三家供应商**：硅基流动 (SiliconFlow) / 智谱官方 (BigModel) / DeepSeek 官方，用 `ccx <名字>` 随时切换。
- ✅ **会话内多模型切换**：进入 `claude` 后用 `/model` 在多个模型间实时切换，**无需重启**。
- ✅ **多模态（看图）支持**：内置视觉模型映射，可直接分析截图、图片、网页 / GUI 界面。
- ✅ **多槽位智能映射**：把 Claude 的 Opus / Sonnet / Haiku 三个「槽位」分别映射到最合适的模型（旗舰推理 / 多模态 / 便宜快速），各司其职。
- ✅ **零依赖、免 sudo、免 GUI**：纯 bash 脚本，服务器 / SSH / 无桌面环境都能用。
- ✅ **自动记忆**：新开终端自动恢复你上次选择的供应商，不用重设。
- ✅ **随时切回官方**：一句 `ccx official` 回到官方 Claude 登录。

> **原理**：Claude Code 走 Anthropic Messages API 协议，上述供应商都提供了 **Anthropic 兼容端点**，
> 所以只需设置几个环境变量即可直连，无需任何协议转换代理。

---

## 目录结构

```
claude-siliconflow-deploy/
├── install.sh                      # 一键安装(装 claude + 部署切换器 + 写 Key)
├── uninstall.sh                    # 卸载切换器(不动 claude 本体)
├── ccx.sh                          # 切换器主脚本(被部署到 ~/.config/claude-switch/)
├── keys.env.example                # API Key 模板
├── README.md                       # 本文档
└── claude_siliconflow_配置指南.html # 图文版说明(浏览器打开)
```

---

## 快速开始（3 步）

```bash
# 1. 进入本文件夹
cd claude-siliconflow-deploy

# 2. 运行安装脚本(会引导你安装 claude、部署切换器、填 Key)
bash install.sh

# 3. 新开终端后
ccx multi     # 选择多模型映射模式
claude        # 启动，进入后用 /model 切换模型
```

---

## 第 1 步：安装 Claude Code CLI

`install.sh` 会自动尝试安装。若失败或想手动安装，任选一种：

### 方式 A：官方安装脚本（推荐，免 Node）
```bash
curl -fsSL https://claude.ai/install.sh | bash
# 安装到 ~/.local/bin，确保它在 PATH 中：
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

### 方式 B：npm 全局安装（需 Node.js ≥ 18）
```bash
npm install -g @anthropic-ai/claude-code
```

**如果没有 Node.js**，按发行版安装：
```bash
# Ubuntu / Debian
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs
# Fedora / RHEL
sudo dnf install -y nodejs
# Arch
sudo pacman -S nodejs npm
# macOS (Homebrew)
brew install node
```

验证：
```bash
claude --version
```

---

## 第 2 步：获取 API Key（只需注册要用的那家）

到对应供应商官网注册账号，创建一个 API Key（一串通常以 `sk-` 开头的字符串），**复制**下来备用：

| 供应商 | 对应 ccx 模式 | 获取地址 |
|---|---|---|
| 硅基流动 SiliconFlow | glm / glmv / kimi / multi | <https://cloud.siliconflow.cn/account/ak> |
| 智谱 BigModel | zhipu | <https://open.bigmodel.cn/usercenter/apikeys> |
| DeepSeek | deepseek | <https://platform.deepseek.com/api_keys> |

> 只需注册你打算用的那一家即可，其余可留空。新用户通常都有免费额度，注册后在「API Keys / 密钥管理」页面点击「新建」即可拿到。

---

## 第 3 步：把 Key 填进配置文件

拿到 Key 后，要把它写进配置文件 `~/.config/claude-switch/keys.env`，`ccx` 启动时才会读到它。

> 小知识：`~` 代表你的用户主目录（如 `/home/xx03`）。这个文件在第 1 步安装时由 `install.sh` 自动创建，权限为 `600`（仅本人可读，安全）。

下面三种方法**任选一种**：

### 方法 A：用 Cursor / 编辑器打开填写（直观，推荐）

1. 在 Cursor 里按 `Ctrl+O`（或菜单 File → Open File），在路径栏粘贴下面这行后回车：

```
~/.config/claude-switch/keys.env
```

如果打不开，就用完整路径（把 `你的用户名` 换成实际的，例如 `xx03`）：

```
/home/你的用户名/.config/claude-switch/keys.env
```

2. 找到你要用的那一行，把**引号里的占位文字**替换成你复制的真实 Key。例如用硅基流动：

```bash
# 改之前（占位）
SILICONFLOW_KEY="sk-在此粘贴你的硅基流动Key"
# 改之后（换成你的真实 Key）
SILICONFLOW_KEY="sk-abcd1234你复制来的真实key"
```

3. 按 `Ctrl+S` 保存。没用到的那几家保持原样或留空都行。

### 方法 B：用命令行编辑器填写（服务器 / 无界面）

```bash
nano ~/.config/claude-switch/keys.env
# 改完按 Ctrl+O 回车保存, 再按 Ctrl+X 退出
# 习惯 vim 也可以: vim ~/.config/claude-switch/keys.env
```

### 方法 C：一条命令直接写入（最快，把 sk-xxx 换成你的 Key）

```bash
# 硅基流动
sed -i 's#^SILICONFLOW_KEY=.*#SILICONFLOW_KEY="sk-xxx"#' ~/.config/claude-switch/keys.env
# 智谱
sed -i 's#^ZHIPU_KEY=.*#ZHIPU_KEY="你的智谱key"#'        ~/.config/claude-switch/keys.env
# DeepSeek
sed -i 's#^DEEPSEEK_KEY=.*#DEEPSEEK_KEY="sk-xxx"#'       ~/.config/claude-switch/keys.env
```

配置文件本身长这样，把每行引号内的占位内容换成真实 Key 即可：

```bash
# 硅基流动 (glm / glmv / kimi / multi 使用)
SILICONFLOW_KEY="sk-在此粘贴你的硅基流动Key"
# 智谱官方 BigModel (zhipu 使用)
ZHIPU_KEY="在此粘贴你的智谱Key"
# DeepSeek 官方 (deepseek 使用)
DEEPSEEK_KEY="sk-在此粘贴你的DeepSeekKey"
```

### 确认填对了

```bash
# ① 查看文件内容, 确认 Key 已写入
cat ~/.config/claude-switch/keys.env

# ② 测试硅基流动 Key 是否有效(能列出一堆模型 = Key 正常)
source ~/.config/claude-switch/keys.env
curl -s -H "Authorization: Bearer $SILICONFLOW_KEY" \
     https://api.siliconflow.cn/v1/models | head -c 200; echo
```

> ⚠️ **常见坑：**
> - Key 两边的**英文双引号别删**；`=` 两边**不要留空格**。
> - 从网页复制时注意**别多带进空格或换行**。
> - 改完 Key 后，若 `claude` 正在运行，需**退出重开**才生效。

> 关于服务器地址：硅基流动默认用国内站 `https://api.siliconflow.cn`；智谱默认用 BigModel `open.bigmodel.cn`。若要改用国际站（如智谱 Z.ai），见下文「自定义 / 增删模型」。

---

## 第 4 步：使用 ccx 切换器

安装后**新开一个终端**（或 `source ~/.bashrc`），即可用 `ccx`：

| 命令 | 供应商 | 说明 |
|---|---|---|
| `ccx list` | — | 列出所有模式和当前选择 |
| `ccx glm` | 硅基流动 | 单模型：GLM-5.2（已核实可用） |
| `ccx glmv` | 硅基流动 | 单模型：GLM-4.5V 多模态（看图） |
| `ccx kimi` | 硅基流动 | 单模型：Kimi |
| `ccx multi` | 硅基流动 | **多槽位映射**，`/model` 实时切换 |
| `ccx zhipu` | 智谱官方 | **多槽位映射**（GLM-5.2/4.6/4.7/4.5V） |
| `ccx deepseek` | DeepSeek官方 | **多槽位映射**（V4-Pro/Flash，无视觉） |
| `ccx official` | 官方Claude | 切回官方登录（OAuth） |
| `ccx status` | — | 查看当前 BASE_URL / 模型 / 槽位映射 |

选好模式后运行 `claude` 即生效。**新终端会自动记住上次选择。**

---

## 核心功能：会话内多模型 + 多模态映射

Claude Code 运行时是**多模型协作**：主推理模型 + 后台小模型。它支持把
Opus / Sonnet / Haiku 三个「槽位」各映射到不同模型，并可声明能力（如 `vision` 视觉）。

`ccx multi` 一次配好如下映射：

| Claude 槽位 | 硅基流动模型 | 用途 | 能力 |
|---|---|---|---|
| **Opus** | `zai-org/GLM-5.2` | 旗舰编码 / 长程推理 | tools, thinking |
| **Sonnet** | `zai-org/GLM-4.5V` | **多模态 / 看图 / GUI / 文档** | **vision**, tools |
| **Haiku** | `zai-org/GLM-4.1V-9B-Thinking` | 便宜快速 / 背景任务（也能看图） | **vision**, tools |
| **自定义项** | `deepseek-ai/DeepSeek-V4-Pro` | 旗舰 / 深度推理（无视觉） | tools, thinking |

用法：
```bash
ccx multi
claude
# 进入会话后：
/model          # 弹出菜单，在 GLM-5.2 / GLM-4.5V / GLM-4.1V / DeepSeek-V4-Pro 间实时切换
```

**多模态**：需要看图/截图分析时，用 `/model` 切到 **Sonnet(GLM-4.5V)**（已标 `vision`，可直接接收图片）；需要更强的纯代码/深度推理时切到自定义项 **DeepSeek-V4-Pro**（无视觉）；日常纯代码切回 **Opus(GLM-5.2)**；背景小任务由 Haiku(GLM-4.1V) 自动承担。

### 怎么确认在用多个模型？
- `/model` 菜单显示的是 **GLM/Qwen 名字**（不是 Opus 4.7 / Sonnet 4.6）→ 映射已生效
- 终端 `ccx status` → 打印四个槽位各自映射的模型
- 硅基流动控制台「用量/账单」→ 能看到对 GLM-5.2、GLM-4.1V 等的真实调用记录

> ⚠️ 连着硅基流动时，`/model` 里若出现 Anthropic 原生名（Opus/Sonnet/Haiku 且未被映射改名），**别选**——硅基流动没有这些模型，会报错。`multi` 模式下这些名字会被替换成 GLM/Qwen，选它们即安全。

---

## 智谱官方 / DeepSeek 官方 映射

除了硅基流动，还内置了两家**官方直连**（各自独立端点与 Key），同样是多槽位映射，进 claude 后用 `/model` 切换。

### `ccx zhipu` — 智谱官方 (BigModel)
端点 `https://open.bigmodel.cn/api/anthropic`，Key = `ZHIPU_KEY`

| Claude 槽位 | 模型 | 用途 | 能力 |
|---|---|---|---|
| Opus | `glm-5.2[1m]` | 旗舰编码/长程/1M 上下文 | tools, thinking |
| Sonnet | `glm-4.6` | 日常编码/更快更省 | tools |
| Haiku | `glm-4.7` | 背景任务/低成本 | tools |
| 自定义 | `glm-4.5v` | **多模态/看图/GUI** | **vision**, tools |

> `[1m]` 后缀开启 1M 上下文（脚本已同时设 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000`）。若提示模型不存在，请 `claude update` 升级到最新版。

### `ccx deepseek` — DeepSeek 官方
端点 `https://api.deepseek.com/anthropic`，Key = `DEEPSEEK_KEY`

| Claude 槽位 | 模型 | 用途 | 能力 |
|---|---|---|---|
| Opus | `deepseek-v4-pro[1m]` | 旗舰/1M/深度推理 | tools, thinking |
| Sonnet | `deepseek-v4-flash` | 快/便宜/日常 | tools |
| Haiku | `deepseek-v4-flash` | 背景任务 | tools |

> **DeepSeek 无多模态**，无法看图；需要视觉请用 `zhipu`(GLM-4.5V) 或硅基流动 `multi`。
> 脚本已按官方建议设 `CLAUDE_CODE_EFFORT_LEVEL=max`。旧模型名 `deepseek-chat/reasoner` 已于 2026-07-24 弃用。

用法一致：
```bash
ccx zhipu      # 或 ccx deepseek
claude
/model         # 在该家的模型间实时切换
```

---

## 验证连通性

```bash
source ~/.config/claude-switch/keys.env
curl -s -H "Authorization: Bearer $SILICONFLOW_KEY" \
     https://api.siliconflow.cn/v1/models | head -c 300; echo
# 能列出模型 = Key 正常
```

---

## 自定义 / 增删模型

编辑 `~/.config/claude-switch/ccx.sh`：
- **加单模型模式**：在 `_ccx_apply()` 的 `case` 里仿照 `glm)` 加一段，并把新名字加进
  `ccx()` 里 `glm|glmv|deepseek|kimi|multi|official)` 那行。
- **改多槽位映射**：编辑 `multi)` 段，把某个槽位换成别的模型 ID。
- **模型 ID** 到 <https://www.siliconflow.cn/models> 复制准确 slug。
  已核实：`zai-org/GLM-5.2`、`zai-org/GLM-4.5V`。若报 `model not found` 即改这里。

改完 `source ~/.bashrc` 或新开终端生效。

---

## 常见问题

| 现象 | 原因 / 解决 |
|---|---|
| `ccx: command not found` | 没新开终端。执行 `source ~/.bashrc`，或确认 install 已挂载到 rc 文件 |
| `/model` 显示 Opus 4.7 等原生名 | 没进 multi 模式。退出 claude → `ccx multi` → 重开 `claude` |
| 调用报 401 / 鉴权失败 | Key 没填或填错。编辑 `~/.config/claude-switch/keys.env` |
| 调用报 `model not found` | 模型 slug 变了，到模型页核对后改 `ccx.sh` |
| 想临时用回官方 Claude | `ccx official` 后重启 claude（走 OAuth 登录） |
| 改了配置不生效 | 正在运行的 claude 不会热更新，需退出重启 |

---

## 卸载

```bash
bash uninstall.sh        # 移除切换器与 shell 挂载(可选删 Key)，不动 claude 本体
```

---

## 安全提示

- `keys.env` 内是**明文 API Key**，已设 `chmod 600`（仅本人可读）。
- **切勿**把 `keys.env` 提交到 Git 或分享给他人（本仓库 `.gitignore` 已默认忽略它）。
- 换机部署时**只拷贝本文件夹**（不含 keys.env），到新机重新填 Key。

---

## 从 GitHub 一键安装（发布后）

```bash
git clone https://github.com/<你的用户名>/<仓库名>.git
cd <仓库名>
bash install.sh
```

---

## 许可证

[MIT](LICENSE) © 2026 xx03
