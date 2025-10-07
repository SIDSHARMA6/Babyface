import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/baby_generation_entity.dart';

/// Baby generation remote datasource
/// Follows master plan clean architecture
abstract class BabyGenerationRemoteDatasource {
  Future<void> startGeneration(BabyGenerationEntity entity);
  Future<void> checkGenerationStatus(String id);
  Future<void> cancelGeneration(String id);
}

/// Baby generation remote datasource implementation
class BabyGenerationRemoteDatasourceImpl implements BabyGenerationRemoteDatasource {
  static const String _baseUrl = 'https://api.babyface.app/v1';
  final http.Client _httpClient;

  BabyGenerationRemoteDatasourceImpl(this._httpClient);

  @override
  Future<void> startGeneration(BabyGenerationEntity entity) async {
    try {
      // Upload images
      final maleImageUrl = await _uploadImage(entity.maleImagePath);
      final femaleImageUrl = await _uploadImage(entity.femaleImagePath);

      // Start generation
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getApiKey()}',
        },
        body: jsonEncode({
          'id': entity.id,
          'maleImageUrl': maleImageUrl,
          'femaleImageUrl': femaleImageUrl,
          'metadata': {
            'aiModel': entity.metadata.aiModel,
            'quality': entity.metadata.quality,
            'resolution': entity.metadata.resolution,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to start generation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Remote generation failed: $e');
    }
  }

  @override
  Future<void> checkGenerationStatus(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/generations/$id'),
        headers: {
          'Authorization': 'Bearer ${_getApiKey()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Process status update
        _processStatusUpdate(id, data);
      }
    } catch (e) {
      throw Exception('Failed to check generation status: $e');
    }
  }

  @override
  Future<void> cancelGeneration(String id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/generations/$id'),
        headers: {
          'Authorization': 'Bearer ${_getApiKey()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel generation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to cancel generation: $e');
    }
  }

  /// Upload image to remote server
  Future<String> _uploadImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file does not exist: $imagePath');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );

    request.headers['Authorization'] = 'Bearer ${_getApiKey()}';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['url'] as String;
    } else {
      throw Exception('Failed to upload image: $responseBody');
    }
  }

  /// Process status update from server
  void _processStatusUpdate(String id, Map<String, dynamic> data) {
    // This would typically update the local database
    // through a callback or event system
    final status = data['status'] as String;
    final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
    final generatedImageUrl = data['generatedImageUrl'] as String?;
    final errorMessage = data['errorMessage'] as String?;

    // Emit status update event
    _emitStatusUpdate(id, status, progress, generatedImageUrl, errorMessage);
  }

  /// Emit status update event
  void _emitStatusUpdate(
    String id,
    String status,
    double progress,
    String? generatedImageUrl,
    String? errorMessage,
  ) {
    // This would integrate with the app's event system
    // For now, we'll just log the update
    // Generation $id status update: $status, progress: $progress
  }

  /// Get API key from environment or config
  String _getApiKey() {
    // This would typically come from environment variables or secure storage
    return 'your-api-key-here';
  }
}
