// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kulaidoverse/game_history_screen.dart';
import 'package:kulaidoverse/game_stats_screen.dart';
import 'package:kulaidoverse/login_screen.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:kulaidoverse/testing_results_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String? avatarUrl;

  const UserProfileScreen({super.key, required this.userName, this.avatarUrl});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SyncService _syncService = SyncService();

  Future<void> _signOut() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Ensure settings are synced before logout
      await _syncService.syncUserSettings(user.id);
    }

    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign-out failed: $e');
    }

    await Supabase.instance.client.auth.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showCreditsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Image.asset('assets/logo/LogoKly.png', width: 80, height: 80),
                  const SizedBox(height: 16),

                  // App Name
                  const Text(
                    'KULAIDOVERSE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // Version
                  const Text(
                    'Version 1.0',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Developer Credits Title
                  const Text(
                    'Developed By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Developer Names
                  _buildDeveloperName('Ma. Romina Andrei Villones'),
                  _buildDeveloperName('Sean Stephan Miguel Sumugat'),
                  _buildDeveloperName('Ephraim John San Jose'),
                  _buildDeveloperName('John Louel Pulumbarit'),

                  const SizedBox(height: 24),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDeveloperName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                        ? NetworkImage(widget.avatarUrl!)
                        : const AssetImage(
                              'assets/logo/default_avatar_icon.png',
                            )
                            as ImageProvider,
              ),

              const SizedBox(height: 16),

              // Full Name
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Email (optional)
              Text(
                Supabase.instance.client.auth.currentUser?.email ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // Menu Buttons
              _buildMenuButton(
                icon: Icons.emoji_events_outlined,
                label: 'Game Stats',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameStatsScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuButton(
                icon: Icons.history_outlined,
                label: 'Game History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuButton(
                icon: Icons.assignment_outlined,
                label: 'Testing Results',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TestingResultsScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Credits Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _showCreditsDialog,
                  icon: const Icon(Icons.info_outline),
                  label: const Text(
                    'Credits',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF2C2C2C),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
