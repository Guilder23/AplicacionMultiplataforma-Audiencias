import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.headerGradient,
        child: const SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.balance_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Sis de Audiencias MI ADA🥺😊❤️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Materia de Familia',
                style: TextStyle(color: Color(0xFFF6D8DD), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
