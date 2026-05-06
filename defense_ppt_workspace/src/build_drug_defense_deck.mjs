const fs = await import("node:fs/promises");
const {
  Presentation,
  PresentationFile,
  row,
  column,
  grid,
  layers,
  panel,
  text,
  shape,
  rule,
  fill,
  hug,
  fixed,
  wrap,
  grow,
  fr,
} = await import("@oai/artifact-tool");

const W = 1920;
const H = 1080;
const C = {
  ink: "#13231E",
  muted: "#5C6F68",
  faint: "#E8F1EE",
  canvas: "#F7FAF8",
  white: "#FFFFFF",
  green: "#1F7A5A",
  teal: "#1F9AA0",
  blue: "#2563A8",
  amber: "#D8912B",
  red: "#C94A4A",
  dark: "#0E2A25",
};

const font = "Microsoft YaHei";
const mono = "Consolas";

const presentation = Presentation.create({
  slideSize: { width: W, height: H },
});

function bg(slide, color = C.canvas) {
  slide.compose(
    layers(
      { name: "background", width: fill, height: fill },
      [
        shape({ name: "canvas", shape: "rect", x: 0, y: 0, width: W, height: H, fill: color, stroke: "transparent" }),
        shape({ name: "top-rule", shape: "rect", x: 0, y: 0, width: W, height: 12, fill: C.green, stroke: "transparent" }),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function titleBlock(title, subtitle = "") {
  return column(
    { name: "title-stack", width: fill, height: hug, gap: 14 },
    [
      text(title, {
        name: "slide-title",
        width: wrap(1640),
        height: hug,
        style: { fontFace: font, fontSize: 50, bold: true, color: C.ink, lineHeight: 1.08 },
      }),
      subtitle
        ? text(subtitle, {
            name: "slide-subtitle",
            width: wrap(1320),
            height: hug,
            style: { fontFace: font, fontSize: 24, color: C.muted, lineHeight: 1.2 },
          })
        : null,
    ].filter(Boolean),
  );
}

function footer(label = "计算机221-25号 余梓杰 | 基于 Spring Boot 的药品追溯监管系统") {
  return text(label, {
    name: "footer",
    width: fill,
    height: hug,
    style: { fontFace: font, fontSize: 14, color: "#7B8B86" },
  });
}

function capsule(label, color = C.green) {
  return panel(
    {
      name: `capsule-${label}`,
      width: hug,
      height: hug,
      padding: { x: 18, y: 8 },
      fill: color,
      borderRadius: 999,
    },
    text(label, {
      name: `capsule-text-${label}`,
      width: hug,
      height: hug,
      style: { fontFace: font, fontSize: 18, bold: true, color: C.white },
    }),
  );
}

function metric(label, value, color) {
  return column(
    { name: `metric-${label}`, width: fill, height: hug, gap: 4 },
    [
      text(value, {
        name: `metric-value-${label}`,
        width: fill,
        height: hug,
        style: { fontFace: font, fontSize: 46, bold: true, color },
      }),
      text(label, {
        name: `metric-label-${label}`,
        width: fill,
        height: hug,
        style: { fontFace: font, fontSize: 18, color: C.muted },
      }),
    ],
  );
}

function node(label, color, w = 220) {
  return panel(
    {
      name: `node-${label}`,
      width: fixed(w),
      height: fixed(72),
      fill: C.white,
      stroke: color,
      strokeWidth: 2,
      borderRadius: 16,
      padding: { x: 16, y: 14 },
    },
    text(label, {
      name: `node-text-${label}`,
      width: fill,
      height: hug,
      style: { fontFace: font, fontSize: 22, bold: true, color, align: "center" },
    }),
  );
}

function arrow(label = "") {
  return column(
    { name: `arrow-${label}`, width: fixed(92), height: fixed(72), gap: 4 },
    [
      text("→", {
        name: `arrow-symbol-${label}`,
        width: fill,
        height: hug,
        style: { fontFace: "Arial", fontSize: 42, bold: true, color: C.muted, align: "center" },
      }),
      label
        ? text(label, {
            name: `arrow-label-${label}`,
            width: fill,
            height: hug,
            style: { fontFace: font, fontSize: 12, color: C.muted, align: "center" },
          })
        : null,
    ].filter(Boolean),
  );
}

function addCover() {
  const slide = presentation.slides.add();
  bg(slide, C.dark);
  slide.compose(
    shape({ name: "cover-right-field", shape: "rect", width: fill, height: fill, fill: "#DDEFE8", stroke: "transparent" }),
    { frame: { left: 1320, top: 0, width: 600, height: H }, baseUnit: 8 },
  );
  slide.compose(
    shape({ name: "cover-band", shape: "rect", width: fill, height: fill, fill: "#163E36", stroke: "transparent" }),
    { frame: { left: 0, top: 768, width: 1320, height: 118 }, baseUnit: 8 },
  );
  slide.compose(
    shape({ name: "thin-accent", shape: "rect", width: fill, height: fill, fill: C.amber, stroke: "transparent" }),
    { frame: { left: 122, top: 168, width: 180, height: 10 }, baseUnit: 8 },
  );

  slide.compose(
    column(
      { name: "cover-copy", width: fixed(1040), height: hug, gap: 28 },
      [
        text("毕业设计答辩", {
          name: "cover-kicker",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 26, color: "#A7D6C6", bold: true },
        }),
        text("基于 Spring Boot 的\n药品追溯监管系统", {
          name: "cover-title",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 78, bold: true, color: C.white, lineHeight: 1.05 },
        }),
        text("围绕“来源可查、去向可追、责任可究”，构建 Web 管理端 + Flutter 移动端 + 后端服务的一体化监管平台。", {
          name: "cover-promise",
          width: wrap(900),
          height: hug,
          style: { fontFace: font, fontSize: 26, color: "#C8DDD6", lineHeight: 1.28 },
        }),
        row({ name: "cover-tags", width: hug, height: hug, gap: 14 }, [
          capsule("Spring Boot", C.green),
          capsule("Vue 3", C.teal),
          capsule("Flutter", C.blue),
          capsule("AI 辅助检索", C.amber),
        ]),
      ],
    ),
    { frame: { left: 122, top: 156, width: 1100, height: 620 }, baseUnit: 8 },
  );

  slide.compose(
    column(
      { name: "cover-meta", width: fixed(520), height: hug, gap: 14 },
      [
        text("计算机221-25号  余梓杰", {
          name: "cover-author",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 26, bold: true, color: C.dark },
        }),
        text("仲恺农业工程学院 人工智能学院", {
          name: "cover-school",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 20, color: "#49635B" },
        }),
        text("5分钟讲解版", {
          name: "cover-duration",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 18, color: "#49635B" },
        }),
      ],
    ),
    { frame: { left: 1350, top: 790, width: 500, height: 160 }, baseUnit: 8 },
  );
}

function addProblemGoal() {
  const slide = presentation.slides.add();
  bg(slide);
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 112, y: 76 }, gap: 38 },
      [
        titleBlock("研究背景与目标", "从数据分散到闭环监管：系统要解决的不只是查询，而是跨角色协同。"),
        grid(
          { name: "problem-goal-grid", width: fill, height: fill, columns: [fr(1), fr(1)], columnGap: 72 },
          [
            column({ name: "left-problems", width: fill, height: fill, gap: 28 }, [
              text("现实问题", {
                name: "problem-heading",
                width: fill,
                height: hug,
                style: { fontFace: font, fontSize: 30, bold: true, color: C.red },
              }),
              ...[
                ["数据分散", "生产、流通、使用环节信息割裂，难以快速拼接责任链。"],
                ["链条不完整", "批次、库存、销售记录若口径不统一，会影响追溯可信度。"],
                ["线索滞后", "公众问题反馈难汇聚，监管处置缺少流程化入口。"],
              ].map(([a, b]) =>
                row({ name: `problem-${a}`, width: fill, height: hug, gap: 18 }, [
                  shape({ name: `dot-${a}`, shape: "ellipse", width: 18, height: 18, fill: C.red, stroke: "transparent" }),
                  column({ name: `problem-copy-${a}`, width: fill, height: hug, gap: 4 }, [
                    text(a, { name: `problem-title-${a}`, width: fill, height: hug, style: { fontFace: font, fontSize: 26, bold: true, color: C.ink } }),
                    text(b, { name: `problem-body-${a}`, width: fill, height: hug, style: { fontFace: font, fontSize: 21, color: C.muted, lineHeight: 1.25 } }),
                  ]),
                ]),
              ),
            ]),
            column({ name: "right-goals", width: fill, height: fill, gap: 28 }, [
              text("设计目标", {
                name: "goal-heading",
                width: fill,
                height: hug,
                style: { fontFace: font, fontSize: 30, bold: true, color: C.green },
              }),
              row({ name: "goal-metrics", width: fill, height: hug, gap: 42 }, [
                metric("来源可查", "查", C.green),
                metric("去向可追", "追", C.teal),
                metric("责任可究", "究", C.amber),
              ]),
              rule({ name: "goal-rule", width: fill, stroke: "#D4E3DE", weight: 2 }),
              text("最终形成“统一认证 + 全链路追溯 + 监管闭环 + 智能辅助”的一体化平台，服务管理员、监管人员、企业、医疗机构与公众用户。", {
                name: "goal-summary",
                width: fill,
                height: hug,
                style: { fontFace: font, fontSize: 25, bold: true, color: C.ink, lineHeight: 1.32 },
              }),
            ]),
          ],
        ),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addArchitecture() {
  const slide = presentation.slides.add();
  bg(slide);
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 100, y: 70 }, gap: 32 },
      [
        titleBlock("系统架构：Web + App + Spring Boot 服务", "论文内容被拆解为四层可讲元素：终端、接口、业务服务、数据与智能支撑。"),
        grid(
          { name: "arch-grid", width: fill, height: fill, columns: [fr(1)], rows: [fr(1), fr(1), fr(1), fr(1)], rowGap: 18 },
          [
            row({ name: "layer-client", width: fill, height: fill, gap: 24 }, [
              node("Vue Web 管理端", C.blue, 300),
              node("Flutter 移动端", C.teal, 300),
              text("多角色入口：管理员 / 监管 / 企业 / 机构 / 公众", { name: "client-note", width: fill, height: hug, style: { fontFace: font, fontSize: 24, color: C.ink, bold: true } }),
            ]),
            row({ name: "layer-api", width: fill, height: fill, gap: 24 }, [
              node("统一 API", C.green, 260),
              node("JWT + RBAC", C.green, 260),
              text("前端控制体验，后端拦截器完成真正授权校验", { name: "api-note", width: fill, height: hug, style: { fontFace: font, fontSize: 24, color: C.ink, bold: true } }),
            ]),
            row({ name: "layer-service", width: fill, height: fill, gap: 18 }, [
              node("药品主数据", C.blue, 220),
              node("生产批次", C.blue, 220),
              node("采购销售库存", C.blue, 250),
              node("监管任务", C.amber, 220),
              node("AI 助手", C.teal, 200),
            ]),
            row({ name: "layer-data", width: fill, height: fill, gap: 24 }, [
              node("MySQL", C.dark, 190),
              node("Redis", C.dark, 190),
              node("审计日志", C.dark, 220),
              text("数据一致性、会话状态、操作留痕共同支撑监管可信度", { name: "data-note", width: fill, height: hug, style: { fontFace: font, fontSize: 24, color: C.ink, bold: true } }),
            ]),
          ],
        ),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addTraceAndLoop() {
  const slide = presentation.slides.add();
  bg(slide);
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 92, y: 70 }, gap: 34 },
      [
        titleBlock("核心业务：一条追溯主链 + 一个监管闭环", "讲解重点：系统不是单表 CRUD，而是围绕批次和线索组织业务流转。"),
        column({ name: "content", width: fill, height: fill, gap: 54 }, [
          column({ name: "trace-chain", width: fill, height: hug, gap: 18 }, [
            text("药品追溯主链", { name: "trace-heading", width: fill, height: hug, style: { fontFace: font, fontSize: 28, bold: true, color: C.blue } }),
            row({ name: "trace-flow", width: fill, height: hug, gap: 10 }, [
              node("药品主数据", C.blue),
              arrow("drug_id"),
              node("生产批次", C.blue),
              arrow("batch_id"),
              node("采购记录", C.blue),
              arrow("batch_id"),
              node("销售记录", C.blue),
              arrow("org+batch"),
              node("库存台账", C.blue),
            ]),
          ]),
          column({ name: "reg-loop", width: fill, height: hug, gap: 18 }, [
            text("监管处置闭环", { name: "loop-heading", width: fill, height: hug, style: { fontFace: font, fontSize: 28, bold: true, color: C.amber } }),
            row({ name: "loop-flow", width: fill, height: hug, gap: 10 }, [
              node("公众举报", C.amber),
              arrow("线索"),
              node("任务派发", C.amber),
              arrow("责任人"),
              node("调查核查", C.amber),
              arrow("结论"),
              node("处罚处置", C.amber),
              arrow("留痕"),
              node("结果归档", C.amber),
            ]),
          ]),
          grid({ name: "evidence-grid", width: fill, height: hug, columns: [fr(1), fr(1), fr(1)], columnGap: 28 }, [
            text("批次是追溯主键：生产、采购、销售、库存围绕 batch_id 聚合。", { name: "proof-1", width: fill, height: hug, style: { fontFace: font, fontSize: 23, color: C.ink, lineHeight: 1.24 } }),
            text("库存写入与流转记录放入事务，避免记录成功但库存未更新。", { name: "proof-2", width: fill, height: hug, style: { fontFace: font, fontSize: 23, color: C.ink, lineHeight: 1.24 } }),
            text("监管任务记录派发、调查、处置时间点，满足流程复盘。", { name: "proof-3", width: fill, height: hug, style: { fontFace: font, fontSize: 23, color: C.ink, lineHeight: 1.24 } }),
          ]),
        ]),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addImplementationHighlights() {
  const slide = presentation.slides.add();
  bg(slide);
  const rows = [
    ["前端", "Vue 3 + Element Plus", "路由守卫、角色菜单、表格表单、ECharts 看板"],
    ["移动端", "Flutter", "扫码追溯、公众举报、监管现场、AI 问答"],
    ["后端", "Spring Boot + MyBatis-Plus", "Controller / Service / Mapper 分层，事务编排"],
    ["安全", "JWT + RBAC + Redis", "令牌签发、刷新、失效、接口角色拦截"],
    ["治理", "审计日志 + 导入回执", "写操作快照、差异记录、批量数据质量反馈"],
  ];
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 102, y: 70 }, gap: 32 },
      [
        titleBlock("实现亮点：把论文功能落到工程边界", "这页用于答辩时快速说明“我具体做了哪些模块、技术如何对应功能”。"),
        grid(
          { name: "impl-table", width: fill, height: fill, rows: [fixed(64), ...rows.map(() => fixed(96))], columns: [fixed(210), fixed(360), fr(1)], rowGap: 0, columnGap: 0 },
          [
            ...["层面", "关键技术", "实现内容"].map((h, i) =>
              panel({ name: `head-${h}`, fill: C.dark, padding: { x: 18, y: 18 } },
                text(h, { name: `head-text-${h}`, width: fill, height: hug, style: { fontFace: font, fontSize: 22, bold: true, color: C.white, align: i === 0 ? "center" : "left" } })),
            ),
            ...rows.flatMap((r, idx) =>
              r.map((cell, col) =>
                panel(
                  {
                    name: `cell-${idx}-${col}`,
                    fill: idx % 2 === 0 ? "#FFFFFF" : "#EEF6F3",
                    stroke: "#D7E6E1",
                    strokeWidth: 1,
                    padding: { x: 18, y: 18 },
                  },
                  text(cell, {
                    name: `cell-text-${idx}-${col}`,
                    width: fill,
                    height: hug,
                    style: { fontFace: font, fontSize: col === 0 ? 23 : 21, bold: col === 0, color: col === 0 ? C.green : C.ink, lineHeight: 1.18, align: col === 0 ? "center" : "left" },
                  }),
                ),
              ),
            ),
          ],
        ),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addAiAlgorithm() {
  const slide = presentation.slides.add();
  bg(slide);
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 96, y: 70 }, gap: 34 },
      [
        titleBlock("AI与算法：检索增强，减少模型自由发挥", "论文中的 AI 能力，在实现上拆成意图识别、只读查询、事实注入和回答生成。"),
        grid({ name: "ai-grid", width: fill, height: fill, columns: [fr(1.2), fr(0.8)], columnGap: 58 }, [
          column({ name: "ai-flow", width: fill, height: fill, gap: 24 }, [
            row({ name: "ai-step-1", width: fill, height: hug, gap: 16 }, [node("用户问题", C.teal, 190), arrow(), node("意图识别", C.teal, 210), arrow(), node("参数抽取", C.teal, 210)]),
            row({ name: "ai-step-2", width: fill, height: hug, gap: 16 }, [node("只读 SQL", C.blue, 190), arrow(), node("事实结果", C.blue, 210), arrow(), node("Prompt 注入", C.blue, 230)]),
            row({ name: "ai-step-3", width: fill, height: hug, gap: 16 }, [node("大模型生成", C.green, 230), arrow(), node("中文回答", C.green, 210), arrow(), node("会话记录", C.green, 210)]),
            text("关键约束：监管结论仍由人工复核，AI 只做信息检索与表达增强。", {
              name: "ai-caveat",
              width: fill,
              height: hug,
              style: { fontFace: font, fontSize: 25, bold: true, color: C.red, lineHeight: 1.24 },
            }),
          ]),
          column({ name: "rules", width: fill, height: fill, gap: 24 }, [
            text("实现中的规则化检索", { name: "rules-title", width: fill, height: hug, style: { fontFace: font, fontSize: 28, bold: true, color: C.ink } }),
            text("批号：B\\d{6}[A-Z]?", { name: "rule-batch", width: fill, height: hug, style: { fontFace: mono, fontSize: 28, color: C.blue, bold: true } }),
            text("药品编码：RX\\d{6}", { name: "rule-drug", width: fill, height: hug, style: { fontFace: mono, fontSize: 28, color: C.teal, bold: true } }),
            text("关键词：库存 / 风险 / 不良反应 / 追溯 / 药品说明", { name: "rule-keyword", width: fill, height: hug, style: { fontFace: font, fontSize: 24, color: C.ink, lineHeight: 1.28 } }),
            rule({ name: "rules-line", width: fill, stroke: "#D4E3DE", weight: 2 }),
            text("这样做的目的：减少幻觉、保留可追溯事实、让答辩中能讲清算法边界。", {
              name: "rules-summary",
              width: fill,
              height: hug,
              style: { fontFace: font, fontSize: 23, color: C.muted, lineHeight: 1.28 },
            }),
          ]),
        ]),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addTestingSummary() {
  const slide = presentation.slides.add();
  bg(slide);
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 102, y: 70 }, gap: 34 },
      [
        titleBlock("测试与结论", "测试重点不是覆盖所有边角，而是验证核心链路、权限隔离、数据一致性和多端可用性。"),
        grid({ name: "test-grid", width: fill, height: fill, columns: [fr(1), fr(1.05)], columnGap: 62 }, [
          column({ name: "test-left", width: fill, height: fill, gap: 28 }, [
            text("测试覆盖", { name: "test-heading", width: fill, height: hug, style: { fontFace: font, fontSize: 30, bold: true, color: C.green } }),
            ...[
              "登录认证与权限拦截",
              "药品 / 批次 / 采购 / 销售 / 库存",
              "监管任务派发、调查、处置",
              "追溯图谱、统计分析、报表消息",
              "扫码增强、数据交换、AI 问答",
            ].map((item, i) =>
              row({ name: `test-item-${i}`, width: fill, height: hug, gap: 16 }, [
                text(String(i + 1).padStart(2, "0"), { name: `test-no-${i}`, width: fixed(48), height: hug, style: { fontFace: mono, fontSize: 22, bold: true, color: C.amber } }),
                text(item, { name: `test-text-${i}`, width: fill, height: hug, style: { fontFace: font, fontSize: 24, color: C.ink } }),
              ]),
            ),
          ]),
          column({ name: "test-right", width: fill, height: fill, gap: 28 }, [
            text("结论与不足", { name: "result-heading", width: fill, height: hug, style: { fontFace: font, fontSize: 30, bold: true, color: C.blue } }),
            text("系统已能稳定支撑两条主流程：\n“药品主数据—批次—流通—库存”追溯主链；\n“线索上报—任务派发—调查处置—结果归档”监管闭环。", {
              name: "result-main",
              width: fill,
              height: hug,
              style: { fontFace: font, fontSize: 27, bold: true, color: C.ink, lineHeight: 1.35 },
            }),
            rule({ name: "result-rule", width: fill, stroke: "#D4E3DE", weight: 2 }),
            text("后续优化：高并发库存一致性、弱网体验、批量导入性能、AI 结果稳定性、安全专项测试。", {
              name: "future",
              width: fill,
              height: hug,
              style: { fontFace: font, fontSize: 24, color: C.muted, lineHeight: 1.3 },
            }),
          ]),
        ]),
        footer(),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

function addClosing() {
  const slide = presentation.slides.add();
  bg(slide, "#EEF6F3");
  slide.compose(
    column(
      { name: "root", width: fill, height: fill, padding: { x: 130, y: 120 }, gap: 42 },
      [
        text("答辩收束", {
          name: "closing-kicker",
          width: fill,
          height: hug,
          style: { fontFace: font, fontSize: 28, bold: true, color: C.green },
        }),
        text("本项目完成了从需求、设计、实现到测试的闭环实践", {
          name: "closing-title",
          width: wrap(1500),
          height: hug,
          style: { fontFace: font, fontSize: 64, bold: true, color: C.ink, lineHeight: 1.08 },
        }),
        text("核心价值：用统一身份和批次主线打通多角色业务，用监管任务闭环提升问题处置效率，用 AI 与扫码增强降低查询和现场操作成本。", {
          name: "closing-body",
          width: wrap(1350),
          height: hug,
          style: { fontFace: font, fontSize: 30, color: C.muted, lineHeight: 1.32 },
        }),
        row({ name: "closing-tags", width: hug, height: hug, gap: 18 }, [
          capsule("安全访问", C.green),
          capsule("全链路追溯", C.blue),
          capsule("监管闭环", C.amber),
          capsule("多端协同", C.teal),
        ]),
        footer("谢谢各位老师，请批评指正"),
      ],
    ),
    { frame: { left: 0, top: 0, width: W, height: H }, baseUnit: 8 },
  );
}

addCover();
addProblemGoal();
addArchitecture();
addTraceAndLoop();
addImplementationHighlights();
addAiAlgorithm();
addTestingSummary();
addClosing();

await fs.mkdir("output", { recursive: true });
await fs.mkdir("scratch/previews", { recursive: true });
const pptxBlob = await PresentationFile.exportPptx(presentation);
await pptxBlob.save("output/drug_traceability_defense_5min.pptx");

const slides = presentation.slides.items;
for (let i = 0; i < slides.length; i += 1) {
  const slide = slides[i];
  const png = await presentation.export({ slide, format: "png" });
  await fs.writeFile(`scratch/previews/slide-${String(i + 1).padStart(2, "0")}.png`, Buffer.from(await png.arrayBuffer()));
  const layout = await presentation.export({ slide, format: "layout" });
  await fs.writeFile(`scratch/previews/slide-${String(i + 1).padStart(2, "0")}.layout.json`, Buffer.from(await layout.arrayBuffer()));
}

console.log(`Exported ${slides.length} slides`);
