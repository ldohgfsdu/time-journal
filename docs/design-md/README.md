# Design system source (awesome-design-md)

## 仓库

- 官方集合：https://github.com/VoltAgent/awesome-design-md  
- 本机克隆：`/root/code/awesome-design-md`（shallow clone，**不进** time-journal git）

## 项目选型（Grok 2026-07-09）

**已选用：Claude** → 仓库根目录 `DESIGN.md`

依据（time-journal 产品）：
- 低压力时间手账、纸质暖色、克制、温和
- 现有主题已是 Claude 暖纸色板（paper `#FAF6EF` / tomato `#C45C4A` 接近 coral）
- Claude DESIGN.md：cream canvas + warm coral + editorial，与「手账感」一致

**备选：Notion**（`docs/design-md/notion.DESIGN.md`）
- 暖色极简、软表面、工作区/笔记感
- 若希望更「中性灰暖 + 衬线标题」可切换

**不推荐（对本产品）：**
- Vercel / Linear / Stripe 偏冷、科技、高对比，易把产品拉成工具台
- 暗色 crypto / terminal 系与手账气质冲突

## 给 Claude Code / 其他 Agent

1. 读根目录 `DESIGN.md`（Claude 规范）
2. 改 UI 时对齐 tokens，**不要**大范围重做成另一套品牌
3. 换规范：从 `/root/code/awesome-design-md/design-md/<brand>/DESIGN.md` 复制覆盖根目录 `DESIGN.md`，并更新本 README
