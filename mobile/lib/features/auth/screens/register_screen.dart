import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!success && mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!success && mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Google sign in failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  double _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;
    return strength.clamp(0, 1);
  }

  Color _strengthColor(double strength) {
    if (strength < 0.3) return const Color(0xFFFF3B30);
    if (strength < 0.6) return const Color(0xFFFF9500);
    return const Color(0xFF34C759);
  }

  String _strengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;
    final strength = _passwordStrength(_passwordController.text);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Join The Swap.',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to start rescuing clothes',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),

                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            error,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Name
                TextFormField(
                  enabled: !isLoading,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Display name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Icon(Icons.person_outline_rounded, size: 22),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0),
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Name is required';
                    if (value.length < 2 || value.length > 50) return 'Name must be 2-50 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  enabled: !isLoading,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Icon(Icons.mail_outline_rounded, size: 22),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  enabled: !isLoading,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Icon(Icons.lock_outline_rounded, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined, size: 22),
                      onPressed: isLoading
                          ? null
                          : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: strength,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _strengthLabel(strength),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _strengthColor(strength),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),

                // Confirm password
                TextFormField(
                  enabled: !isLoading,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Icon(Icons.lock_outline_rounded, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined, size: 22),
                      onPressed: isLoading
                          ? null
                          : () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                    ),
                  ),
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Register button
                FilledButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: isLoading ? null : _googleSignIn,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 16),

                // Terms
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
