// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:kulaidoverse/game_stats_screen.dart';
import 'package:kulaidoverse/services/sync_service.dart';
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
  bool _isLoading = false;

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
              // In user_profile_screen.dart, update the Game Stats button:
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
                  // TODO: Navigate to GameHistoryScreen
                  _showComingSoon(context, 'Game History');
                },
              ),

              const SizedBox(height: 12),

              _buildMenuButton(
                icon: Icons.assignment_outlined,
                label: 'Testing Results',
                onTap: () {
                  // TODO: Navigate to TestingResultsScreen
                  _showComingSoon(context, 'Testing Results');
                },
              ),
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

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(feature),
            content: Text('$feature screen coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
