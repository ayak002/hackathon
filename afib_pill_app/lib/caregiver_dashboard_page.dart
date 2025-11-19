import 'package:flutter/material.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final caregiverName = args != null ? (args['name'] as String? ?? '') : '';

    // 🔹 For now: mock patients. Later: load from backend.
    final patients = [
      {
        'name': 'Aya',
        'pill': 'Red pill',
        'time': '17:00',
        'status': 'OK',
      },
      {
        'name': 'Marie',
        'pill': 'Blue pill',
        'time': '20:00',
        'status': 'Wrong pill yesterday',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caregiverName.isEmpty
                  ? 'Welcome, caregiver'
                  : 'Welcome, $caregiverName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your patients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final p = patients[index];
                  return Card(
                    child: ListTile(
                      title: Text(p['name'] ?? ''),
                      subtitle: Text(
                        'Pill: ${p['pill']}\nTime: ${p['time']}\nStatus: ${p['status']}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        onPressed: () {
                          // 🔹 Later: send notification / alert
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Would notify ${p['name']} about their pill.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
