import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/password_model.dart';
import '../../password_detail/pages/password_detail_page.dart';

class ReusedPasswordsPage extends StatefulWidget {
  const ReusedPasswordsPage({super.key});

  @override
  State<ReusedPasswordsPage> createState() => _ReusedPasswordsPageState();
}

class _ReusedPasswordsPageState extends State<ReusedPasswordsPage> {
  List<PasswordItem> _reusedPasswords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReusedPasswords();
  }

  Future<void> _loadReusedPasswords() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query('passwords', orderBy: 'created_at DESC');
      final encryptionService = DatabaseHelper.instance.encryptionService;
      
      Map<String, List<PasswordItem>> passwordGroups = {};
      
      for (var map in results) {
        final decryptedPassword = encryptionService.decryptData(
          map['password'] as String,
        );
        
        final password = PasswordItem(
          id: map['id'] as int,
          title: map['title'] as String,
          email: map['email'] as String? ?? '',
          password: decryptedPassword,
          website: map['website'] as String? ?? '',
        );
        
        if (passwordGroups.containsKey(decryptedPassword)) {
          passwordGroups[decryptedPassword]!.add(password);
        } else {
          passwordGroups[decryptedPassword] = [password];
        }
      }
      
      List<PasswordItem> reused = [];
      passwordGroups.forEach((key, value) {
        if (value.length > 1) {
          reused.addAll(value);
        }
      });
      
      if (!mounted) return;
      
      setState(() {
        _reusedPasswords = reused;
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
          'REUSED PASSWORDS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (!_isLoading && _reusedPasswords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Using the same password for multiple accounts is risky. Consider using unique passwords.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isLoading && _reusedPasswords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_reusedPasswords.length} passwords reused',
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
                : _reusedPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Reused Passwords',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Great! All passwords are unique',
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
                        onRefresh: _loadReusedPasswords,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _reusedPasswords.length,
                          itemBuilder: (context, index) {
                            final password = _reusedPasswords[index];
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
            color: Colors.orange.shade400,
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
            _loadReusedPasswords();
          }
        },
      ),
    );
  }
}
