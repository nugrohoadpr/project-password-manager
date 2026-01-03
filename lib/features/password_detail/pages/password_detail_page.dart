import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/password_model.dart';
import '../../edit_password/pages/edit_password_page.dart';

class PasswordDetailPage extends StatefulWidget {
  final int passwordId;
  
  const PasswordDetailPage({
    super.key,
    required this.passwordId,
  });

  @override
  State<PasswordDetailPage> createState() => _PasswordDetailPageState();
}

class _PasswordDetailPageState extends State<PasswordDetailPage> {
  PasswordItem? _password;
  bool _isLoading = true;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        'passwords',
        where: 'id = ?',
        whereArgs: [widget.passwordId],
      );
      
      if (!mounted) return;
      
      if (results.isNotEmpty) {
        final map = results.first;
        final encryptionService = DatabaseHelper.instance.encryptionService;
        
        final decryptedPassword = encryptionService.decryptData(
          map['password'] as String,
        );
        
        setState(() {
          _password = PasswordItem(
            id: map['id'] as int,
            title: map['title'] as String,
            email: map['email'] as String? ?? '',
            password: decryptedPassword,
            website: map['website'] as String? ?? '',
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _navigateToEdit() async {
    if (_password == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPasswordPage(item: _password!),
      ),
    );

    // Reload data setelah edit
    if (result != null && mounted) {
      await _loadPassword();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Password updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deletePassword() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${_password?.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'passwords',
        where: 'id = ?',
        whereArgs: [widget.passwordId],
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Password deleted successfully'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ $label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF5ECFF);
    const Color cardColor = Color(0xFFF8EFFF);
    const Color primary = Color(0xFF7C3FBF);

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
          'PASSWORD DETAIL',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            color: primary,
            onPressed: _password != null ? _navigateToEdit : null,
            tooltip: 'Edit password',
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: _password != null ? _deletePassword : null,
            tooltip: 'Delete password',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C3FBF),
              ),
            )
          : _password == null
              ? const Center(
                  child: Text(
                    'Password not found',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - NO COPY
                      _buildInfoCard(
                        'Title',
                        _password!.title,
                        Icons.title,
                        cardColor,
                      ),
                      const SizedBox(height: 12),
                      
                      // Email - NO COPY
                      if (_password!.email.isNotEmpty)
                        _buildInfoCard(
                          'Email',
                          _password!.email,
                          Icons.email,
                          cardColor,
                        ),
                      if (_password!.email.isNotEmpty) 
                        const SizedBox(height: 12),
                      
                      // Password - WITH COPY & EYE
                      _buildPasswordCard(cardColor),
                      const SizedBox(height: 12),
                      
                      // Website - NO COPY
                      if (_password!.website.isNotEmpty)
                        _buildInfoCard(
                          'Website',
                          _password!.website,
                          Icons.language,
                          cardColor,
                        ),
                    ],
                  ),
                ),
    );
  }

  // Info Card - NO COPY BUTTON
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color cardColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Password Card - WITH COPY & EYE BUTTON
  Widget _buildPasswordCard(Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Eye icon (show/hide password)
              IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                color: const Color(0xFF7C3FBF),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                tooltip: _passwordVisible ? 'Hide password' : 'Show password',
              ),
              // Copy icon (ONLY for password)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                color: const Color(0xFF7C3FBF),
                onPressed: () => _copyToClipboard(
                  _password!.password, 
                  'Password',
                ),
                tooltip: 'Copy password',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _passwordVisible ? _password!.password : '••••••••',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: _passwordVisible ? 0 : 2,
            ),
          ),
        ],
      ),
    );
  }
}
