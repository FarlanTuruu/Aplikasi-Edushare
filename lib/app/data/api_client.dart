import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  final String _baseUrl = apiBaseUrl;
  String? _token;

  final Map<String, String> _defaultHeaders = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setToken(String? token) {
    _token = token;
    setApiToken(token);
  }

  String? getToken() => _token ?? getApiToken();

  // Gabungkan base URL dan endpoint tanpa double slash
  Uri _u(String endpoint) {
    final a = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final b = endpoint.replaceAll(RegExp(r'^/+'), '');
    return Uri.parse('$a/$b');
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(_u(endpoint), headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET error: $e');
    }
  }

  Future<Map<String, dynamic>> getJson(String endpoint) => get(endpoint);

  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final response = await http.get(_u(endpoint), headers: _getHeaders());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) return jsonResponse;
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['data'] is List) return jsonResponse['data'] as List;
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

  Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        _u(endpoint),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST error: $e');
    }
  }

  Future<Map<String, dynamic>> putJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        _u(endpoint),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(_u(endpoint), headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE error: $e');
    }
  }

  Future<Map<String, dynamic>> postWithFile(
    String endpoint,
    String fileFieldName,
    String filePath,
    Map<String, String>? fields,
  ) async {
    try {
      final headers = _getHeaders();
      headers.remove('Content-Type'); // otomatis oleh Multipart
      final request = http.MultipartRequest('POST', _u(endpoint))
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
      if (fields != null) request.fields.addAll(fields);

      final response = await request.send();
      final body = await response.stream.bytesToString();
      return _handleStringResponse(response.statusCode, body);
    } catch (e) {
      throw Exception('POST with file error: $e');
    }
  }

  Future<Map<String, dynamic>> putWithFile(
    String endpoint,
    String fileFieldName,
    String filePath,
    Map<String, String>? fields,
  ) async {
    try {
      final headers = _getHeaders();
      headers.remove('Content-Type');
      final request = http.MultipartRequest('PUT', _u(endpoint))
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
      if (fields != null) request.fields.addAll(fields);

      final response = await request.send();
      final body = await response.stream.bytesToString();
      return _handleStringResponse(response.statusCode, body);
    } catch (e) {
      throw Exception('PUT with file error: $e');
    }
  }

  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = _token ?? getApiToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    return _handleStringResponse(response.statusCode, response.body);
  }

  Map<String, dynamic> _handleStringResponse(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (statusCode >= 200 && statusCode < 300) return decoded;
        final message = decoded['message']?.toString() ?? 'Error: $statusCode';
        throw Exception(message);
      }
      if (statusCode >= 200 && statusCode < 300) {
        return decoded is List ? {'data': decoded} : {'data': decoded};
      } else {
        throw Exception('Error: $statusCode - $body');
      }
    } catch (_) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'message': body};
      }
      final msg = body.trim().isNotEmpty
          ? body.trim()
          : 'HTTP $statusCode error';
      throw Exception(msg);
    }
  }
}
