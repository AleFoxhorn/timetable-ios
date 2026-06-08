# AGENTS

## 关于本文件
本文件是本项目的 Agent 执行手册。
当收到功能实现请求时，按本文件定义的流程执行，不得跳过步骤，不得自行猜测缺失信息。

## 路径配置

```
Skills目录：      /Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/SKILLS/
文档目录：        /Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/
工程目录：        /Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/
组件目录：        /Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/timetable/Components/
界面目录：        /Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/timetable/Screens/
DesignSystem目录：/Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/timetable/DesignSystem/
COMPONENT_CONTRACTS：/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/COMPONENT_CONTRACTS.md
```

---

## 信息收集规则

**在任何阶段需要向用户提问时，必须把所有问题整理成一个编号列表，一次性发出，等用户全部回答后再继续执行。禁止边执行边单独提问。**

---

## 沟通规则

### 生成过程中
生成任何文档的过程中，遇到以下情况必须暂停，将问题加入当前问题列表，等用户回答后再继续：
- 用户描述中有歧义，有多种合理解读
- 涉及设计决策（比如某个字段是否必填、某个行为的边界条件）
- 发现当前描述和已有文档存在潜在冲突

不允许自己猜测一个答案填进文档，必须问用户确认。

### 待确认项自检规则
每份文档生成完成后，agent必须重新读一遍自己生成的内容，主动检查以下问题：
- 是否有分支的边界条件没有定义清楚？
- 是否有字段的取值范围或默认值没有明确？
- 是否有和已有文档（ROUTING / DATA_FLOW / MODEL）潜在冲突的地方？
- 是否有用户描述中提到但文档里没有覆盖的情况？
- 是否有「待确认」的设计决策被自己猜测填入了？

自检结果写入文档的「待确认项」章节。如果真的没有待确认项，必须说明自检了哪些方面、为什么判断没有问题，不允许直接写「暂无」。

---

## 阶段状态报告规则

**每完成一个步骤后，必须输出当前状态报告，格式如下：**

```
✅ 已完成：[步骤名]
📍 当前阶段：[阶段一/阶段二] 步骤[X]
⏭ 下一个人工检查点：[检查点名称]
📋 检查点前的任务规划：
  1. [任务一]
  2. [任务二]
  ...
💬 如需调整方向，现在回复；否则回复"继续"。
```

---

## 人工检查点清单

以下是整个流程中需要人工介入确认的节点，agent在到达每个检查点时必须暂停等待确认：

**检查点 P1：ROUTING 文档确认**
- 时机：ROUTING 文件生成完成后
- 人工确认内容：
  - 流程分支是否完整覆盖所有用户操作
  - 组件名和界面名是否与 Figma 一致
  - 待确认项是否都已列出
- 确认通过后继续执行步骤 1-B

**检查点 P2：MODEL 文档确认**
- 时机：MODEL 文件生成完成后
- 人工确认内容：
  - 字段是否完整，类型是否正确
  - 必填/选填规则是否符合预期
  - 关联对象删除规则是否正确
- 确认通过后继续执行步骤 1-C

**检查点 P3：DATA_FLOW 文档确认**
- 时机：DATA_FLOW 文件生成完成后
- 人工确认内容：
  - 分支代号是否与 ROUTING 完全对齐
  - 数据流步骤是否完整、合理
  - 存储方式是否符合预期
- 确认通过后继续执行步骤 1-D

**检查点 P4：COMPONENT_CONTRACTS 更新确认**
- 时机：COMPONENT_CONTRACTS 补全后
- 人工确认内容：
  - 新增组件的层级分类是否正确
  - 输入字段是否完整
  - Figma节点ID是否都已填写
- 确认通过后继续执行步骤 1-E

**检查点 P5：Token 提取确认**
- 时机：DesignSystem token 提取完成后
- 人工确认内容：
  - Token 命名是否规范
  - 是否有缺失的 token
- 确认通过后进入阶段二

**检查点 P6：每个组件视觉验收**
- 时机：每个组件 Swift 实现完成并截图后
- 人工确认内容：
  - 颜色、字体、间距、圆角是否与 Figma 一致
  - 层级关系是否正确
- 确认通过后继续下一个组件

**检查点 P7：界面组装确认**
- 时机：所有组件实现完成，界面组装后
- 人工确认内容：
  - 界面整体布局是否与 Figma 一致
  - 组件组合关系是否正确
- 确认通过后进行流程验收

**检查点 P8：流程验收确认**
- 时机：所有分支流程测试完成后
- 人工确认内容：
  - 所有分支跳转是否正确
  - 数据操作是否符合 DATA_FLOW 定义
  - 错误提示是否在正确时机出现
- 确认通过后输出完成报告

遇到以下情况时，必须立即暂停并报告，不得自行猜测继续：

- Figma节点ID找不到对应组件
- COMPONENT_CONTRACTS中缺少某个组件的定义
- Swift文件路径不存在
- 视觉验收连续失败超过3次
- 任何步骤的输入文件不存在

报告格式：
```
⚠️ 暂停原因：[说明具体是什么问题]
需要人工处理：[说明需要用户做什么]
处理完成后回复"继续"以恢复执行。
```

---

## 触发方式

用户说以下类似的话时，进入对应阶段：

- "帮我实现XX功能" / "我要做XX界面" → 进入【阶段判断】
- "继续" → 从上次暂停处恢复执行
- "跳过验收" → 跳过当前组件的视觉验收，继续下一个
- "重新验收" → 对当前组件重新截图并验收

---

## 阶段判断

收到功能实现请求后，按以下顺序逐项检查当前状态，**每一步只执行尚未完成的部分，已完成的直接跳过**。

```
检查1：文档目录下是否有 ROUTING_[功能].md
  → 不存在：执行步骤 1-A
  → 已存在：跳过步骤 1-A

检查2：文档目录下是否有对应的 [对象]_MODEL.md
  → 不存在：从 ROUTING 文件中提取涉及的数据对象，执行步骤 1-B
  → 已存在：跳过步骤 1-B

检查3：文档目录下是否有 DATA_FLOW_[功能].md
  → 不存在：执行步骤 1-C
  → 已存在：跳过步骤 1-C

检查4：COMPONENT_CONTRACTS 是否已包含本次功能涉及的所有组件
  → 有缺失：执行步骤 1-D（只补充缺失组件，不覆盖已有）
  → 已完整：跳过步骤 1-D

检查5：本次功能涉及的组件，DesignSystem token 是否已提取
  → 有缺失：执行步骤 1-E
  → 已完整：跳过步骤 1-E

检查6：本次功能涉及的组件，Swift 文件是否已存在
  → 全部存在：跳过步骤 2-B，直接进入步骤 2-C
  → 部分存在：只对缺失的组件执行步骤 2-B
  → 全部缺失：完整执行步骤 2-B
```

完成所有检查后，报告当前状态：
```
📋 当前状态：
- ROUTING文件：已有 / 待建
- MODEL文件：已有 / 待建
- DATA_FLOW文件：已有 / 待建
- COMPONENT_CONTRACTS：完整 / 缺少[N]个组件
- DesignSystem token：完整 / 缺少[N]个
- Swift组件文件：[N]个已有 / [N]个待建
→ 即将从步骤[X]开始执行
```

确认无误后开始执行。

---

## 阶段一：文档建立

### 步骤 1-A：建立 ROUTING 文件（如缺失）

读取 Skill：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/SKILLS/SKILL_ROUTING.md`

读取范例：
- `/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/ROUTING_COURSE.md`
- `/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/ROUTING_EVENT.md`

按 Skill 规则，一次性收集所有需要的信息，生成：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/ROUTING_[功能].md`

验收条件：
- 所有组件名用反引号包裹且全文一致
- 每个分支有触发条件、系统行为、返回页面、结果
- 待确认项全部列出

---

### 步骤 1-B：建立 MODEL 文件（如缺失）

说明：
ROUTING 文件建立后，从中提取本次功能涉及的核心数据对象，再建立对应的 MODEL 文件。

读取 Skill：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/SKILLS/SKILL_MODEL.md`

按 Skill 规则，一次性收集所有需要的信息，生成：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/[对象名]_MODEL.md`

验收条件：
- 所有字段有类型、作用、必填/选填标注
- 结构化字段和派生展示字段分开列出
- 关联对象删除规则明确

---

### 步骤 1-C：建立 DATA_FLOW 文件（如缺失）

读取 Skill：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/SKILLS/SKILL_DATAFLOW.md`

读取范例：
- `/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/DATA_FLOW_COURSE.md`
- `/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/DATA_FLOW_EVENT.md`

按 Skill 规则生成：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/DATA_FLOW_[功能].md`

验收条件：
- 分支代号与 ROUTING 文件完全对齐
- 每个分支数据流步骤使用具体组件名/Repository名
- 展示刷新规则完整

---

### 步骤 1-D：更新 COMPONENT_CONTRACTS（如有新组件）

读取 Skill：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/SKILLS/SKILL_COMPONENT.md`

读取现有文件：
`/Users/zhangxing/Documents/New project 3/docs/UXdesigndocs/COMPONENT_CONTRACTS.md`

规则：
- 只增量补充新功能涉及的组件
- 不覆盖已有组件定义
- 按层级顺序补充：基础组件 → Section组件 → 界面

验收条件：
- 新功能涉及的所有组件都有完整定义
- 格式与现有组件一致
- Figma节点字段已填写或标注「待填充」

---

### 步骤 1-E：提取 DesignSystem Token（如有新组件）

对本次功能涉及的所有新组件，从 Figma MCP 提取：
- 颜色 token
- 字体 token
- 间距 token
- 圆角 token

检查 DesignSystem 目录下是否已有对应 token：
`/Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/timetable/DesignSystem/`

如缺少 token，先补充 token 文件，再继续。

---

## 阶段二：代码实现

### 步骤 2-A：读取所有相关文档

按顺序读取：
1. `[对象]_MODEL.md` — 确认数据字段
2. `ROUTING_[功能].md` — 确认页面流程
3. `DATA_FLOW_[功能].md` — 确认数据操作
4. `COMPONENT_CONTRACTS.md` — 确认组件定义和层级

从 COMPONENT_CONTRACTS 中提取本次功能涉及的组件列表，按层级排序：
```
基础组件（第一批实现）
Section组件（第二批实现）
界面（最后实现）
```

---

### 步骤 2-B：逐组件实现

对每个组件，按以下子步骤执行：

**子步骤 B1：检查组件是否已存在**
扫描组件目录：
`/Users/zhangxing/Documents/New project 3/UXDESIGN/timetable/timetable/Components/`

- 如果 Swift 文件已存在且功能完整 → 跳过，标记为「已有」
- 如果 Swift 文件已存在但需要修改 → 进入修改流程
- 如果 Swift 文件不存在 → 进入新建流程

**子步骤 B2：从 Figma MCP 读取视觉数值**
使用 COMPONENT_CONTRACTS 中的 Figma节点 字段定位组件。
读取该组件的完整视觉数值，包括子元素细节。

如果 Figma节点 字段为「待填充」：
→ 触发报错，暂停并请求人工提供节点ID

**子步骤 B3：实现 Swift 代码**
依据：
- COMPONENT_CONTRACTS 中该组件的输入、视觉、输出事件、职责边界
- Figma MCP 读取的实际数值
- DesignSystem 中已有的 token

生成或修改 Swift 文件，保存到对应目录。

**子步骤 B4：视觉验收**
在模拟器中截图，与 Figma 设计稿对比。

对比项目：
- 颜色
- 字体和字重
- 间距和 padding
- 圆角
- 边框
- 层级关系

**验收通过** → 标记该组件为「已完成」，继续下一个组件

**验收不通过** → 列出具体偏差项，修复后重新截图，最多重试3次

**3次仍不通过** → 触发报错，暂停并报告偏差详情，等待人工处理

---

### 步骤 2-C：界面组装

所有基础组件和 Section 组件验收通过后，开始组装界面。

按 ROUTING 文件中的界面定义，将组件组合成完整界面。
按 DATA_FLOW 文件，接入 ViewModel 和 Repository。

每个界面组装完成后，同样进行视觉验收。

---

### 步骤 2-D：流程验收

所有界面组装完成后，按 ROUTING 文件走完所有分支流程：

- 逐个测试每个分支（A1、A2、B1……）
- 确认页面跳转正确
- 确认数据操作符合 DATA_FLOW 定义
- 确认错误提示在正确时机出现

**全部通过** → 输出完成报告，请求人工确认

**有分支不通过** → 报告具体哪个分支失败，等待人工处理

---

## 完成报告格式

```
✅ 功能实现完成：[功能名]

已实现组件：
- [组件名] — 新建 / 修改 / 已有
- ...

已实现界面：
- [界面名]
- ...

验收结果：
- 视觉验收：通过 / [N]个组件有偏差（已记录）
- 流程验收：全部分支通过 / [具体分支]有问题

待人工确认：
- [需要人工检查的事项]
```

---

## 当前项目 Skills 清单

```
SKILL_MODEL.md      → 生成/更新 MODEL 文件
SKILL_ROUTING.md    → 生成 ROUTING 文件
SKILL_DATAFLOW.md   → 生成 DATA_FLOW 文件
SKILL_COMPONENT.md  → 更新 COMPONENT_CONTRACTS（待完成）
```
