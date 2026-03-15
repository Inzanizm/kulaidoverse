import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kulaidoverse/services/local_database.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'login_screen.dart';

enum CameraQuality { low, medium, high }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;
  final LocalDatabase _localDb = LocalDatabase();
  final SyncService _syncService = SyncService();

  String? _userId;
  CameraQuality _cameraQuality = CameraQuality.medium;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _qualityOptions = [
    {'label': 'Low (Faster)', 'value': CameraQuality.low},
    {'label': 'Medium (Balanced)', 'value': CameraQuality.medium},
    {'label': 'High (Best Quality)', 'value': CameraQuality.high},
  ];

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null) {
      _userId = user.id;
      _loadUserSettings(user.id);
    }
  }

  Future<void> _loadUserSettings(String userId) async {
    setState(() => _isLoading = true);

    try {
      // Try to load from local first
      final localSettings = await _localDb.getUserSettings(userId);

      if (localSettings != null) {
        setState(() {
          _cameraQuality = _parseCameraQuality(localSettings['camera_quality']);
          _isLoading = false;
        });
        return;
      }

      // If not in local, try Supabase
      try {
        final response =
            await supabase
                .from('user_settings')
                .select('camera_quality')
                .eq('user_id', userId)
                .maybeSingle();

        if (response != null) {
          final quality = response['camera_quality'] ?? 'medium';
          // Save to local for next time
          await _saveSettingsLocally(userId, quality);
          setState(() => _cameraQuality = _parseCameraQuality(quality));
        } else {
          // No settings exist - create default
          await _createDefaultSettings(userId);
        }
      } catch (e) {
        // Supabase failed (maybe offline), use default
        debugPrint('Supabase failed, using default: $e');
        setState(() => _cameraQuality = CameraQuality.medium);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() => _cameraQuality = CameraQuality.medium);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this helper method
  Future<void> _createDefaultSettings(String userId) async {
    const defaultQuality = 'medium';
    try {
      await _saveSettingsLocally(userId, defaultQuality);
      setState(() => _cameraQuality = CameraQuality.medium);

      // Try to sync to Supabase
      if (await _syncService.isOnline()) {
        await _syncService.syncUserSettings(userId);
      }
    } catch (e) {
      debugPrint('Error creating default settings: $e');
    }
  }

  CameraQuality _parseCameraQuality(String? value) {
    switch (value) {
      case 'low':
        return CameraQuality.low;
      case 'high':
        return CameraQuality.high;
      case 'medium':
      default:
        return CameraQuality.medium;
    }
  }

  String _cameraQualityToString(CameraQuality quality) {
    switch (quality) {
      case CameraQuality.low:
        return 'low';
      case CameraQuality.high:
        return 'high';
      case CameraQuality.medium:
        return 'medium';
    }
  }

  Future<void> _saveSettingsLocally(String userId, String quality) async {
    await _localDb.saveUserSettings({
      'user_id': userId,
      'camera_quality': quality,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<void> _updateCameraQuality(CameraQuality quality) async {
    if (_userId == null) return;

    final qualityString = _cameraQualityToString(quality);

    // Save locally first
    await _saveSettingsLocally(_userId!, qualityString);

    setState(() => _cameraQuality = quality);

    // Try to sync if online
    if (await _syncService.isOnline()) {
      await _syncService.syncUserSettings(_userId!);
    }
  }

  Future<void> _signOut() async {
    if (_userId != null) {
      // Ensure settings are synced before logout
      await _syncService.syncUserSettings(_userId!);
    }

    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign-out failed: $e');
    }

    await supabase.auth.signOut();

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

                  // Developer Names (Placeholder)
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
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Section Title
                    const Text(
                      "Camera Settings",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Camera Quality Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CameraQuality>(
                          isExpanded: true,
                          value: _cameraQuality,
                          icon: const Icon(Icons.arrow_drop_down),
                          items:
                              _qualityOptions.map((option) {
                                return DropdownMenuItem<CameraQuality>(
                                  value: option['value'],
                                  child: Text(option['label']),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateCameraQuality(value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quality Description
                    Text(
                      'Affects all camera modes in Color Camera',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
