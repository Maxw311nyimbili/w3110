// lib/core/constants/app_strings.dart

/// App-wide string constants - eventually move to l10n
class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'MedLink';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String done = 'Done';

  // Onboarding
  static const String onboardingWelcomeTitle = 'Welcome to MedLink';
  static const String onboardingWelcomeSubtitle =
      'Your trusted companion for health information';
  static const String onboardingRoleTitle = 'I am a...';
  static const String onboardingRoleExpectingMother = 'Expecting Mother';
  static const String onboardingRoleHealthcare = 'Healthcare Provider';
  static const String onboardingRoleParent = 'Parent/Caregiver';
  static const String onboardingRoleExplorer = 'Just Exploring';

  // Auth
  static const String signInWithGoogle = 'Continue with Google';
  static const String signOut = 'Sign Out';

  // Chat
  static const String chatInputHint = 'Ask a health question...';
  static const String chatEmptyState = 'Start a conversation';
  static const String chatErrorGeneric = 'Something went wrong. Please try again.';

  // Confidence
  static const String confidenceHigh = 'High confidence';
  static const String confidenceMedium = 'Medium confidence';
  static const String confidenceLow = 'Low confidence';

  // Forum
  static const String forumTitle = 'Community';
  static const String forumNewPost = 'New Post';
  static const String forumOfflineIndicator = 'Syncing...';

  // Scanner
  static const String scannerTitle = 'MedScanner';
  static const String scannerCapture = 'Capture';
  static const String scannerGallery = 'From Gallery';

  // Errors
  static const String errorNetworkTitle = 'No Connection';
  static const String errorNetworkMessage =
      'Please check your internet connection and try again.';
  static const String errorGenericTitle = 'Oops!';
  static const String errorGenericMessage = 'Something went wrong.';
}