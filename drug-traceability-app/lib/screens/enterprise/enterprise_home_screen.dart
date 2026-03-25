import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../ai_assistant_profile.dart';
import '../ai_chat_screen.dart';

class EnterpriseHomeScreen extends StatefulWidget {
  const EnterpriseHomeScreen({super.key});

  @override
  State<EnterpriseHomeScreen> createState() => _EnterpriseHomeScreenState();
}

class _EnterpriseHomeScreenState extends State<EnterpriseHomeScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getInventory();
      if (res['code'] == 200) {
        _inventory = List<Map<String, dynamic>>.from(res['data'] ?? []);
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildActions(),
            const SizedBox(height: 16),
            _buildInventory(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _loadInventory,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新库存'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _openAssistant,
            icon: const Icon(Icons.smart_toy),
            label: const Text('AI助手'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('企业端', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('进销存管理 · 追溯留痕 · 合规自查', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showFlowDialog(type: 'in'),
                icon: const Icon(Icons.login),
                label: const Text('采购入库'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFlowDialog(type: 'out'),
                icon: const Icon(Icons.logout),
                label: const Text('销售出库'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('库存列表', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_inventory.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('暂无库存数据', style: TextStyle(color: Colors.grey))),
              )
            else
              ..._inventory.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.medication_outlined),
                  title: Text(item['drugName']?.toString() ?? '未知药品'),
                  subtitle: Text('批次: ${item['batchNumber'] ?? '-'}'),
                  trailing: Text('${item['quantity'] ?? 0}'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFlowDialog({required String type}) async {
    final drugId = TextEditingController();
    final batch = TextEditingController();
    final quantity = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(type == 'in' ? '采购入库' : '销售出库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: drugId, decoration: const InputDecoration(labelText: '药品ID')),
            TextField(controller: batch, decoration: const InputDecoration(labelText: '批次号')),
            TextField(controller: quantity, decoration: const InputDecoration(labelText: '数量')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('提交')),
        ],
      ),
    );

    if (ok != true) return;

    final payload = {
      'drugId': int.tryParse(drugId.text.trim()) ?? 0,
      'batchNumber': batch.text.trim(),
      'quantity': int.tryParse(quantity.text.trim()) ?? 0,
    };

    try {
      if (type == 'in') {
        await _apiService.warehouseIn(payload);
      } else {
        await _apiService.warehouseOut(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('提交成功')));
      _loadInventory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交失败: $e')));
    }
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatScreen(profile: AIAssistantProfiles.enterpriseSide),
      ),
    );
  }
}
