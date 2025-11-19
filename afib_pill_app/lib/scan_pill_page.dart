import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanPillPage extends StatefulWidget {
  const ScanPillPage({super.key});

  @override
  State<ScanPillPage> createState() => _ScanPillPageState();
}

class _ScanPillPageState extends State<ScanPillPage> {
  String _status = 'Waiting for AI analysis...';
  bool _isCorrect = false;
  bool _hasResult = false;

  // 👇 Store the expected pill we receive from the previous screen
  String? _expectedPill;

  Future<void> _simulateAI({required bool correct}) async {
    setState(() {
      _status = 'Analyzing...';
      _hasResult = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isCorrect = correct;
      _hasResult = true;
      _status = correct
          ? 'Correct pill detected. You can take it.'
          : 'Wrong pill detected! Do NOT take it.';
    });

    // Make sure we have a value (fallback just in case)
    final pillName = _expectedPill ?? 'Red pill';

    // Send event to backend (prototype)
    final uri = Uri.parse('http://localhost:3000/intake');

    await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'caregiverId': 1, // hardcoded for prototype
        'pillName': pillName,
        'expectedTime': '17:00',
        'detectedPill': correct ? pillName : 'Blue pill',
        'isCorrect': correct,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize _expectedPill once, from navigation arguments
    _expectedPill ??=
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Red pill';

    final expectedPill = _expectedPill!;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan your pill')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Expected pill: $expectedPill'),
            const SizedBox(height: 16),

            // Here we would show the real camera preview
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Camera preview (placeholder)'),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                fontSize: 16,
                color: !_hasResult
                    ? Colors.black
                    : _isCorrect
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _simulateAI(correct: true),
                  child: const Text('Simulate CORRECT pill'),
                ),
                ElevatedButton(
                  onPressed: () => _simulateAI(correct: false),
                  child: const Text('Simulate WRONG pill'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
