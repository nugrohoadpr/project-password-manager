import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/password_model.dart';
import '../../password_detail/pages/password_detail_page.dart';

class WeakPasswordsPage extends StatefulWidget {
  const WeakPasswordsPage({super.key});

  @override
  State<WeakPasswordsPage> createState() => _WeakPasswordsPageState();
}

class _WeakPasswordsPageState extends State<WeakPasswordsPage> {
  List<PasswordItem> _weakPasswords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeakPasswords();
  }

  Future<void> _loadWeakPasswords() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query('passwords', orderBy: 'created_at DESC');
      final encryptionService = DatabaseHelper.instance.encryptionService;
      
      List<PasswordItem> weak = [];
      
      for (var map in results) {
        final decryptedPassword = encryptionService.decryptData(
          map['password'] as String,
        );
        
        if (_isWeakPassword(decryptedPassword)) {
          final password = PasswordItem(
            id: map['id'] as int,
            title: map['title'] as String,
            email: map['email'] as String? ?? '',
            password: decryptedPassword,
            website: map['website'] as String? ?? '',
          );
          weak.add(password);
        }
      }
      
      if (!mounted) return;
      
      setState(() {
        _weakPasswords = weak;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _isWeakPassword(String password) {
    if (password.length < 8) return true;
    
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;
    
    return strength < 3;
  }

  Future<void> _copyPassword(String password) async {
    try {
      await Clipboard.setData(ClipboardData(text: password));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'WEAK PASSWORDS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (!_isLoading && _weakPasswords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Weak passwords are easier to guess. Use at least 8 characters with mix of letters, numbers, and symbols.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isLoading && _weakPasswords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_weakPasswords.length} weak passwords found',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C3FBF),
                    ),
                  )
                : _weakPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 80,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Weak Passwords',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All passwords are strong!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF7C3FBF),
                        onRefresh: _loadWeakPasswords,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _weakPasswords.length,
                          itemBuilder: (context, index) {
                            final password = _weakPasswords[index];
                            return _buildPasswordCard(password, cardColor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(PasswordItem password, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              password.firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        title: Text(
          password.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          password.email.isNotEmpty 
              ? password.email 
              : (password.website.isNotEmpty 
                  ? password.website 
                  : 'No details'),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              color: const Color(0xFF7C3FBF),
              onPressed: () => _copyPassword(password.password),
              tooltip: 'Copy password',
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordDetailPage(
                passwordId: password.id,
              ),
            ),
          );
          if (result == true) {
            _loadWeakPasswords();
          }
        },
      ),
    );
  }
}
