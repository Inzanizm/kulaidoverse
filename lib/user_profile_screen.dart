// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kulaidoverse/game_history_screen.dart';
import 'package:kulaidoverse/game_stats_screen.dart';
import 'package:kulaidoverse/login_screen.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:kulaidoverse/testing_results_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

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
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo/LogoKly.png', width: 80, height: 80),
                  const SizedBox(height: AppTheme.spaceMd),
                  const Text(
                    'KULAIDOVERSE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Version 1.0',
                    style: TextStyle(fontSize: 14, color: AppTheme.grey),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  const Text(
                    'Developed By',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  _buildDeveloperName('Ma. Romina Andrei Villones'),
                  _buildDeveloperName('Sean Stephan Miguel Sumugat'),
                  _buildDeveloperName('Ephraim John San Jose'),
                  _buildDeveloperName('John Louel Pulumbarit'),
                  const SizedBox(height: AppTheme.spaceLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pureBlack,
                        foregroundColor: AppTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spaceMd,
                        ),
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
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
      child: Text(
        name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.pureBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // FIX: Use LayoutBuilder with proper constraints instead of IntrinsicHeight
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isSmallScreen ? AppTheme.spaceMd : AppTheme.spaceLg,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppTheme.spaceLg),

                        // Avatar with Hero animation
                        Hero(
                          tag: 'userAvatar',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.lightGrey,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: isSmallScreen ? 50 : 60,
                              backgroundColor: AppTheme.offWhite,
                              backgroundImage:
                                  widget.avatarUrl != null &&
                                          widget.avatarUrl!.isNotEmpty
                                      ? NetworkImage(widget.avatarUrl!)
                                      : const AssetImage(
                                            'assets/logo/default_avatar_icon.png',
                                          )
                                          as ImageProvider,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spaceMd),

                        // User Info
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          Supabase.instance.client.auth.currentUser?.email ??
                              '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spaceXl),

                        // Menu Items - FIX: Removed Spacer, using SizedBox for spacing
                        _buildMenuButton(
                          icon: Icons.emoji_events_outlined,
                          label: 'Game Stats',
                          onTap: () => _navigateTo(const GameStatsScreen()),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildMenuButton(
                          icon: Icons.history_outlined,
                          label: 'Game History',
                          onTap: () => _navigateTo(const GameHistoryScreen()),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildMenuButton(
                          icon: Icons.assignment_outlined,
                          label: 'Testing Results',
                          onTap:
                              () => _navigateTo(const TestingResultsScreen()),
                        ),

                        // FIX: Use Expanded instead of Spacer for proper flex behavior
                        const Expanded(child: SizedBox()),

                        // Bottom Actions
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.pureBlack,
                              side: const BorderSide(color: AppTheme.pureBlack),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spaceMd,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                              ),
                            ),
                            onPressed: _showCreditsDialog,
                            icon: const Icon(Icons.info_outline),
                            label: const Text(
                              'Credits',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spaceMd),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.pureBlack,
                              foregroundColor: AppTheme.pureWhite,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spaceMd,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                              ),
                            ),
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spaceMd),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
      color: AppTheme.softBlack,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceMd + 4,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.pureWhite, size: 28),
              const SizedBox(width: AppTheme.spaceMd),
              Text(label, style: AppTheme.cardTitle),
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

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
