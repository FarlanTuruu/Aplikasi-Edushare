import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  // Base URL mengikuti platform (Android emulator: 10.0.2.2, dll)
  final String _baseUrl = apiBaseUrl;

  String? _token;

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Set token untuk request (biasanya JWT atau Sanctum token)
  void setToken(String? token) {
    _token = token;
    // sinkronkan ke config global jika digunakan di tempat lain
    setApiToken(token);
  }

  /// Get current token
  String? getToken() => _token ?? getApiToken();

  /// GET request - returns Map
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET error: $e');
    }
  }

  /// GET request - returns Map (alias untuk get)
  Future<Map<String, dynamic>> getJson(String endpoint) async {
    return get(endpoint);
  }

  /// GET request - returns List
  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);

        // Handle both list dan map response
        if (jsonResponse is List) {
          return jsonResponse;
        } else if (jsonResponse is Map<String, dynamic>) {
          // Jika API return data dalam nested field (e.g., {"data": [...]})
          if (jsonResponse.containsKey('data') &&
              jsonResponse['data'] is List) {
            return jsonResponse['data'] as List<dynamic>;
          }
          return [jsonResponse];
        }
        return [];
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('GET list error: $e');
    }
  }

  /// POST request dengan JSON body
  Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST error: $e');
    }
  }

  /// PUT request dengan JSON body
  Future<Map<String, dynamic>> putJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT error: $e');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();

      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE error: $e');
    }
  }

  /// POST request dengan file upload (multipart)
  Future<Map<String, dynamic>> postWithFile(
    String endpoint,
    String fileFieldName,
    String filePath,
    Map<String, String>? fields,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = _getHeaders();
      headers.remove('Content-Type'); // Multipart akan set ini otomatis

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return _handleStringResponse(response.statusCode, responseBody);
    } catch (e) {
      throw Exception('POST with file error: $e');
    }
  }

  /// Get headers dengan token jika ada
  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = _token ?? getApiToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Handle response dan parse JSON
  Map<String, dynamic> _handleResponse(http.Response response) {
    return _handleStringResponse(response.statusCode, response.body);
  }

  /// Handle string response
  Map<String, dynamic> _handleStringResponse(int statusCode, String body) {
    // Be flexible: server may return plain text on errors (e.g., "Invalid or expired reset token")
    try {
      final dynamic decoded = jsonDecode(body);

      // If decoded is a Map, proceed
      if (decoded is Map<String, dynamic>) {
        if (statusCode >= 200 && statusCode < 300) {
          return decoded;
        } else {
          // Prefer server-provided message
          final message =
              decoded['message']?.toString() ?? 'Error: $statusCode';
          throw Exception(message);
        }
      }

      // If decoded is a List or other JSON type, wrap appropriately for success
      if (statusCode >= 200 && statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return {'data': decoded};
      } else {
        // Non-2xx: use body content as message
        throw Exception('Error: $statusCode - ${body.toString()}');
      }
    } catch (_) {
      // Not JSON: treat as plain text
      if (statusCode >= 200 && statusCode < 300) {
        // Return a generic structure so callers can read a message
        return {'message': body};
      }
      // For errors, surface the raw text message if available
      final msg = body.trim().isNotEmpty
          ? body.trim()
          : 'HTTP $statusCode error';
      throw Exception(msg);
    }
  }

  /// Set base URL (jika perlu dynamic)
  void setBaseUrl(String newBaseUrl) {
    // Kalau mau buat dynamic, uncomment method ini dan update _baseUrl
    // _baseUrl = newBaseUrl;
  }
}
