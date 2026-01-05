// Base URL default langsung ke domain Railway kamu.
// Bisa di-override saat run/build pakai --dart-define=API_BASE_URL=...
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://web-production-291d3.up.railway.app/api',
);

// Simpan token (pindahkan ke secure storage untuk produksi).
String? _apiToken;

void setApiToken(String? token) {
  _apiToken = token;
}

String? getApiToken() => _apiToken;
