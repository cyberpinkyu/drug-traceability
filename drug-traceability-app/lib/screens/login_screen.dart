import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'public';

  final List<Map<String, dynamic>> _roles = [
    {'value': 'public', 'label': '公众用户', 'icon': Icons.person},
    {'value': 'enterprise', 'label': '企业用户', 'icon': Icons.business},
    {'value': 'institution', 'label': '医疗机构', 'icon': Icons.local_hospital},
    {'value': 'regulator', 'label': '监管人员', 'icon': Icons.security},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      final userData = response['data'] as Map<String, dynamic>;
      final user = User(
        id: userData['id'].toString(),
        username: userData['username']?.toString() ?? '',
        name: userData['name']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        phone: userData['phone']?.toString() ?? '',
        role: userData['roleCode']?.toString() ?? _selectedRole,
        token: userData['token']?.toString() ?? '',
      );

      if (kIsWeb) {
        _apiService.setWebToken(user.token);
      } else {
        final userBox = await Hive.openBox<User>('userBox');
        await userBox.put('currentUser', user);
      }
      ref.read(userProvider.notifier).setUser(user);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '药监通',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '智能药品全流程追溯监管系统',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? '请输入用户名' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '密码',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? '请输入密码' : null,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _roles.map((role) {
                        return ChoiceChip(
                          selected: _selectedRole == role['value'],
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(role['icon'] as IconData, size: 16),
                              const SizedBox(width: 4),
                              Text(role['label'] as String),
                            ],
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedRole = role['value'] as String;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('登录'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
