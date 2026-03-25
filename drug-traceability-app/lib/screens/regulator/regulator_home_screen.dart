import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/api_service.dart';
import '../ai_assistant_profile.dart';
import '../ai_chat_screen.dart';

class RegulatorHomeScreen extends StatefulWidget {
  const RegulatorHomeScreen({super.key});

  @override
  State<RegulatorHomeScreen> createState() => _RegulatorHomeScreenState();
}

class _RegulatorHomeScreenState extends State<RegulatorHomeScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;
  Set<Marker> _markers = {};

  static const LatLng _center = LatLng(39.9042, 116.4074);

  @override
  void initState() {
    super.initState();
    _loadRiskMap();
  }

  Future<void> _loadRiskMap() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getRiskMap();
      if (response['code'] == 200 && response['data'] is List) {
        final data = List<Map<String, dynamic>>.from(response['data'] as List);
        _markers = data.map((item) {
          final level = item['riskLevel']?.toString() ?? 'medium';
          return Marker(
            markerId: MarkerId(item['id']?.toString() ?? UniqueKey().toString()),
            position: LatLng(
              (item['latitude'] as num?)?.toDouble() ?? _center.latitude,
              (item['longitude'] as num?)?.toDouble() ?? _center.longitude,
            ),
            infoWindow: InfoWindow(
              title: item['name']?.toString() ?? '风险点',
              snippet: '风险级别: $level',
            ),
            icon: _markerIcon(level),
          );
        }).toSet();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  BitmapDescriptor _markerIcon(String level) {
    switch (level) {
      case 'high':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'low':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(target: _center, zoom: 11),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                  if (_isLoading) const Center(child: CircularProgressIndicator()),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: const [
                            _RiskLegend(color: Colors.red, label: '高风险'),
                            SizedBox(width: 12),
                            _RiskLegend(color: Colors.orange, label: '中风险'),
                            SizedBox(width: 12),
                            _RiskLegend(color: Colors.green, label: '低风险'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _showEnforcementDialog,
            icon: const Icon(Icons.assignment),
            label: const Text('现场检查'),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('监管端', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('现场检查 · 风险地图 · 执法辅助', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Future<void> _showEnforcementDialog() async {
    final orgId = TextEditingController();
    final result = TextEditingController();
    final desc = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('提交执法记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: orgId, decoration: const InputDecoration(labelText: '单位ID')),
            TextField(controller: result, decoration: const InputDecoration(labelText: '处理结果')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: '说明')),
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
      await _apiService.submitEnforcementRecord({
        'organizationId': int.tryParse(orgId.text.trim()) ?? 0,
        'inspectionType': 'manual',
        'inspectionResult': result.text.trim(),
        'description': desc.text.trim(),
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
        builder: (_) => AIChatScreen(profile: AIAssistantProfiles.regulatorSide),
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _RiskLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
