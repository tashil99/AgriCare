class Results {
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String recommendation;
  final String symptoms;
  final String cause;
  final String imageBase64;
  final DateTime createdAt;

  Results({
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.recommendation,
    required this.symptoms,
    required this.cause,
    required this.imageBase64,
    required this.createdAt,
  });

  factory Results.fromMap(Map<String, dynamic> map) {
    return Results(
      cropName: map['crop_name'] ?? "",
      diseaseName: map['disease_name'] ?? "",
      confidence: (map['confidence'] ?? 0).toDouble(),
      recommendation: map['recommendation'] ?? "",
      symptoms: map['symptoms'] ?? "",
      cause: map['cause'] ?? "",
      imageBase64: map['image_base64'] ?? "",
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}