
import 'package:booking_app/app.dart';
import 'package:booking_app/features/services/data/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = FirebaseAuthService();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController(); 

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingApp()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome Back',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () => _run(() async {
                          final email = _emailCtrl.text.trim();
                          final pass = _passCtrl.text.trim();
                          if (email.isEmpty || pass.isEmpty) {
                            throw 'Please enter email & password';
                          }
                          await _authService.signInWithEmailPassword(email: email, password: pass);
                        }),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('OR'),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 14),

            _SocialButton(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata,
              background: Colors.white,
              foreground: Colors.black87,
              borderColor: Colors.grey.shade300,
              onPressed: _loading ? null : () => _run(() async => _authService.signInWithGoogle()),
            ),
            const SizedBox(height: 10),

            _SocialButton(
              label: 'Continue with Facebook',
              icon: Icons.facebook,
              background: const Color(0xFF1877F2),
              foreground: Colors.white,
              onPressed: _loading ? null : () => _run(() async => _authService.signInWithFacebook()),
            ),
            const SizedBox(height: 10),

            _SocialButton(
              label: 'Continue with Apple',
              icon: Icons.apple,
              background: Colors.black,
              foreground: Colors.white,
              onPressed: _loading ? null : () => _run(() async => _authService.signInWithApple()),
            ),

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          ),
                  child: Text('Sign up', style: TextStyle(color: cs.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: foreground),
        label: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
          ),
        ),
      ),
    );
  }
}
