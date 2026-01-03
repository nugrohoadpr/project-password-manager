import 'package:flutter/material.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/session_manager.dart';
import 'features/auth/pages/create_master_password_page.dart';
import 'features/auth/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().loadTimeoutSetting();
  runApp(const LockPassApp());
}

class LockPassApp extends StatelessWidget {
  const LockPassApp({super.key});

  Future<Widget> _decideStartPage() async {
    final storage = SecureStorageService();
    final hasMaster = await storage.hasMasterPassword();
    
    if (hasMaster) {
      return const LoginPage();
    } else {
      return const CreateMasterPasswordPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LockPass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _decideStartPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
