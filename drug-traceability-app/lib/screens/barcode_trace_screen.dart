import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_service.dart';

class BarcodeTraceScreen extends StatefulWidget {
  const BarcodeTraceScreen({super.key});

  @override
  State<BarcodeTraceScreen> createState() => _BarcodeTraceScreenState();
}

class _BarcodeTraceScreenState extends State<BarcodeTraceScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _codeController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _loading = false;
  bool _handlingScan = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _resolveCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final res = await _apiService.resolveTraceByScanCode(trimmed);
      setState(() {
        _result = res;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('scan success: ${res['type']}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('scan failed: $e')),
      );
      setState(() {
        _result = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openScanner() async {
    _handlingScan = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Scan Drug Barcode / QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    _resolveCode(normalized);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    if (_result == null) {
      return const Text('No result yet');
    }

    final type = _result!['type']?.toString() ?? 'unknown';
    final code = _result!['code']?.toString() ?? '';
    final data = _result!['data'];

    if (data is! Map) {
      return Text('result type: $type\ncode: $code\ndata: $data');
    }

    final map = Map<String, dynamic>.from(data);
    final lines = <String>[
      'type: $type',
      'scanCode: $code',
      if (map['drugCode'] != null) 'drugCode: ${map['drugCode']}',
      if (map['name'] != null) 'drugName: ${map['name']}',
      if (map['drugName'] != null) 'drugName: ${map['drugName']}',
      if (map['batchNumber'] != null) 'batchNumber: ${map['batchNumber']}',
      if (map['manufacturer'] != null) 'manufacturer: ${map['manufacturer']}',
      if (map['productionDate'] != null) 'productionDate: ${map['productionDate']}',
      if (map['expiryDate'] != null) 'expiryDate: ${map['expiryDate']}',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(lines.join('\n')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Trace')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Scan code / trace code',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _openScanner,
                ),
              ),
              onSubmitted: _resolveCode,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : () => _resolveCode(_codeController.text),
                icon: _loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Trace by Code'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildResultCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}