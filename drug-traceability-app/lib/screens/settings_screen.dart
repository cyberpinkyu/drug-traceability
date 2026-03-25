import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _biometricEnabled;
  late String _themeMode;
  late bool _autoUpdate;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _notificationsEnabled = box.get('notifications', defaultValue: true);
      _biometricEnabled = box.get('biometric', defaultValue: false);
      _themeMode = box.get('theme', defaultValue: 'system');
      _autoUpdate = box.get('autoUpdate', defaultValue: false);
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('biometric', value);
    setState(() {
      _biometricEnabled = value;
    });
  }

  Future<void> _setThemeMode(String value) async {
    final box = await Hive.openBox('settings');
    await box.put('theme', value);
    setState(() {
      _themeMode = value;
    });
  }

  Future<void> _toggleAutoUpdate(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('autoUpdate', value);
    setState(() {
      _autoUpdate = value;
    });
  }

  Future<void> _clearCache() async {
    final box = await Hive.openBox('settings');
    await box.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存已清除')),
    );
  }

  Future<void> _aboutApp() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于药监通'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('药监通 - 智能药品全流程追溯监管系统'),
            SizedBox(height: 16),
            Text('© 2024 药监通团队. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            title: '通用设置',
            children: [
              _buildSwitchTile(
                title: '通知提醒',
                subtitle: '接收系统通知和提醒',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                icon: Icons.notifications,
              ),
              _buildSwitchTile(
                title: '自动更新',
                subtitle: '自动下载和安装更新',
                value: _autoUpdate,
                onChanged: _toggleAutoUpdate,
                icon: Icons.update,
              ),
            ],
          ),
          _buildSection(
            title: '安全设置',
            children: [
              _buildSwitchTile(
                title: '生物识别',
                subtitle: '使用指纹或面部识别登录',
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
                icon: Icons.fingerprint,
              ),
            ],
          ),
          _buildSection(
            title: '主题设置',
            children: [
              _buildListTile(
                title: '主题模式',
                subtitle: _themeMode == 'system'
                    ? '跟随系统'
                    : _themeMode == 'light'
                        ? '浅色模式'
                        : '深色模式',
                icon: Icons.palette,
                onTap: () => _showThemeDialog(),
              ),
            ],
          ),
          _buildSection(
            title: '关于',
            children: [
              _buildListTile(
                title: '关于药监通',
                icon: Icons.info,
                onTap: _aboutApp,
              ),
              _buildListTile(
                title: '清除缓存',
                icon: Icons.delete_sweep,
                onTap: _clearCache,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: Icon(icon),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('跟随系统'),
              leading: const Icon(Icons.computer),
              selected: _themeMode == 'system',
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                _setThemeMode('system');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('浅色模式'),
              leading: const Icon(Icons.sunny),
              selected: _themeMode == 'light',
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                _setThemeMode('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('深色模式'),
              leading: const Icon(Icons.dark_mode),
              selected: _themeMode == 'dark',
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                _setThemeMode('dark');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
