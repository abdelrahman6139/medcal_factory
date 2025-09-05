// lib/constants/env.dart
class Env {
  /// On Android emulator, 10.0.2.2 points to your machine's localhost:5000
  static const String apiBase =
      String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:5000');

  /// MUST equal the Web OAuth Client ID you created in Google Cloud
  /// and used in backend .env as GOOGLE_CLIENT_ID.
  static const String googleWebClientId = String.fromEnvironment(
    '276810087339-0nnqjp1833s4andi8qtmqeefs1j65mh1.apps.googleusercontent.com',
    defaultValue: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );
}
