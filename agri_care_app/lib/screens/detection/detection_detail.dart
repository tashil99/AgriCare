import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../entities/results.dart';
import '../../services/report_service.dart';

class DetectionDetailScreen extends StatelessWidget {
  final Results result;

  const DetectionDetailScreen({
    super.key,
    required this.result,
  });

  Uint8List _safeDecode(String base64Str) {
    try {
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      base64Str = base64Str.replaceAll('\n', '').trim();
      return base64Decode(base64Str);
    } catch (_) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportService = ReportService();

    final imageBytes = _safeDecode(result.imageBase64);
    final accuracy = result.confidence;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text("Diagnosis")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [

            /// TITLE
            Text(
              result.diseaseName,
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 10),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: imageBytes.isNotEmpty
                  ? Image.memory(
                      imageBytes,
                      height: 260,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 260,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text("No image available"),
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            /// ACCURACY
            Text(
              "Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%",
            ),

            const SizedBox(height: 20),

            /// SYMPTOMS
            Text("Symptoms", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.symptoms),

            const SizedBox(height: 20),

            /// CAUSE
            Text("Cause", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.cause),

            const SizedBox(height: 20),

            /// TREATMENT
            Text("Treatment", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.recommendation),

            const SizedBox(height: 30),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: () async {
                      await reportService.shareReport(result);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () async {
                      await reportService.exportReport(result);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}