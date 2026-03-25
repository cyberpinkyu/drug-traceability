import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';

class AdverseReactionScreen extends ConsumerStatefulWidget {
  const AdverseReactionScreen({super.key});

  @override
  ConsumerState<AdverseReactionScreen> createState() =>
      _AdverseReactionScreenState();
}

class _AdverseReactionScreenState extends ConsumerState<AdverseReactionScreen> {
  final _apiService = ApiService();
  final _drugNameController = TextEditingController();
  final _reactionController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _severityController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _doctorNameController = TextEditingController();

  String _selectedSeverity = '轻度';
  bool _isLoading = false;
  bool _isScanning = false;

  final List<String> _severityOptions = ['轻度', '中度', '重度', '危重'];

  @override
  void dispose() {
    _drugNameController.dispose();
    _reactionController.dispose();
    _patientNameController.dispose();
    _severityController.dispose();
    _hospitalController.dispose();
    _doctorNameController.dispose();
    super.dispose();
  }

  Future<void> _submitReaction() async {
    if (_drugNameController.text.isEmpty ||
        _reactionController.text.isEmpty ||
        _patientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写必填信息')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.submitAdverseReaction({
        'drugName': _drugNameController.text,
        'reactionDescription': _reactionController.text,
        'patientName': _patientNameController.text,
        'severity': _selectedSeverity,
        'hospital': _hospitalController.text,
        'doctorName': _doctorNameController.text,
      });

      if (response['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('上报成功')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? '上报失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上报失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _drugNameController.clear();
    _reactionController.clear();
    _patientNameController.clear();
    _severityController.clear();
    _hospitalController.clear();
    _doctorNameController.clear();
    setState(() {
      _selectedSeverity = '轻度';
    });
  }

  void _showScanner() {
    setState(() {
      _isScanning = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '扫码获取药品信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isScanning = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) {
                      Navigator.pop(context);
                      _drugNameController.text = barcode.rawValue!;
                      setState(() {
                        _isScanning = false;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('不良反应上报'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('历史上报记录功能开发中')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red[700]!,
            Colors.red[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '不良反应上报',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '及时上报药品不良反应，保障用药安全',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _drugNameController,
              label: '药品名称',
              hint: '请输入药品名称',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _showScanner,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _patientNameController,
              label: '患者姓名',
              hint: '请输入患者姓名',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _reactionController,
              label: '不良反应描述',
              hint: '请详细描述不良反应症状',
              maxLines: 4,
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 16),
            _buildDropdownButton(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _hospitalController,
              label: '医疗机构',
              hint: '请输入医疗机构名称',
              prefixIcon: Icons.local_hospital,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _doctorNameController,
              label: '医生姓名',
              hint: '请输入医生姓名（可选）',
              prefixIcon: Icons.medical_services,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedSeverity,
      decoration: InputDecoration(
        labelText: '严重程度',
        prefixIcon: const Icon(Icons.warning),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _severityOptions.map((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSeverity = newValue!;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReaction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '提交上报',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
