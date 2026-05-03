import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 12),
                TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 4),
                ],
                ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (_password.text != _confirm.text) {
                            setState(() => _error = 'Passwords do not match');
                            return;
                          }
                          setState(() => _error = null);
                          try {
                            await auth.signup(name: _name.text.trim(), email: _email.text.trim(), password: _password.text.trim());
                            if (context.mounted) context.goNamed(AppRoutes.home);
                          } catch (e) {
                            if (context.mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
                          }
                        },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
