import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  final _caregiverNameController = TextEditingController();
  final _caregiverEmailController = TextEditingController();
  final _pillNameController = TextEditingController(text: 'Red pill');
  TimeOfDay _selectedTime = const TimeOfDay(hour: 17, minute: 0);

  final List<Map<String, String>> _caregivers = [];
  String? _savedScheduleSummary;

  // 👇 NEW: fields to store data coming from previous screen
  String? userName;
  int? caregiverId;

  Timer? _reminderTimer;
  DateTime? _lastReminderDate;

  @override
  void initState() {
  super.initState();
  _startReminderTimer();
}

void _startReminderTimer() {
  _reminderTimer?.cancel();

  // Check every 30 seconds (you can change to 1 minute if you prefer)
  _reminderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    // If no schedule has been saved yet, do nothing
    if (_savedScheduleSummary == null) return;

    final now = DateTime.now();

    // If we already showed a reminder today, don't show again
    if (_lastReminderDate != null &&
        _lastReminderDate!.year == now.year &&
        _lastReminderDate!.month == now.month &&
        _lastReminderDate!.day == now.day) {
      return;
    }

    // Compare current time to scheduled time
    if (now.hour == _selectedTime.hour &&
        now.minute == _selectedTime.minute) {
      _lastReminderDate = now;
      _showPillReminder();
    }
  });
}

void _showPillReminder() {
  final pillName = _pillNameController.text.isEmpty
      ? 'your pill'
      : _pillNameController.text;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pill reminder'),
        content: Text('It is time to take $pillName.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              // Go directly to scan page, with the expected pill name
              Navigator.pushNamed(
                context,
                '/user/scan',
                arguments: pillName,
              );
            },
            child: const Text('Scan my pill'),
          ),
        ],
      );
    },
  );
}




  @override
  void dispose() {
    _reminderTimer?.cancel();
    _caregiverNameController.dispose();
    _caregiverEmailController.dispose();
    _pillNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This runs when the widget gets its context,
    // we read route arguments only once
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      userName ??= args['name'] as String?;
      caregiverId ??= args['id'] as int?;
    }
  }

  void _addCaregiver() {
    if (_caregiverNameController.text.isEmpty ||
        _caregiverEmailController.text.isEmpty) {
      return;
    }

    setState(() {
      _caregivers.add({
        'name': _caregiverNameController.text,
        'email': _caregiverEmailController.text,
      });
      _caregiverNameController.clear();
      _caregiverEmailController.clear();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAll() async {
  if (caregiverId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No caregiver id (prototype).')),
    );
    return;
  }

  final timeStr =
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  final uri =
      Uri.parse('http://localhost:3000/caregivers/$caregiverId/schedule');

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Saving to backend...')),
  );

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'pillName': _pillNameController.text,
      'time': timeStr,
    }),
  );

  if (response.statusCode == 200) {
    setState(() {
      _savedScheduleSummary =
          'Pill "${_pillNameController.text}" at ${_selectedTime.format(context)}';

      // 🔁 reset last reminder so today's new schedule can trigger again
      _lastReminderDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule saved. Reminder armed.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${response.body}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Welcome ${userName ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Caregivers box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add caregivers',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _caregiverNameController,
                      decoration:
                          const InputDecoration(labelText: 'Caregiver name'),
                    ),
                    TextField(
                      controller: _caregiverEmailController,
                      decoration:
                          const InputDecoration(labelText: 'Caregiver email'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _addCaregiver,
                      child: const Text('Add caregiver'),
                    ),
                    const SizedBox(height: 8),
                    if (_caregivers.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _caregivers
                            .map(
                              (c) => Text('- ${c['name']} (${c['email']})'),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Schedule box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pill schedule',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _pillNameController,
                      decoration:
                          const InputDecoration(labelText: 'Pill name / color'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Time: ${_selectedTime.format(context)}'),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _pickTime,
                          child: const Text('Change time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _saveAll,
                      child: const Text('Save schedule'),
                    ),
                    if (_savedScheduleSummary != null) ...[
                      const SizedBox(height: 8),
                      Text('Saved: $_savedScheduleSummary'),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
