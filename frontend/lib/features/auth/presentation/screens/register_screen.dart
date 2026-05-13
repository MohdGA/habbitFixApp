import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).register(
        email: _emailCtrl.text.trim(),
        username: _usernameCtrl.text.trim().toLowerCase(),
        displayName: _nameCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your journey',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),

                const SizedBox(height: 8),
                Text(
                  'Create your account and begin transforming your life',
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 32),

                AppTextField(
                  controller: _nameCtrl,
                  label: 'Display Name',
                  hint: 'How should we call you?',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v != null && v.length >= 2) ? null : 'Minimum 2 characters',
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _usernameCtrl,
                  label: 'Username',
                  hint: 'e.g. john_doe (letters, numbers, _)',
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.length < 3) return 'Minimum 3 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) return 'Only letters, numbers, underscores';
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v != null && v.contains('@')) ? null : 'Enter a valid email',
                ).animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: 'Min 8 chars, 1 uppercase, 1 number',
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    icon: Icon(
                      _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Minimum 8 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include at least one uppercase letter';
                    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number';
                    return null;
                  },
                ).animate(delay: 300.ms).fadeIn(),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.red, fontSize: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                AppButton(
                  label: 'Create Account',
                  onPressed: _register,
                  isLoading: _isLoading,
                ).animate(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'By signing up, you agree to our Terms of Service',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
