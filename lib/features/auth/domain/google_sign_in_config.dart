const googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '1083299267005-s50rpi93utao2k8m7446ht8ql782ov1q.apps.googleusercontent.com',
);

bool get isGoogleSignInConfigured =>
    googleServerClientId.trim().isNotEmpty &&
    googleServerClientId.endsWith('.apps.googleusercontent.com');
