import 'dart:io';
import 'package:dio/dio.dart';
import 'package:docexaaesthetic/models/GetUploadedImagesResponse.dart';
import 'package:docexaaesthetic/models/Loginresponse.dart';
import 'package:docexaaesthetic/models/UploadImageResponse.dart';
import 'package:docexaaesthetic/models/patientget.dart';
import 'package:path/path.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://aestheticai.globalspace.in/aesthetic_backend/public/api/v3';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
  }

  Future<patientget> getPatients({
    required int userId,
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get(
        '/establishments/users/$userId/patients/$page/$perPage',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.data}'); // For debugging

        // If response.data is already a Map
        if (response.data is Map<String, dynamic>) {
          return patientget.fromJson(response.data);
        }

        // If response.data is a List (direct patient list)
        if (response.data is List) {
          return patientget.fromJson({
            'status': 'success',
            'data': {
              'patient': response.data,
              'total_patient': response.data.length,
            },
          });
        }

        // If response format is unexpected
        throw Exception('Unexpected response format');
      } else {
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load patients',
        );
      }
    } catch (e) {
      // Log the error for debugging
      print('Error in getPatients: $e');

      // If it's a DioError, we can get more specific error information
      if (e is DioError) {
        print('DioError Response: ${e.response?.data}');
        print('DioError Status Code: ${e.response?.statusCode}');
      }

      throw Exception('Failed to fetch patients: $e');
    }
  }

  Future<GetUploadedImagesResponse> uploadImagesWithParams({
    required List<File> imageFiles,
    required String doctorId,
    required String patientId,
    required String patientNumber,
  }) async {
    FormData formData = FormData.fromMap({
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_number': patientNumber,
    });

    for (File image in imageFiles) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(
          image.path,
          filename: basename(image.path),
        ),
      ));
    }

    final response = await _dio.post(
      '/uploadImageFromDoc',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    print('Upload Response: ${response.data}'); // For debugging

    // Parse and return your model here
    return GetUploadedImagesResponse.fromJson(response.data);
  }

  Future<GetUploadedImagesResponse> uploadMarkedImagesWithParams({
    required List<File> imageFiles,
    required String doctorId,
    required String patientId,
    required String patientNumber,
    required String ismarked,
  }) async {
    FormData formData = FormData.fromMap({
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_number': patientNumber,
      'ismarked': ismarked,
    });

    for (File image in imageFiles) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(
          image.path,
          filename: basename(image.path),
        ),
      ));
    }

    final response = await _dio.post(
      '/uploadMarkedImageFromDoc',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    print('Upload Response: ${response.data}'); // For debugging

    // Parse and return your model here
    return GetUploadedImagesResponse.fromJson(response.data);
  }

  Future<GetUploadedImagesResponse> getUploadedImages(
      String patientNumber, String doctorid) async {
    try {
      print('print call: ${doctorid}');

      final response = await _dio.get(
        '/getUploadedImages/$doctorid/$patientNumber',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      // For debugging

      if (response.statusCode == 200) {
        return GetUploadedImagesResponse.fromJson(response.data);
      } else {
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load uploaded images',
        );
      }
    } catch (e) {
      print('Error in getUploadedImages: $e');
      throw Exception('Failed to fetch uploaded images: $e');
    }
  }

  Future<Loginresponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/public/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Upload Response: ${response.data}'); // For debugging
      // Parse the response data into your model
      return Loginresponse.fromJson(response.data);
    } catch (e) {
      print('Error in getUploadedImages: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  /// Add account creation here if available in the API
  /// This is just an example, adjust the model if your register API returns something different
  Future<Loginresponse> createAccount(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/auth/public/register',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      return Loginresponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<GetUploadedImagesResponse> deleteUploadedImage({
    required String doctorId,
    required String patientId,
    required String fileName,
    required String patientNumber,
  }) async {
    final currentDateTime = DateTime.now().toUtc().toString().split('.')[0];
    const userLogin = 'gajendra82';

    try {
      final response = await _dio.delete(
        '/api/deletePatientImage',
        data: {
          'doctor_id': doctorId,
          'patient_id': patientId,
          'file_name': fileName,
          'patient_number': patientNumber,
          'user_login': userLogin,
          'timestamp': currentDateTime,
        },
      );
      return GetUploadedImagesResponse.fromJson(response.data);
    } catch (e) {
      return GetUploadedImagesResponse(
        status: false,
        message: 'Failed to delete image: $e',
      );
    }
  }
}
