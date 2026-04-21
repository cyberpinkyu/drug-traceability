import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_service.dart';

class TraceRecordScreen extends StatefulWidget {
  const TraceRecordScreen({super.key});

  @override
  State<TraceRecordScreen> createState() => _TraceRecordScreenState();
}

class _TraceRecordScreenState extends State<TraceRecordScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _codeController = TextEditingController();

  Map<String, dynamic>? _record;
  final List<Map<String, dynamic>> _historyRecords = [];

  bool _isLoading = false;
  bool _hasSearched = false;
  bool _handlingScan = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchTrace() async {
    final input = _codeController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please input scan code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.resolveTraceByScanCode(input);
      final data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'] as Map)
          : <String, dynamic>{};

      setState(() {
        _record = data;
        _hasSearched = true;
        _historyRecords.insert(0, {
          'code': result['code']?.toString() ?? input,
          'type': result['type']?.toString() ?? 'unknown',
          'timestamp': DateTime.now(),
          'drugName': data['drugName']?.toString() ?? data['name']?.toString() ?? 'unknown',
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trace success: ${result['type']}')),
      );
    } catch (e) {
      setState(() {
        _record = null;
        _hasSearched = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trace failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showScanner() async {
    _handlingScan = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text('Scan Barcode / QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  if (_handlingScan) return;
                  final raw = capture.barcodes.first.rawValue;
                  if (raw == null || raw.trim().isEmpty) return;
                  _handlingScan = true;

                  Navigator.pop(context);
                  final normalized = _apiService.normalizeScanCode(raw);
                  _codeController.text = normalized;
                  _searchTrace();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trace Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_hasSearched && _record == null)
              const Expanded(
                child: Center(
                  child: Text('No matching trace info'),
                ),
              )
            else if (_record != null)
              Expanded(child: _buildTraceInfo(_record!))
            else
              const Expanded(
                child: Center(
                  child: Text('Scan or input code to start trace query'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode / trace code',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _searchTrace(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _showScanner,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchTrace,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceInfo(Map<String, dynamic> record) {
    final timeline = _buildTimeline(record);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(record),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trace Timeline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (timeline.isEmpty)
                    const Text('No detailed timeline provided by backend')
                  else
                    ...timeline,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Drug Name', _pick(record, ['drugName', 'name'])),
            _buildInfoRow('Specification', _pick(record, ['specification'])),
            _buildInfoRow('Manufacturer', _pick(record, ['manufacturer'])),
            _buildInfoRow('Batch Number', _pick(record, ['batchNumber', 'batch_number'])),
            _buildInfoRow('Production Date', _pick(record, ['productionDate', 'production_date'])),
            _buildInfoRow('Expiry Date', _pick(record, ['expiryDate', 'expiry_date'])),
            _buildInfoRow('Trace Code', _pick(record, ['traceCode', 'drugCode', 'drug_code'])),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Trace information is available', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(Map<String, dynamic> record) {
    final steps = <Widget>[];

    final rawTimeline = record['timeline'];
    if (rawTimeline is List) {
      for (final item in rawTimeline) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          steps.add(
            _buildTraceStep(
              _pick(map, ['stage', 'traceStep', 'step']),
              _pick(map, ['time', 'stepTime', 'createdAt']),
              _pick(map, ['organization', 'company']),
              _pick(map, ['description', 'detail']),
            ),
          );
        }
      }
    }

    if (steps.isEmpty) {
      final keys = ['procurementCount', 'saleCount', 'inventoryCount'];
      for (final k in keys) {
        if (record.containsKey(k)) {
          steps.add(_buildTraceStep(k, '-', '-', '${record[k]}'));
        }
      }
    }

    return steps;
  }

  Widget _buildTraceStep(String stage, String time, String company, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.done, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stage, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$time | $company', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Query History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: _historyRecords.isEmpty
                    ? const Center(child: Text('No history'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _historyRecords.length,
                        itemBuilder: (context, index) {
                          final record = _historyRecords[index];
                          return ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(record['drugName']?.toString() ?? 'unknown'),
                            subtitle: Text('${record['code']} | ${record['type']}'),
                            onTap: () {
                              _codeController.text = record['code'].toString();
                              Navigator.pop(context);
                              _searchTrace();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _pick(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return '-';
  }
}