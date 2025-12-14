// Simple API config. Adjust base URL to your Laravel app.
// Note: Android emulator cannot reach host's 127.0.0.1; use 10.0.2.2.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

String get apiBaseUrl {
  // Override via env-like switch if needed later.
  const port = 8000;
  if (kIsWeb) {
    // Web runs in browser on the host; localhost works.
    return 'http://127.0.0.1:$port/api';
  }
  if (Platform.isAndroid) {
    // Android Studio emulator: 10.0.2.2 maps to host loopback.
    return 'http://10.0.2.2:$port/api';
  }
  // iOS simulator, desktop, others can use loopback.
  return 'http://127.0.0.1:$port/api';
}

// If you use JWT or Sanctum, store token securely (e.g., flutter_secure_storage).
String? apiToken;

void setApiToken(String? token) {
  apiToken = token;
}

String? getApiToken() => apiToken;
