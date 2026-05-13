import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showForgotPasswordSheet(BuildContext context, Dio dio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ForgotPasswordSheet(dio: dio),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _errorMessage = e is AppException ? e.userMessage : e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.streakGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('🔥', style: TextStyle(fontSize: 32))),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate(delay: 100.ms).slideX(begin: -0.1, duration: 300.ms).fadeIn(),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue your journey',
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 40),

                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                ).animate(delay: 200.ms).slideY(begin: 0.1, duration: 300.ms).fadeIn(),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    icon: Icon(
                      _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                  validator: (v) => (v != null && v.length >= 8) ? null : 'Minimum 8 characters',
                ).animate(delay: 250.ms).slideY(begin: 0.1, duration: 300.ms).fadeIn(),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      final dio = ref.read(dioProvider);
                      _showForgotPasswordSheet(context, dio);
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.orange, fontSize: 14),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                AppButton(
                  label: 'Sign In',
                  onPressed: _login,
                  isLoading: _isLoading,
                ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Forgot Password Sheet ────────────────────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  final Dio dio;
  const _ForgotPasswordSheet({required this.dio});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  // Step 1 — email
  final _emailCtrl = TextEditingController();
  // Step 2 — new password
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _step = 1; // 1 = email, 2 = new password, 3 = success
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _userId;
  String? _token;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await widget.dio.post('/auth/forgot-password', data: {'email': email});
      final data = res.data as Map<String, dynamic>;
      if (mounted) setState(() {
        _userId = data['userId'] as String;
        _token = data['token'] as String;
        _step = 2;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;
      setState(() { _loading = false; _error = msg ?? 'Something went wrong. Please try again.'; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'An unexpected error occurred'; });
    }
  }

  Future<void> _submitNewPassword() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pass.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (!pass.contains(RegExp(r'[A-Z]'))) {
      setState(() => _error = 'Password must contain at least one uppercase letter');
      return;
    }
    if (!pass.contains(RegExp(r'[0-9]'))) {
      setState(() => _error = 'Password must contain at least one number');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.dio.post('/auth/reset-password', data: {
        'userId': _userId,
        'token': _token,
        'password': pass,
      });
      if (mounted) setState(() { _step = 3; _loading = false; });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;
      setState(() { _loading = false; _error = msg ?? 'Reset failed. Please try again.'; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'An unexpected error occurred'; });
    }
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(color: const Color(0xFF3F3F46), borderRadius: BorderRadius.circular(2)),
    ),
  );

  Widget _buildError() => _error == null ? const SizedBox.shrink() : Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(children: [
      const Icon(Icons.error_outline, color: Color(0xFFFF453A), size: 15),
      const SizedBox(width: 6),
      Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFFF453A), fontSize: 13))),
    ]),
  );

  Widget _buildButton(String label, VoidCallback onPressed) => ElevatedButton(
    onPressed: _loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF9F0A),
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      disabledBackgroundColor: const Color(0xFFFF9F0A).withValues(alpha: 0.5),
    ),
    child: _loading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),

          // ── Step 1: Email ──
          if (_step == 1) ...[
            const Text('Forgot password?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Enter your account email to reset your password.", style: TextStyle(color: Color(0xFF71717A), fontSize: 13)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitEmail(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: Color(0xFF71717A)),
                labelStyle: TextStyle(color: Color(0xFF71717A)),
              ),
            ),
            _buildError(),
            const SizedBox(height: 24),
            _buildButton('Continue', _submitEmail),
          ],

          // ── Step 2: New Password ──
          if (_step == 2) ...[
            const Text('Set new password', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Choose a strong password for your account.", style: TextStyle(color: Color(0xFF71717A), fontSize: 13)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'New password',
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Color(0xFF71717A)),
                labelStyle: const TextStyle(color: Color(0xFF71717A)),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF71717A)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitNewPassword(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Confirm password',
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Color(0xFF71717A)),
                labelStyle: const TextStyle(color: Color(0xFF71717A)),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF71717A)),
                ),
              ),
            ),
            _buildError(),
            const SizedBox(height: 24),
            _buildButton('Reset Password', _submitNewPassword),
          ],

          // ── Step 3: Success ──
          if (_step == 3) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF30D158).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30D158).withValues(alpha: 0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF30D158), size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Password reset successfully! You can now sign in.', style: TextStyle(color: Color(0xFF30D158), fontSize: 13, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Color(0xFF3F3F46)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Sign In', style: TextStyle(color: Color(0xFFA1A1AA))),
            ),
          ],
        ],
      ),
    );
  }
}
