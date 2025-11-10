import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;
  bool _saveEnabled = false;
  String? _userId;

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
    final response =
        await supabase
            .from('user_settings')
            .select('switch_sample')
            .eq('user_id', userId)
            .maybeSingle();

    if (response == null) {
      await supabase.from('user_settings').insert({
        'user_id': userId,
        'switch_sample': false,
      });
    } else {
      setState(() {
        _saveEnabled = response['switch_sample'] ?? false;
      });
    }
  }

  Future<void> _updateUserSetting(bool value) async {
    if (_userId == null) return;
    await supabase
        .from('user_settings')
        .update({
          'switch_sample': value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', _userId!);

    setState(() => _saveEnabled = value);
  }

  Future<void> _signOut() async {
    if (_userId != null) {
      await supabase
          .from('user_settings')
          .update({
            'switch_sample': _saveEnabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _userId!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🔹 Save Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Switch Sample Setting",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _saveEnabled,
                  onChanged: (val) => _updateUserSetting(val),
                ),
              ],
            ),
            const Spacer(),

            // 🔹 Logout Button
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
