const googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '1083299267005-s50rpi93utao2k8m7446ht8ql782ov1q.apps.googleusercontent.com',
);

// Public OAuth client identifier for the iOS app. This is intentionally not
// given a fake/default value: a production iOS build must supply the exact
// client registered for com.examtree.examtree.
const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

bool isGoogleOAuthClientId(String value) {
  final normalized = value.trim();
  return normalized.isNotEmpty &&
      normalized.endsWith('.apps.googleusercontent.com');
}

bool get isGoogleSignInConfigured => isGoogleOAuthClientId(googleServerClientId);

bool get isGoogleIosSignInConfigured => isGoogleOAuthClientId(googleIosClientId);
