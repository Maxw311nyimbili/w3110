/// Shared data model for Privacy Policy and Terms of Service content.
library;

class PolicySection {
  const PolicySection({required this.heading, required this.body});
  final String heading;
  final String body;
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVACY POLICY
// ─────────────────────────────────────────────────────────────────────────────

const String kPrivacyPolicyTitle = 'Privacy Policy';
const String kPrivacyPolicyDate = 'Effective: 21 June 2026';

const List<PolicySection> kPrivacySections = [
  PolicySection(
    heading: '1. Who We Are',
    body:
        'Naiia is a maternal health companion app. We use artificial intelligence to provide personalised health information to pregnant women, new mothers, healthcare professionals, and support partners.\n\nContact: nyimbilimaxwell9@gmail.com',
  ),
  PolicySection(
    heading: '2. What Personal Data We Collect',
    body:
        'When you use Naiia, we collect:\n\n'
        '• Account information — your email address, display name, and profile photo (obtained from your Google account via Firebase Authentication).\n\n'
        '• Profile data — your role (Mother, Support Partner, Doctor, Midwife, Clinician), account nickname, and health interests you select during onboarding.\n\n'
        '• Health conversations — the text of every message you send to Naiia and the AI responses you receive.\n\n'
        '• Medication scans — photos you take using the MedScanner and the extracted drug or barcode information.\n\n'
        '• Community forum content — posts and comments you publish.\n\n'
        '• Preferences — your chosen language, colour theme, and app rating.\n\n'
        '• Usage data — session timestamps and basic technical device information.',
  ),
  PolicySection(
    heading: '3. Why We Collect It',
    body:
        'We collect this data solely to operate the Naiia service:\n\n'
        '• Account and profile data lets us personalise your experience and remember your preferences.\n\n'
        '• Health conversations are stored so you can review your chat history and so the AI can maintain context across sessions.\n\n'
        '• Medication scan data is processed to identify drugs and retrieve safety information.\n\n'
        '• Forum content enables the community features of the app.\n\n'
        'We do not use your data for advertising, and we do not sell your data to any third party.',
  ),
  PolicySection(
    heading: '4. Who We Share It With',
    body:
        'We share data with the following service providers, only to the extent necessary to operate the app:\n\n'
        '• Firebase (Google LLC) — handles user authentication. Your email and profile are transmitted to Firebase to verify your identity.\n\n'
        '• Groq Inc. — processes your chat messages through large language models to generate AI responses. Your query text is sent to Groq\'s API.\n\n'
        '• Railway — hosts our backend server and database. Your data is stored on Railway\'s infrastructure.\n\n'
        '• GhanaNLP / Khaya AI — provides Twi language translation and text-to-speech. Text you request to be translated or spoken is sent to this service.\n\n'
        '• DuckDuckGo / Google Custom Search / Brave Search — used by our validation pipeline to retrieve medical evidence when verifying AI responses. Your health query (not your identity) may be used to form search queries.\n\n'
        'No other parties receive your personal data.',
  ),
  PolicySection(
    heading: '5. How Long We Keep Your Data',
    body:
        '• Chat messages — retained for 12 months from the date of conversation, then automatically deleted.\n\n'
        '• Medication scan images — retained for 90 days, then deleted from our servers.\n\n'
        '• Account and profile data — retained until you delete your account.\n\n'
        '• Forum posts and comments — retained until you delete them or your account.',
  ),
  PolicySection(
    heading: '6. Your Rights',
    body:
        'You have the right to:\n\n'
        '• Access your data — contact us at nyimbilimaxwell9@gmail.com.\n\n'
        '• Delete your account and all data — use Settings → Delete Account in the app. All your data is permanently and irreversibly deleted.\n\n'
        '• Correct inaccurate information — contact us at nyimbilimaxwell9@gmail.com.\n\n'
        '• Data portability — contact us to receive a copy of your data in JSON format.',
  ),
  PolicySection(
    heading: '7. Data Security',
    body:
        'We use industry-standard security measures including:\n\n'
        '• Firebase Authentication for secure sign-in (no passwords stored by us).\n\n'
        '• JWT tokens for session management with short expiry windows.\n\n'
        '• HTTPS-only communication between the app and our servers.\n\n'
        '• Database access restricted to our backend services only.\n\n'
        'No system is perfectly secure. In the event of a data breach we will notify affected users as required by applicable law.',
  ),
  PolicySection(
    heading: '8. Children\'s Privacy',
    body:
        'Naiia is not intended for users under 18 years of age. If you are a parent or guardian and believe your child has used this app, please contact us at nyimbilimaxwell9@gmail.com and we will delete their data promptly.',
  ),
  PolicySection(
    heading: '9. Changes to This Policy',
    body:
        'We will notify you within the app if we make material changes to this Privacy Policy. Continued use of the app after changes constitutes acceptance of the updated policy.',
  ),
  PolicySection(
    heading: '10. Contact',
    body:
        'For any privacy-related questions, requests, or complaints:\n\nEmail: nyimbilimaxwell9@gmail.com',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// TERMS OF SERVICE
// ─────────────────────────────────────────────────────────────────────────────

const String kTermsTitle = 'Terms of Service';
const String kTermsDate = 'Effective: 21 June 2026';

const List<PolicySection> kTermsSections = [
  PolicySection(
    heading: '1. Acceptance of Terms',
    body:
        'By creating an account and using Naiia, you agree to these Terms of Service. If you do not agree, please do not use the app.',
  ),
  PolicySection(
    heading: '2. What Naiia Is',
    body:
        'Naiia is an AI-powered maternal health information companion. It is designed to help you find and understand health information related to pregnancy, maternal care, and child health.\n\nNaiia is NOT a medical device, a licensed healthcare provider, or a substitute for professional medical advice.',
  ),
  PolicySection(
    heading: '3. Not Medical Advice',
    body:
        'IMPORTANT: The information provided by Naiia, including all AI-generated responses, is for informational and educational purposes only. It does not constitute medical advice, diagnosis, or treatment.\n\n'
        'Always seek the guidance of your doctor, midwife, or other qualified healthcare professional with any questions you have regarding a medical condition. Never disregard professional medical advice or delay seeking it because of something you read in Naiia.',
  ),
  PolicySection(
    heading: '4. Emergencies',
    body:
        'Naiia is not an emergency service. If you are experiencing a medical emergency, call your local emergency number (e.g. 911, 999, 112) immediately.\n\nDo not rely on Naiia in an emergency situation.',
  ),
  PolicySection(
    heading: '5. For Healthcare Professionals',
    body:
        'If you are a doctor, midwife, or clinician using Naiia: the app provides AI-generated information as a starting point for research only. You must apply your own clinical judgment to any information obtained through Naiia. The app does not replace clinical decision-making tools or protocols.',
  ),
  PolicySection(
    heading: '6. Accuracy of AI Responses',
    body:
        'Naiia uses artificial intelligence to generate responses. While we use a validation pipeline to check AI responses against authoritative medical sources, AI can make mistakes. Information may be outdated, incomplete, or incorrect.\n\nYou should independently verify important health information with a qualified professional.',
  ),
  PolicySection(
    heading: '7. User Responsibilities',
    body:
        'You agree to:\n\n'
        '• Provide accurate information during onboarding.\n\n'
        '• Use Naiia for lawful purposes only.\n\n'
        '• Not attempt to manipulate, hack, or abuse the AI system.\n\n'
        '• Not post harmful, abusive, or medically dangerous content in the community forum.\n\n'
        '• Not share another person\'s medical information without their consent.',
  ),
  PolicySection(
    heading: '8. Community Forum',
    body:
        'The Naiia community forum allows users to post and discuss health topics. You are responsible for the content you post. We reserve the right to remove content that is harmful, abusive, medically dangerous, or off-topic. Repeated violations may result in account suspension.',
  ),
  PolicySection(
    heading: '9. Disclaimer of Warranties',
    body:
        'Naiia is provided "as is" without warranties of any kind. We do not guarantee that the app will be available at all times, free of errors, or that AI responses will be accurate, complete, or up to date.',
  ),
  PolicySection(
    heading: '10. Limitation of Liability',
    body:
        'To the maximum extent permitted by applicable law, Naiia and its developers shall not be liable for any damages resulting from your use of or inability to use the app, including any reliance on information provided by the AI.',
  ),
  PolicySection(
    heading: '11. Changes to Terms',
    body:
        'We may update these Terms from time to time. We will notify you within the app of material changes. Continued use constitutes acceptance.',
  ),
  PolicySection(
    heading: '12. Governing Law',
    body:
        'These Terms are governed by the laws of Ghana. Any disputes shall be resolved in the courts of Ghana.',
  ),
  PolicySection(
    heading: '13. Contact',
    body: 'nyimbilimaxwell9@gmail.com',
  ),
];
