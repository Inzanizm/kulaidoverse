import 'package:flutter/material.dart';
import 'package:kulaidoverse/home_screen.dart';
import 'package:kulaidoverse/login_screen.dart';
import 'main.dart';

/// This widget decides whether to show login or home screen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user != null) {
      // User already logged in → go to HomeScreen
      return HomeScreen(
        userName: user.userMetadata?['full_name'] ?? 'User',
        avatarUrl: user.userMetadata?['avatar_url'] ?? '',
      );
    }

    // Otherwise → show login screen
    return const LoginScreen();
  }
}
