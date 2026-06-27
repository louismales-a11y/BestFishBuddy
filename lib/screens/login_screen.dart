import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_sync.dart';
import '../services/theme_provider.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _isSignUp = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final fs = FirebaseSyncService.instance;
    String? err;
    if (_isSignUp) {
      err = await fs.signUp(_emailCtrl.text.trim(), _passCtrl.text);
      if (err == null) await fs.saveUserEmail();
    } else {
      err = await fs.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    }
    if (mounted) {
      if (err == null) {
        Navigator.pop(context);
      } else {
        setState(() { _error = err; _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Create Account' : 'Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_sync, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Sync your catches across devices', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              obscureText: true),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isSignUp ? 'Create Account' : 'Sign In'),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isSignUp)
              TextButton(
                onPressed: () async {
                  final email = _emailCtrl.text.trim();
                  if (email.isEmpty) {
                    setState(() => _error = 'Enter your email first');
                    return;
                  }
                  await FirebaseSyncService.instance.resetPassword(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
                    );
                  }
                },
                child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey)),
              ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
              child: Text(_isSignUp ? 'Already have an account? Sign in' : 'No account? Create one'),
            ),
          ],
        ),
      ),
    );
  }
}
