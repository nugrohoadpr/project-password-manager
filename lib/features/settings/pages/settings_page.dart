import 'package:flutter/material.dart';
import '../../change_password/pages/change_master_password_page.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/session_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _lightMode = false;
  bool _mfaEnabled = false;
  
  final SessionManager _sessionManager = SessionManager();
  int _sessionTimeout = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _sessionManager.loadTimeoutSetting();
    setState(() {
      _sessionTimeout = _sessionManager.timeoutMinutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF5ECFF);
    const Color cardColor = Color(0xFFF8EFFF);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        title: const Text(
          'SETTING',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Master Password
            _buildSettingCard(
              icon: Icons.key,
              title: 'Master Password',
              subtitle: 'Change master password',
              cardColor: cardColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeMasterPasswordPage(),
                  ),
                );
              },
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Session Timeout
            _buildSettingCard(
              icon: Icons.timer_outlined,
              title: 'Session Timeout',
              subtitle: _getTimeoutLabel(),
              cardColor: cardColor,
              onTap: () {
                _showTimeoutDialog();
              },
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Settings Group
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.light_mode,
                    title: 'Light Mode',
                    subtitle: 'Use light mode for your app',
                    value: _lightMode,
                    onChanged: (value) {
                      setState(() {
                        _lightMode = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value 
                              ? 'Light mode enabled' 
                              : 'Dark mode enabled'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggleItem(
                    icon: Icons.lock,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Use authentication apps',
                    value: _mfaEnabled,
                    onChanged: (value) {
                      setState(() {
                        _mfaEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value 
                              ? 'MFA enabled' 
                              : 'MFA disabled'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lock App
            GestureDetector(
              onTap: () {
                _showLockConfirmation(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(128),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_outline,
                          size: 24, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock App',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lock and return to login',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3FBF),
          ),
        ],
      ),
    );
  }

  String _getTimeoutLabel() {
    if (_sessionTimeout == 0) return 'Never';
    return '$_sessionTimeout minutes';
  }

  void _showTimeoutDialog() {
    final timeouts = [0, 1, 2, 5, 10, 15, 30];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Session Timeout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: timeouts.map((timeout) {
              final label = timeout == 0 ? 'Never' : '$timeout minutes';
              
              return ListTile(
                title: Text(label),
                leading: Radio<int>(
                  value: timeout,
                  groupValue: _sessionTimeout,
                  onChanged: (value) async {
                    setState(() => _sessionTimeout = value!);
                    await _sessionManager.saveTimeoutSetting(value!);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Timeout set to $label'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                onTap: () async {
                  setState(() => _sessionTimeout = timeout);
                  await _sessionManager.saveTimeoutSetting(timeout);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Timeout set to $label'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lock App'),
          content: const Text(
              'Are you sure you want to lock the app? You will need to enter your master password to unlock.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                AuthService.logout(context);
              },
              child: const Text(
                'Lock',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
