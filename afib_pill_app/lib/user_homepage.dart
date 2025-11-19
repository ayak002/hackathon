import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read expected pill name from arguments (passed from CaregiverHomePage)
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final nextPill = args ?? 'Red pill'; // fallback
    const nextTime = '17:00'; // still hardcoded for now

    return Scaffold(
      appBar: AppBar(title: const Text('Patient – Pills')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Today\'s schedule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Next pill: $nextPill'),
              const Text('Time: $nextTime'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/user/scan',
                    arguments: nextPill, // 🔹 pass expected pill to scan page
                  );
                },
                child: const Text('Scan pill now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
