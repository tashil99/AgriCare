class Detections {
  final String className;
  final double confidence;
  final String symptoms;
  final String cause;
  final String recommendation;

  Detections({
    required this.className,
    required this.confidence,
    required this.symptoms,
    required this.cause,
    required this.recommendation,
  });

  factory Detections.fromJson(Map<String, dynamic> json) {
    return Detections(
      className: json['class'],
      confidence: json['confidence'],
      symptoms: json['symptoms'],
      cause: json['cause'],
      recommendation: json['recommendation'],
    );
  }
}