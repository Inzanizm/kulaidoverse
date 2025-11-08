import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    const webClientId =
        '957390893057-fbbe556fqfg9bno9k9cpgl2uc5fvf5b5.apps.googleusercontent.com';
    const iosClientId =
        '957390893057-mpgduur1apma79i347d8rj9l0u2mf0r1.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      await googleSignIn.signOut(); // ensure fresh login
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // cancelled
      }

      final googleAuth = await googleUser.authentication;
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      final user = supabase.auth.currentUser;
      if (mounted && user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => HomeScreen(
                  userName: user.userMetadata?['full_name'] ?? 'User',
                  avatarUrl: user.userMetadata?['avatar_url'] ?? '',
                ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      if (!mounted) return; // prevents context use if widget is gone
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Logo
            Center(
              child: Image.asset(
                'assets/logo/kulaidoverse_logo_text.jpg',
                width: 300,
                height: 300,
              ),
            ),

            // Google Button at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 3,
                    ),
                    icon: Image.asset(
                      'assets/logo/google_icon.png', // add this asset
                      height: 24,
                    ),
                    label: Text(
                      _isLoading ? "Signing in..." : "Sign in with Google",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isLoading ? null : _signInWithGoogle,
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
