import 'dart:convert';
import 'dart:io';
import 'package:AgriCare/services/app_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/results.dart';

class DetectionService {

  final supabase = Supabase.instance.client;

  Future<void> saveDetection({
    required String cropName,
    required String diseaseName,
    required double confidence,
    required String recommendation,
    required String symptoms,
    required String cause,
    required String imagePath,
  }) async {
    try {
      final user = authService.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final imageBytes = await File(imagePath).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      await supabase.from('detections').insert({
        'user_id': user.id,
        'crop_name': cropName,
        'disease_name': diseaseName,
        'confidence': confidence,
        'recommendation': recommendation,
        'symptoms': symptoms,
        'cause': cause,
        'image_base64': imageBase64,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("SAVED SUCCESSFULLY");

    } catch (e) {
      print("SAVE ERROR: $e");
      throw e;
    }
  }

Future<List<Results>> fetchDetections() async {

  final user = authService.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final response = await supabase
      .from('detections')
      .select()
      .eq('user_id', user.id) 
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => Results.fromMap(e))
      .toList();
}
}