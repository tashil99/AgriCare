import 'dart:convert';
import 'dart:io';
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

    final imageBytes = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    await supabase.from('detections').insert({
      'crop_name': cropName,
      'disease_name': diseaseName,
      'confidence': confidence,
      'recommendation': recommendation,
      'symptoms': symptoms,     // ✅ SAVE
      'cause': cause,           // ✅ SAVE
      'image_base64': imageBase64,
      'created_at': DateTime.now().toIso8601String(), 
    });
  }

  Future<List<Results>> fetchDetections() async {

    final response = await supabase
        .from('detections')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Results.fromMap(e))
        .toList();
  }
}