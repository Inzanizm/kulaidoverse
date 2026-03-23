// lib/testing/testing_screen.dart
import 'package:flutter/material.dart';
import 'package:kulaidoverse/theme.dart';
import 'package:kulaidoverse/testing/d15men.dart';
import 'lanterntest.dart';
import 'ishihara.dart';
import 'hrr.dart';
import 'mosaic.dart';

class TestingScreen extends StatelessWidget {
  const TestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.softBlack,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
            const SizedBox(height: 4),
            const Text(
              "KULAIDOVERSE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spaceLg),

            // Title Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? AppTheme.spaceMd : AppTheme.spaceLg,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("Testing", style: AppTheme.screenTitle),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Tests Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isSmallScreen ? AppTheme.spaceMd : AppTheme.spaceLg,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child:
                          isTablet
                              ? _buildTabletLayout(context)
                              : _buildMobileLayout(context),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTestCard(
                title: "Ishihara-Test",
                icon: Icons.remove_red_eye,
                onPressed: () => _navigateTo(context, const IshiharaScreen()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildTestCard(
                title: "D-15 Test",
                icon: Icons.view_agenda,
                onPressed:
                    () => _navigateTo(context, const D15TestMenuScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildTestCard(
                title: "Mosaic Test",
                icon: Icons.grid_on,
                onPressed: () => _navigateTo(context, const mosaic()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildTestCard(
                title: "Lantern Test",
                icon: Icons.circle,
                onPressed: () => _navigateTo(context, const Lanterntest()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        SizedBox(
          width: double.infinity,
          child: _buildTestCard(
            title: "HRR-Test",
            icon: Icons.bubble_chart,
            onPressed: () => _navigateTo(context, HRRScreen()),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTestCard(
                title: "Ishihara-Test",
                icon: Icons.remove_red_eye,
                onPressed: () => _navigateTo(context, const IshiharaScreen()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildTestCard(
                title: "D-15 Test",
                icon: Icons.view_agenda,
                onPressed:
                    () => _navigateTo(context, const D15TestMenuScreen()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildTestCard(
                title: "Mosaic Test",
                icon: Icons.grid_on,
                onPressed: () => _navigateTo(context, const mosaic()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildTestCard(
                title: "Lantern Test",
                icon: Icons.circle,
                onPressed: () => _navigateTo(context, const Lanterntest()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildTestCard(
                title: "HRR-Test",
                icon: Icons.bubble_chart,
                onPressed: () => _navigateTo(context, HRRScreen()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(child: const SizedBox()), // Empty for balance
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
      ],
    );
  }

  Widget _buildTestCard({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 140,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.softBlack,
          foregroundColor: AppTheme.pureWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.pureWhite),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
