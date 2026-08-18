import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/auth_error_messages.dart';
import 'providers/auth_providers.dart';
import 'widgets/auth_visual_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _registerMode = false;
  String? _loadingMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_registerMode) {
      await _register();
    } else {
      await _login();
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!AuthErrorMessages.isValidEmail(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Enter your password.');
      return;
    }

    _beginLoading('Preparing sign-in…');
    try {
      await ref.read(authControllerProvider).signInWithEmailAndPassword(
            email,
            password,
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on AuthEmailVerificationRequiredException catch (error) {
      if (!mounted) return;
      _showMessage(
        '${error.message} Open the link in your email, then return here and sign in again.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(AuthErrorMessages.login(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage('${error.message} Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to sign in. Please try again.');
    } finally {
      _endLoading();
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    _beginLoading('Preparing Google sign-in…');
    try {
      await ref.read(authControllerProvider).signInWithGoogle(
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on GoogleSignInException catch (error) {
      if (!mounted) return;
      final detail = error.description?.trim();
      if (error.code == GoogleSignInExceptionCode.canceled) {
        _showMessage(
          detail == null || detail.isEmpty
              ? 'Google sign-in was canceled. If you already selected an account, Android OAuth configuration was not accepted. Please try once more.'
              : 'Google sign-in stopped after account selection: $detail',
        );
        return;
      }
      _showMessage(
        detail == null || detail.isEmpty
            ? 'Google sign-in failed (${error.code.name}). Please try again.'
            : 'Google sign-in failed (${error.code.name}): $detail',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'operation-not-allowed' =>
          'Google sign-in is not enabled in Firebase Authentication.',
        'account-exists-with-different-credential' =>
          'This email already has an ExamTree sign-in method. Sign in with that method first, then try Google again.',
        'invalid-credential' =>
          'Firebase rejected the Google credential. Check the Android Google sign-in configuration.',
        'google-email-unverified' =>
          'Google did not provide a verified email for this account.',
        'network-request-failed' =>
          'Google sign-in could not reach Firebase. Check your connection and try again.',
        _ => error.message?.trim().isNotEmpty == true
            ? 'Google sign-in failed (${error.code}): ${error.message!.trim()}'
            : 'Google sign-in failed (${error.code}). Please try again.',
      };
      _showMessage(message);
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to sign in with Google: $error');
    } finally {
      _endLoading();
    }
  }

  Future<void> _register() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    if (name.length < 2) {
      _showMessage('Enter your name.');
      return;
    }
    if (name.length > 80) {
      _showMessage('Name must be 80 characters or fewer.');
      return;
    }
    if (!AuthErrorMessages.isValidEmail(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Use at least 6 characters for your password.');
      return;
    }
    if (password != confirmation) {
      _showMessage('Passwords do not match.');
      return;
    }

    _beginLoading('Preparing account setup…');
    try {
      await ref.read(authControllerProvider).registerWithEmailAndPassword(
            displayName: name,
            email: email,
            password: password,
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on AuthEmailVerificationRequiredException catch (error) {
      if (!mounted) return;
      _showMessage(
        '${error.message} Open the link in your email, then return here and sign in.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(AuthErrorMessages.registration(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to create your account. Please try again.');
    } finally {
      _endLoading();
    }
  }

  void _beginLoading(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  void _onSetupStage(AuthSetupStage stage) {
    if (!mounted) return;
    setState(() => _loadingMessage = stage.message);
  }

  void _endLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });
  }

  void _toggleMode() {
    if (_isLoading) return;
    setState(() {
      _registerMode = !_registerMode;
      _confirmPasswordController.clear();
    });
  }

  void _openPasswordRecovery() {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final query = AuthErrorMessages.isValidEmail(email)
        ? '?email=${Uri.encodeQueryComponent(email)}'
        : '';
    context.push('/forgot-password$query');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 8),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final registering = _registerMode;

    return AuthPageFrame(
      child: AutofillGroup(
        child: AuthSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthCardHeading(
                title: registering ? 'Join ExamTree' : 'Sign in to ExamTree',
                subtitle: registering
                    ? 'Create one account for your tests, results and progress across mobile and web.'
                    : 'Continue your tests and progress with the same ExamTree account you use elsewhere.',
                icon: registering
                    ? Icons.person_add_alt_1_outlined
                    : Icons.login_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Continue with Google'),
                ),
              ),
              if (_isLoading && _loadingMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                AuthLoadingStatus(message: _loadingMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              const AuthDivider(),
              const SizedBox(height: AppSpacing.lg),
              if (registering) ...[
                TextField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: authInputDecoration(
                    context,
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: authInputDecoration(
                  context,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: _obscurePassword,
                textInputAction: registering
                    ? TextInputAction.next
                    : TextInputAction.done,
                autofillHints: [
                  registering
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                onSubmitted: (_) {
                  if (!_isLoading && !registering) _submit();
                },
                decoration: authInputDecoration(
                  context,
                  label: 'Password',
                  helperText: registering ? 'Use at least 6 characters.' : null,
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: _isLoading
                        ? null
                        : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              if (registering) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) {
                    if (!_isLoading) _submit();
                  },
                  decoration: authInputDecoration(
                    context,
                    label: 'Confirm password',
                    icon: Icons.lock_reset_outlined,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthPrivacyNote(
                  icon: Icons.mark_email_read_outlined,
                  text:
                      'Email accounts are verified before your learner profile is activated.',
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _openPasswordRecovery,
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(registering ? 'Create Account' : 'Sign In'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _isLoading ? null : _toggleMode,
                child: Text(
                  registering
                      ? 'Already have an account? Sign in'
                      : 'New to ExamTree? Create account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
