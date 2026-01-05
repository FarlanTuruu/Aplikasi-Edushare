// File: /lib/app/services/download_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/config.dart';

class DownloadService extends GetxService {
  late final Dio _dio;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final currentFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // Setup interceptor untuk token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = getApiToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Request storage permission untuk Android
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Untuk Android 13+ (API 33+)
    if (await Permission.photos.isGranted ||
        await Permission.videos.isGranted ||
        await Permission.audio.isGranted) {
      return true;
    }

    // Untuk Android 11-12 (API 30-32)
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Request permission
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        // Android 13+
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        return statuses.values.any((status) => status.isGranted);
      } else if (androidInfo >= 30) {
        // Android 11-12
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      } else {
        // Android 10 dan dibawah
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }

    return false;
  }

  /// Get Android version (SDK level)
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Simplified version check - adjust based on your needs
      return 33; // Default to latest for safety
    } catch (e) {
      debugPrint('Error getting Android version: $e');
      return 30;
    }
  }

  /// Get download directory berdasarkan platform
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Untuk Android, gunakan folder Download publik
      final downloadPath = Directory('/storage/emulated/0/Download');

      // Fallback jika folder tidak ada
      if (!await downloadPath.exists()) {
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          return Directory('${appDir.path}/Download');
        }
      }

      return downloadPath;
    } else if (Platform.isIOS) {
      // Untuk iOS, gunakan Documents directory
      return await getApplicationDocumentsDirectory();
    } else {
      // Untuk platform lain
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }
  }

  /// Download file dari URL storage
  Future<String?> downloadFile(
    String fileName, {
    String? customPath,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Reset progress
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      currentFileName.value = fileName;

      // Request permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final directory = customPath != null
          ? Directory(customPath)
          : await _getDownloadDirectory();

      // Create directory jika belum ada
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Build file path
      final filePath = '${directory.path}/$fileName';

      // Build download URL
      final downloadUrl = _buildFileUrl(fileName);

      debugPrint('📥 Downloading from: $downloadUrl');
      debugPrint('💾 Saving to: $filePath');

      // Download file dengan progress tracking
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress.value = progress;

            if (onProgress != null) {
              onProgress(received, total);
            }

            debugPrint(
              '📊 Download progress: ${(progress * 100).toStringAsFixed(1)}%',
            );
          }
        },
      );

      debugPrint('✅ Download complete: $filePath');
      return filePath;
    } on DioException catch (e) {
      debugPrint('❌ Dio error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('File tidak ditemukan di server');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - silakan login kembali');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - periksa koneksi internet');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Download timeout - file terlalu besar atau koneksi lambat',
        );
      }

      throw Exception('Download error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Download error: $e');
      rethrow;
    } finally {
      isDownloading.value = false;
      currentFileName.value = '';
    }
  }

  /// Download file by note ID (jika server punya endpoint khusus)
  Future<String?> downloadNoteFile(
    String noteId,
    String fileName, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      currentFileName.value = fileName;

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getDownloadDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/$fileName';

      // Endpoint khusus untuk download by ID
      final downloadUrl = '/notes/$noteId/download';

      debugPrint('📥 Downloading note file from: $downloadUrl');
      debugPrint('💾 Saving to: $filePath');

      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
            if (onProgress != null) {
              onProgress(received, total);
            }
          }
        },
      );

      debugPrint('✅ Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Download note file error: $e');
      rethrow;
    } finally {
      isDownloading.value = false;
      currentFileName.value = '';
    }
  }

  /// Download dari URL langsung (untuk file eksternal)
  Future<String?> downloadFromUrl(
    String url,
    String fileName, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      currentFileName.value = fileName;

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getDownloadDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/$fileName';

      debugPrint('📥 Downloading from external URL: $url');
      debugPrint('💾 Saving to: $filePath');

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
            if (onProgress != null) {
              onProgress(received, total);
            }
          }
        },
      );

      debugPrint('✅ Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Download from URL error: $e');
      rethrow;
    } finally {
      isDownloading.value = false;
      currentFileName.value = '';
    }
  }

  /// Cancel download yang sedang berjalan
  void cancelDownload() {
    _dio.close(force: true);
    isDownloading.value = false;
    downloadProgress.value = 0.0;
    currentFileName.value = '';

    // Reinitialize dio
    _dio.options = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    );
  }

  /// Build file URL dari nama file
  String _buildFileUrl(String fileName) {
    final base = apiBaseUrl;

    // Jika apiBaseUrl berakhir dengan /api, hapus untuk akses storage
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;

    return '$host/storage/$fileName';
  }

  /// Check apakah file sudah ada di local
  Future<bool> isFileDownloaded(String fileName) async {
    try {
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file path jika sudah downloaded
  Future<String?> getDownloadedFilePath(String fileName) async {
    try {
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete downloaded file
  Future<bool> deleteDownloadedFile(String fileName) async {
    try {
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete file error: $e');
      return false;
    }
  }

  /// Get ukuran file yang sudah didownload
  Future<int?> getFileSize(String fileName) async {
    try {
      final filePath = await getDownloadedFilePath(fileName);
      if (filePath == null) return null;

      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return null;
    }
  }

  /// Format file size untuk display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
