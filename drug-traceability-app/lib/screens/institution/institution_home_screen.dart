import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../adverse_reaction_screen.dart';
import '../ai_assistant_profile.dart';
import '../ai_chat_screen.dart';
import 'history_record_screen.dart';
import 'inventory_management_screen.dart';

class InstitutionHomeScreen extends StatefulWidget {
  const InstitutionHomeScreen({super.key});

  @override
  State<InstitutionHomeScreen> createState() => _InstitutionHomeScreenState();
}

class _InstitutionHomeScreenState extends State<InstitutionHomeScreen> {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildServices(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAssistant,
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI助手'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal[700],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('医疗机构端', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('验收入库 · 用药记录 · 不良反应上报', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showUsageRecordDialog,
                icon: const Icon(Icons.edit_note),
                label: const Text('记录用药'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdverseReactionScreen()),
                  );
                },
                icon: const Icon(Icons.warning_amber),
                label: const Text('不良反应上报'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServices() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.12,
      children: [
        _serviceCard(
          title: '库存管理',
          subtitle: '查看药品库存',
          icon: Icons.inventory_2,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryManagementScreen()),
            );
          },
        ),
        _serviceCard(
          title: '历史记录',
          subtitle: '查看院内记录',
          icon: Icons.history,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryRecordScreen()),
            );
          },
        ),
        _serviceCard(
          title: '问题上报',
          subtitle: '上报不良反应',
          icon: Icons.report,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdverseReactionScreen()),
            );
          },
        ),
        _serviceCard(
          title: 'AI助手',
          subtitle: '院内流程答疑',
          icon: Icons.smart_toy,
          color: Colors.indigo,
          onTap: _openAssistant,
        ),
      ],
    );
  }

  Widget _serviceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUsageRecordDialog() async {
    final drugId = TextEditingController();
    final patientName = TextEditingController();
    final usage = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增用药记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: drugId, decoration: const InputDecoration(labelText: '药品ID')),
            TextField(controller: patientName, decoration: const InputDecoration(labelText: '患者姓名')),
            TextField(controller: usage, decoration: const InputDecoration(labelText: '用药说明')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('提交')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _apiService.submitUsageRecord({
        'drugId': int.tryParse(drugId.text.trim()) ?? 0,
        'patientName': patientName.text.trim(),
        'usage': usage.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('提交成功')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交失败: $e')));
    }
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatScreen(profile: AIAssistantProfiles.institutionSide),
      ),
    );
  }
}
