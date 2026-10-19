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
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String _role = 'farmer';
  bool _loading = false;

  Future<void> _register() async {
    if (_username.text.isEmpty || _password.text.length < 6 || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required fields (password 6+)')),
      );
      return;
    }
    setState(() => _loading = true);
    final res = await ApiService.register({
      'username': _username.text.trim(),
      'password': _password.text,
      'phone': _phone.text.trim(),
      'role': _role,
      'region': _region.text.trim(),
      'woreda': _woreda.text.trim(),
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;

    if (res['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${res['body']}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username *', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password * (min 6)', prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone * (09...)', prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'farmer', child: Text('I am a Farmer')),
                DropdownMenuItem(value: 'buyer', child: Text('I am a Buyer')),
                DropdownMenuItem(value: 'transporter', child: Text('I am a Transporter')),
                DropdownMenuItem(value: 'admin', child: Text('I am an Admin')),
              ],
              onChanged: (v) => setState(() => _role = v!),
              decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.work)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'First Name'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Last Name'))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _region, decoration: const InputDecoration(labelText: 'Region', prefixIcon: Icon(Icons.map))),
            const SizedBox(height: 16),
            TextField(controller: _woreda, decoration: const InputDecoration(labelText: 'Woreda', prefixIcon: Icon(Icons.location_city))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}