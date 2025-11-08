import 'package:flutter/material.dart';
import 'package:kulaidoverse/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qjuhbmhbbbrwuynipzpi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqdWhibWhiYmJyd3V5bmlwenBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1NzE4NTIsImV4cCI6MjA3NTE0Nzg1Mn0.xkthRQvTkjlwG6JVebtK6zcPj0XM_PrCLkM6xxRT-1M',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login + Supabase',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
