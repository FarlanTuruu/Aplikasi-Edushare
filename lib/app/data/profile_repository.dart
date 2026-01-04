import 'api_client.dart';

class ProfileRepository {
  final ApiClient api;
  ProfileRepository(this.api);

  Future<Map<String, dynamic>> me() async {
    return await api.getJson('profile');
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    return await api.putJson('profile', payload);
  }

  /// Update profile with multipart (including image file upload).
  ///
  /// Uses endpoint 'profile' and file field name 'image' by default,
  /// matching typical Laravel controllers that accept form-data.
  /// Adjust if your backend uses a different route or field name.
  Future<Map<String, dynamic>> updateProfileWithImage({
    required String filePath,
    Map<String, String>? fields,
    String endpoint = 'profile/update',
    String fileFieldName = 'image',
    bool usePut = false,
  }) async {
    if (usePut) {
      return await api.putWithFile(endpoint, fileFieldName, filePath, fields);
    }
    return await api.postWithFile(endpoint, fileFieldName, filePath, fields);
  }
}
