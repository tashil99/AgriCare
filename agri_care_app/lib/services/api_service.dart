import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../entities/detections.dart';

class ApiService {
  static const String baseUrl = "http://192.168.100.165:8000";

  Future<List<Detections>> analyzeImage(File imageFile) async {
    try {
      final uri = Uri.parse("$baseUrl/predict");

      final request = http.MultipartRequest("POST", uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 15));

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 429) {
        throw Exception("TokenLimit");
      }

      if (response.statusCode == 400) {
        throw Exception("InvalidFileType");
      }

      if (response.statusCode == 413) {
        throw Exception("FileTooLarge");
      }

      if (response.statusCode >= 500) {
        throw Exception("500");
      }

      if (response.statusCode != 200) {
        throw Exception("UnknownError");
      }

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final List detectionsJson = jsonData["detections"] ?? [];

      return detectionsJson
          .map((d) => Detections.fromJson(d))
          .toList();

    } on TimeoutException {
      throw Exception("TimeoutException");

    } on SocketException {
      throw Exception("SocketException");

    } catch (e) {
      // fallback
      throw Exception(e.toString());
    }
  }
}