import 'package:flutter/material.dart';
import 'package:kulaidoverse/games/games_screen.dart';
import 'package:kulaidoverse/learning/kulaiticle.dart';
import 'package:kulaidoverse/testing/testing_screen.dart';
import 'package:kulaidoverse/user_profile_screen.dart';
import 'color_camera_screen.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  final String? userName;
  final String? avatarUrl;
  final String? userEmail;

  const HomeScreen({super.key, this.userName, this.avatarUrl, this.userEmail});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final crossAxisCount = size.width > 600 ? 4 : 2;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Unified App Bar
            _buildAppBar(context),

            const SizedBox(height: AppTheme.spaceLg),

            // Dashboard Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Center(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Responsive Grid Dashboard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                ),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppTheme.spaceMd,
                  crossAxisSpacing: AppTheme.spaceMd,
                  childAspectRatio: isSmallScreen ? 0.9 : 1.0,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.camera_alt_outlined,
                      label: 'Color Camera',
                      onTap:
                          () => _navigateTo(context, const ColorCameraScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Learning',
                      onTap: () => _navigateTo(context, const Kulaiticle()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.videogame_asset_outlined,
                      label: 'Games',
                      onTap: () => _navigateTo(context, const GamesScreen()),
                    ),
                    _buildDashboardCard(
                      icon: Icons.checklist_rtl_outlined,
                      label: 'Testing',
                      onTap: () => _navigateTo(context, const TestingScreen()),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: AppTheme.shadowLow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar
          GestureDetector(
            onTap:
                () => _navigateTo(
                  context,
                  UserProfileScreen(
                    userName: userName ?? 'User',
                    avatarUrl: avatarUrl,
                  ),
                ),
            child: Hero(
              tag: 'userAvatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lightGrey, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.offWhite,
                  backgroundImage:
                      avatarUrl != null && avatarUrl!.isNotEmpty
                          ? NetworkImage(avatarUrl!)
                          : const AssetImage(
                                'assets/logo/default_avatar_icon.png',
                              )
                              as ImageProvider,
                ),
              ),
            ),
          ),

          // Center Logo & Title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/kulaidoverse_logo.jpg', height: 32),
                const SizedBox(height: AppTheme.spaceXs),
                const Text('KULAIDOVERSE', style: AppTheme.appName),
              ],
            ),
          ),

          // Balance spacer
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.shadowLow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.pureWhite),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                label,
                style: AppTheme.cardTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
