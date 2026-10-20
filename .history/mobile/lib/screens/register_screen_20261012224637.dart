import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _region = TextEditingController();
  final _woreda = TextEditingController();
  String _role = 'farmer';
  bool _loading = false;

  Future<void> _register() async {
    if (_username.text.isEmpty ||
        _password.text.length < 6 ||
        _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required fields (password 6+)')),
      );
      return;
    }
    setState(() => _loading = true);
    final result = await ApiService.register({
      'username': _username.text.trim(),
      'password': _password.text,
      'phone': _phone.text.trim(),
      'role': _role,
      'region': _region.text.trim(),
      'woreda': _woreda.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;

    if (result['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${result['body']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (09...)'),
            ),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'farmer', child: Text('I am a Farmer')),
                DropdownMenuItem(value: 'buyer', child: Text('I am a Buyer')),
              ],
              onChanged: (v) => setState(() => _role = v!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: _region,
              decoration: const InputDecoration(labelText: 'Region'),
            ),
            TextField(
              controller: _woreda,
              decoration: const InputDecoration(labelText: 'Woreda'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
