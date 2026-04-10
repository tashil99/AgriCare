import 'dart:io';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../entities/detections.dart';
import '../../services/detection_service.dart';
import 'treatment.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final List<Detections> detections;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detectionService = DetectionService();

    if (detections.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No disease detected")),
      );
    }

    final result = detections.first;

    final isHealthy =
        result.className.toLowerCase().contains("healthy");

    final statusColor =
        isHealthy ? AppTheme.healthy : AppTheme.disease;

    final statusText = isHealthy ? "Healthy" : "Diseased";

    final accuracy = result.confidence.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [

            /// HEADER
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 6),
                Text("Diagnosis", style: theme.textTheme.titleLarge),
              ],
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              result.className,
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 10),

            /// STATUS BADGE
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.file(
                imageFile,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            /// ANALYSIS CARD
            _sectionCard(
              title: "Analysis",
              icon: Icons.analytics_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Detection accuracy"),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: accuracy,
                    minHeight: 10,
                    backgroundColor: AppTheme.divider,
                    valueColor:
                        AlwaysStoppedAnimation(statusColor),
                  ),

                  const SizedBox(height: 16),

                  /// SYMPTOMS
                  Text("Symptoms",
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(result.symptoms),

                  const SizedBox(height: 12),

                  /// CAUSE
                  Text("Cause",
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(result.cause),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(
                  isHealthy ? Icons.save : Icons.arrow_forward,
                ),
                label: Text(
                  isHealthy
                      ? "Save detection"
                      : "Save & See treatment",
                ),
                onPressed: () async {

                  await detectionService.saveDetection(
                    cropName: "Tomato",
                    diseaseName: result.className.trim(),
                    confidence: result.confidence,

            
                    recommendation: result.recommendation.trim().isNotEmpty == true
                        ? result.recommendation.trim()
                        : "No treatment available.",

                    symptoms: result.symptoms.trim().isNotEmpty == true
                        ? result.symptoms.trim()
                        : "No symptoms available.",

                    cause: result.cause.trim().isNotEmpty == true
                        ? result.cause.trim()
                        : "No cause information available.",

                    imagePath: imageFile.path,
                  );

                  if (isHealthy) {

                    /// SUCCESS DIALOG
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Saved"),
                        content: const Text(
                            "Detection saved successfully"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );

                  } else {

                    /// GO TO TREATMENT
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TreatmentScreen(
                          imageFile: imageFile,
                          detection: result,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD WIDGET
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}