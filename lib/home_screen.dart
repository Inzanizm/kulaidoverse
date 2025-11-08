import 'package:flutter/material.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? userName;
  final String? avatarUrl;

  const HomeScreen({super.key, this.userName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage(
                                  'assets/logo/default_avatar_icon.png',
                                )
                                as ImageProvider,
                  ),

                  // App Logo and Name
                  Column(
                    children: [
                      Image.asset(
                        'assets/logo/kulaidoverse_logo.jpg',
                        height: 32,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'KULAIDOVERSE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  // Settings Button
                  IconButton(
                    icon: const Icon(Icons.settings, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Dashboard Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Grid Dashboard Buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.camera_alt_outlined,
                      label: 'Color Camera',
                    ),
                    _buildDashboardCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Learning',
                    ),
                    _buildDashboardCard(
                      icon: Icons.videogame_asset_outlined,
                      label: 'Games',
                    ),
                    _buildDashboardCard(
                      icon: Icons.checklist_rtl_outlined,
                      label: 'Testing',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to feature page
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
