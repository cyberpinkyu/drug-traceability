import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_service.dart';

class UsageRecordScanScreen extends StatefulWidget {
  const UsageRecordScanScreen({super.key});

  @override
  State<UsageRecordScanScreen> createState() => _UsageRecordScanScreenState();
}

class _UsageRecordScanScreenState extends State<UsageRecordScanScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _drugIdController = TextEditingController();
  final TextEditingController _drugCodeController = TextEditingController();
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _usageController = TextEditingController();

  String? _drugName;
  bool _saving = false;
  bool _handlingScan = false;

  @override
  void dispose() {
    _drugIdController.dispose();
    _drugCodeController.dispose();
    _patientController.dispose();
    _usageController.dispose();
    super.dispose();
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
              const Text('Scan Drug Barcode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) async {
                    if (_handlingScan) return;
                    final raw = capture.barcodes.first.rawValue;
                    if (raw == null || raw.trim().isEmpty) return;

                    _handlingScan = true;
                    Navigator.pop(context);
                    final normalized = _apiService.normalizeScanCode(raw);
                    _drugCodeController.text = normalized;
                    await _resolveDrugFromCode(normalized);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resolveDrugFromCode(String code) async {
    try {
      final res = await _apiService.resolveDrugForUsageByScanCode(code);
      final data = Map<String, dynamic>.from(res['data'] as Map);
      setState(() {
        _drugIdController.text = (data['id'] ?? '').toString();
        _drugName = (data['name'] ?? data['drugName'] ?? '').toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('identified drug: ${_drugName ?? '-'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to identify drug: $e')),
      );
    }
  }

  Future<void> _submit() async {
    final drugId = int.tryParse(_drugIdController.text.trim());
    final patient = _patientController.text.trim();
    final usage = _usageController.text.trim();

    if (drugId == null || drugId <= 0 || patient.isEmpty || usage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete drugId, patient name and usage')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _apiService.submitUsageRecord({
        'drugId': drugId,
        'patientName': patient,
        'usage': usage,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('usage record submitted')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('submit failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Record Usage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _drugCodeController,
            decoration: InputDecoration(
              labelText: 'Drug barcode / code',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _openScanner,
              ),
            ),
            onSubmitted: _resolveDrugFromCode,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _drugIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Drug ID'),
          ),
          if ((_drugName ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Drug name: $_drugName', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _patientController,
            decoration: const InputDecoration(labelText: 'Patient name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usageController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Usage description'),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Submit Usage Record'),
          ),
        ],
      ),
    );
  }
}