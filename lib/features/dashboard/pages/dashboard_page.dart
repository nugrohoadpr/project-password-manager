import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/password_model.dart';
import '../../add_password/pages/add_password_page.dart';
import '../../password_detail/pages/password_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<PasswordItem> _passwords = [];
  List<PasswordItem> _filteredPasswords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
    _searchController.addListener(_filterPasswords);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPasswords);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query('passwords', orderBy: 'created_at DESC');
      
      if (!mounted) return;
      
      setState(() {
        _passwords = results.map((map) {
          return PasswordItem(
            id: map['id'] as int,
            title: map['title'] as String,
            email: map['email'] as String? ?? '',
            password: map['password'] as String,
            website: map['website'] as String? ?? '',
          );
        }).toList();
        _filteredPasswords = _passwords;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading passwords: $e')),
      );
    }
  }

  void _filterPasswords() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredPasswords = _passwords;
      } else {
        _filteredPasswords = _passwords.where((password) {
          final title = password.title.toLowerCase();
          final email = password.email.toLowerCase();
          final website = password.website.toLowerCase();
          
          return title.contains(query) || 
                 email.contains(query) || 
                 website.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _copyPassword(String encryptedPassword) async {
    try {
      final encryptionService = DatabaseHelper.instance.encryptionService;
      final decryptedPassword = encryptionService.decryptData(encryptedPassword);
      
      await Clipboard.setData(ClipboardData(text: decryptedPassword));
      
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
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search passwords...',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          
          // Password Count
          if (!_isLoading && _passwords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.isEmpty
                        ? '${_passwords.length} passwords'
                        : '${_filteredPasswords.length} of ${_passwords.length} passwords',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Password List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C3FBF),
                    ),
                  )
                : _filteredPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.lock_outline
                                  : Icons.search_off,
                              size: 80,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No passwords yet'
                                  : 'No passwords found',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Tap + to add your first password'
                                  : 'Try different keywords',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF7C3FBF),
                        onRefresh: _loadPasswords,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _filteredPasswords.length,
                          itemBuilder: (context, index) {
                            final password = _filteredPasswords[index];
                            return _buildPasswordCard(password, cardColor);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPasswordPage(),
            ),
          );
          if (result == true) {
            _loadPasswords();
          }
        },
        backgroundColor: const Color(0xFF7C3FBF),
        child: const Icon(Icons.add, color: Colors.white),
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
            color: const Color(0xFF7C3FBF),
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
            _loadPasswords();
          }
        },
      ),
    );
  }
}
