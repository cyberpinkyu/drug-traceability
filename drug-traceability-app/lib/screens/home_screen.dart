import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'screens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final role = ref.watch(roleProvider);

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('药监通'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('退出登录')),
            ],
          ),
        ],
      ),
      body: _buildBody(role),
      drawer: _buildDrawer(context, user),
    );
  }

  Widget _buildBody(String role) {
    switch (role) {
      case 'enterprise':
        return const EnterpriseHomeScreen();
      case 'institution':
        return const InstitutionHomeScreen();
      case 'regulator':
        return const RegulatorHomeScreen();
      case 'public':
      default:
        return const PublicHomeScreen();
    }
  }

  Drawer _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('首页'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('扫码查询'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublicHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('追溯记录'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TraceRecordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定')),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!kIsWeb) {
      final userBox = await Hive.openBox<User>('userBox');
      await userBox.delete('currentUser');
    } else {
      ApiService().setWebToken('');
    }
    ref.read(userProvider.notifier).clearUser();
  }
}
