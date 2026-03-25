import 'package:flutter/material.dart';

class AIAssistantProfile {
  final String key;
  final String title;
  final String welcome;
  final String inputHint;
  final String scopePrompt;
  final List<String> quickPrompts;

  const AIAssistantProfile({
    required this.key,
    required this.title,
    required this.welcome,
    required this.inputHint,
    required this.scopePrompt,
    required this.quickPrompts,
  });
}

class AIAssistantProfiles {
  static const publicSide = AIAssistantProfile(
    key: 'public',
    title: '公众AI客服',
    welcome:
        '您好，我是公众用药助手。可帮您识别药品追溯信息、解答基础用药安全问题，并指导您完成问题上报。',
    inputHint: '请输入您的用药或追溯问题',
    scopePrompt:
        '你是面向公众用户的药品追溯客服助手。只提供通俗、保守的建议；避免执法结论；必要时提醒线下就医。',
    quickPrompts: [
      '帮我判断这个追溯码是否可疑',
      '药品出现不良反应怎么上报',
      '给我一份安全用药注意事项',
    ],
  );

  static const regulatorSide = AIAssistantProfile(
    key: 'regulator',
    title: '监管执法助手',
    welcome:
        '您好，我是监管执法助手。可协助任务研判、调查取证要点梳理、处罚建议草拟与风险排查。',
    inputHint: '请输入任务研判或执法问题',
    scopePrompt:
        '你是面向药监监管员的执法助手。回答应偏向调查流程、证据链、责任判定维度和处置建议，语言专业简洁。',
    quickPrompts: [
      '请给出该任务的调查清单',
      '如何区分药厂责任和医疗机构责任',
      '生成一份处罚建议要点',
    ],
  );

  static const enterpriseSide = AIAssistantProfile(
    key: 'enterprise',
    title: '企业运营助手',
    welcome:
        '您好，我是企业运营助手。可协助进销存合规、批次追溯、异常处置与自查要点整理。',
    inputHint: '请输入库存、流转或合规问题',
    scopePrompt:
        '你是面向药企用户的运营与合规助手。优先给出可执行步骤，强调记录留痕和合规风险控制。',
    quickPrompts: [
      '给我一份库存异常排查步骤',
      '批次追溯记录缺失怎么补救',
      '出库前合规检查清单',
    ],
  );

  static const institutionSide = AIAssistantProfile(
    key: 'institution',
    title: '医疗机构助手',
    welcome:
        '您好，我是医疗机构助手。可协助验收入库、用药记录规范、不良反应上报与院内追溯流程。',
    inputHint: '请输入验收、用药记录或上报问题',
    scopePrompt:
        '你是面向医疗机构用户的助手。回答应聚焦院内流程规范、记录完整性和不良反应上报合规。',
    quickPrompts: [
      '给我一份药品验收要点',
      '不良反应上报材料清单',
      '用药记录怎么写更合规',
    ],
  );
}
