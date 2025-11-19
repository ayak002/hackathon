import 'package:flutter/material.dart';
import 'caregiver_register_page.dart';
import 'caregiver_homepage.dart';
import 'user_homepage.dart';
import 'scan_pill_page.dart';


void main() {
  runApp(const AFibPillApp());
}

class AFibPillApp extends StatelessWidget {
  const AFibPillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFib Pill Guardian',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/caregiver/register': (context) => const CaregiverRegisterPage(),
        '/caregiver/home': (context) => const CaregiverHomePage(),
        '/user/home': (context) => const UserHomePage(),
        '/user/scan': (context) => const ScanPillPage(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AFib Pill Guardian')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Who are you?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/caregiver/register');
              },
              child: const Text('Caregiver / Patient setup'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user/home');
              },
              child: const Text('User (Patient)'),
            ),
          ],
        ),
      ),
    );
  }
}
