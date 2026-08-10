import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMessages {
  const AuthErrorMessages._();

  static String login(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' =>
        'This account has been disabled. Contact ExamTree support if you need help.',
      'too-many-requests' =>
        'Too many sign-in attempts. Wait a little and try again.',
      'network-request-failed' =>
        'No reliable internet connection. Check your connection and try again.',
      'wrong-password' || 'invalid-credential' || 'user-not-found' =>
        'Email or password is incorrect.',
      'operation-not-allowed' =>
        'Email sign-in is temporarily unavailable. Please try again later.',
      _ => 'Unable to sign in. Please try again.',
    };
  }

  static PasswordResetFailure passwordReset(FirebaseAuthException error) {
    return switch (error.code) {
      // Keep account existence private. Firebase projects with email-enumeration
      // protection enabled normally do this already, but older behaviour can
      // still report user-not-found.
      'user-not-found' => const PasswordResetFailure.hiddenAccount(),
      'invalid-email' => const PasswordResetFailure(
          'Enter a valid email address.',
          canRetry: true,
        ),
      'too-many-requests' => const PasswordResetFailure(
          'Too many reset requests. Wait a little before trying again.',
          canRetry: true,
        ),
      'network-request-failed' => const PasswordResetFailure(
          'No reliable internet connection. Check your connection and try again.',
          canRetry: true,
        ),
      'operation-not-allowed' => const PasswordResetFailure(
          'Password reset is temporarily unavailable. Please try again later.',
        ),
      _ => const PasswordResetFailure(
          'We could not send the reset email. Please try again.',
          canRetry: true,
        ),
    };
  }

  static bool isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty || email.length > 254) return false;
    final at = email.indexOf('@');
    if (at <= 0 || at != email.lastIndexOf('@')) return false;
    final domain = email.substring(at + 1);
    return domain.contains('.') && !domain.startsWith('.') && !domain.endsWith('.');
  }
}

class PasswordResetFailure {
  const PasswordResetFailure(this.message, {this.canRetry = false})
      : shouldShowSuccess = false;

  const PasswordResetFailure.hiddenAccount()
      : message = '',
        canRetry = false,
        shouldShowSuccess = true;

  final String message;
  final bool canRetry;
  final bool shouldShowSuccess;
}
