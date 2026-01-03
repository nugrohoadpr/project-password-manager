import 'package:flutter/material.dart';
import '../../../core/repositories/password_repository.dart';
import '../../weak_passwords/pages/weak_passwords_page.dart';
import '../../reused_passwords/pages/reused_passwords_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final PasswordRepository _passwordRepo = PasswordRepository();
  
  int _weakCount = 0;
  int _reusedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    
    final weak = await _passwordRepo.getWeakPasswordsCount();
    final reused = await _passwordRepo.getReusedPasswordsCount();
    
    if (!mounted) return;
    
    setState(() {
      _weakCount = weak;
      _reusedCount = reused;
      _isLoading = false;
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
          'PASSWORD HEALTH',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCounts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Weak Passwords Card
                    _buildToolCard(
                      icon: Icons.shield_outlined,
                      iconColor: Colors.orange,
                      title: 'Weak Passwords',
                      subtitle: '$_weakCount ${_weakCount == 1 ? 'account' : 'accounts'}',
                      description: 'Using weak password',
                      cardColor: cardColor,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeakPasswordsPage(),
                          ),
                        );
                        await _loadCounts();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reused Passwords Card
                    _buildToolCard(
                      icon: Icons.copy_all_outlined,
                      iconColor: Colors.blue,
                      title: 'Reused Passwords',
                      subtitle: '$_reusedCount ${_reusedCount == 1 ? 'account' : 'accounts'}',
                      description: 'Using same password',
                      cardColor: cardColor,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReusedPasswordsPage(),
                          ),
                        );
                        await _loadCounts();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required Color cardColor,
    required VoidCallback onTap,
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
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
    );
  }
}
