// lib/services/upload_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://backend-ecommerce-udhh.onrender.com',
  ));

  Future<String> uploadImage(XFile imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/api/upload',
        data: formData,
      );

      return response.data['imageUrl']; // URL gambar dari backend
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }
}
