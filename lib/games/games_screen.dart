// lib/games/games_screen.dart
import 'package:flutter/material.dart';
import 'package:kulaidoverse/theme.dart';
import 'colormixlab.dart';
import 'huehunt.dart';
import 'huellision.dart';
import 'huetheimp.dart';
import 'tonetrail.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Unified App Bar (same style as HomeScreen)
            _buildAppBar(context),

            const SizedBox(height: AppTheme.spaceLg),

            // Title Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? AppTheme.spaceMd : AppTheme.spaceLg,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("Games", style: AppTheme.screenTitle),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Games Grid
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
          // Back Button (square style like original, but using theme colors)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.softBlack,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.pureWhite,
                size: 18,
              ),
            ),
          ),

          // Center Logo & Title (same as HomeScreen)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
                const SizedBox(height: AppTheme.spaceXs),
                const Text("KULAIDOVERSE", style: AppTheme.appName),
              ],
            ),
          ),

          // Balance spacer (same width as back button)
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGameCard(
                title: "Hue Hunt",
                logoPath: "assets/game_logos/huehunt_logo.png",
                onPressed: () => _navigateTo(context, const Huehunt()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildGameCard(
                title: "Tone Trail",
                logoPath: "assets/game_logos/tonetrail_logo.png",
                onPressed: () => _navigateTo(context, const Tonetrail()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildGameCard(
                title: "Hue the Impostor",
                logoPath: "assets/game_logos/huetheimpostor_logo.png",
                onPressed: () => _navigateTo(context, const Whotheimp()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildGameCard(
                title: "Color Mixing Lab",
                logoPath: "assets/game_logos/colormixinglab_logo.png",
                onPressed: () => _navigateTo(context, const ColorMixLab()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        SizedBox(
          width: double.infinity,
          child: _buildGameCard(
            title: "Huellision",
            logoPath: "",
            onPressed: () => _navigateTo(context, const Huellision()),
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
              child: _buildGameCard(
                title: "Hue Hunt",
                logoPath: "assets/game_logos/huehunt_logo.png",
                onPressed: () => _navigateTo(context, const Huehunt()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildGameCard(
                title: "Tone Trail",
                logoPath: "assets/game_logos/tonetrail_logo.png",
                onPressed: () => _navigateTo(context, const Tonetrail()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildGameCard(
                title: "Hue the Impostor",
                logoPath: "assets/game_logos/huetheimpostor_logo.png",
                onPressed: () => _navigateTo(context, const Whotheimp()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildGameCard(
                title: "Color Mixing Lab",
                logoPath: "assets/game_logos/colormixinglab_logo.png",
                onPressed: () => _navigateTo(context, const ColorMixLab()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildGameCard(
                title: "Huellision",
                logoPath: "",
                onPressed: () => _navigateTo(context, const Huellision()),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(child: const SizedBox()), // Empty slot for balance
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
      ],
    );
  }

  Widget _buildGameCard({
    required String title,
    required String logoPath,
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
            if (logoPath.isNotEmpty)
              Image.asset(
                logoPath,
                height: 56,
                width: 56,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.sports_esports_rounded,
                    size: 40,
                    color: AppTheme.pureWhite,
                  );
                },
              )
            else
              const Icon(
                Icons.sports_esports_rounded,
                size: 40,
                color: AppTheme.pureWhite,
              ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
