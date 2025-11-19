import 'package:flutter/material.dart';

class CaregiverPortalRegisterPage extends StatefulWidget {
  const CaregiverPortalRegisterPage({super.key});

  @override
  State<CaregiverPortalRegisterPage> createState() =>
      _CaregiverPortalRegisterPageState();
}

class _CaregiverPortalRegisterPageState
    extends State<CaregiverPortalRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 🔹 For NOW: we don't call the backend.
      // Later we can POST to /caregivers_app/register or similar.
      // We just navigate to the dashboard and pass the caregiver name.

      Navigator.pushReplacementNamed(
        context,
        '/caregiver/dashboard',
        arguments: {
          'name': _nameController.text,
          'email': _emailController.text,
        },
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver – Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Create your caregiver account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 4 ? 'Min 4 characters' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Continue to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
