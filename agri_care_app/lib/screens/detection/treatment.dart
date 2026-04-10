import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../entities/detections.dart';
import '../../entities/results.dart';
import '../../services/detection_service.dart';
import '../../services/report_service.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/success_dialog.dart';

class TreatmentScreen extends StatefulWidget {
  final File imageFile;
  final Detections detection;

  const TreatmentScreen({
    super.key,
    required this.imageFile,
    required this.detection,
  });

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final DetectionService _service = DetectionService();
  final ReportService _reportService = ReportService();

  bool _isSaved = false;

  Results _toResult() {
    final imageBytes = widget.imageFile.readAsBytesSync();
    final base64Image = base64Encode(imageBytes);

    return Results(
      cropName: "Tomato",
      diseaseName: widget.detection.className,
      confidence: widget.detection.confidence,
      recommendation: widget.detection.recommendation,
      symptoms: widget.detection.symptoms,
      cause: widget.detection.cause,
      imageBase64: base64Image,
      createdAt: DateTime.now(),
    );
  }

  /// 🔥 SAVE FUNCTION (REUSABLE)
  Future<void> _saveDetectionIfNeeded() async {
    if (_isSaved) return;

    await _service.saveDetection(
      cropName: "Tomato",
      diseaseName: widget.detection.className,
      confidence: widget.detection.confidence,
      recommendation: widget.detection.recommendation,
      symptoms: widget.detection.symptoms,
      cause: widget.detection.cause,
      imagePath: widget.imageFile.path,
    );

    setState(() {
      _isSaved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text("Treatment")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(widget.imageFile, height: 260, fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            /// DISEASE NAME
            Text(
              widget.detection.className,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 16),

            /// TREATMENT CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.detection.recommendation,
                style: const TextStyle(height: 1.6),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ SAVE BUTTON (ONLY IF NOT SAVED)
            if (!_isSaved)
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save detection"),
                  onPressed: () async {
                    try {
                      await _saveDetectionIfNeeded();

                      SuccessDialog.show(
                        context,
                        "Detection saved successfully",
                        onContinue: () {
                          Navigator.popUntil(
                              context, (route) => route.isFirst);
                        },
                      );

                    } catch (e) {
                      ErrorDialog.show(
                        context,
                        "Failed to save detection. Please try again.",
                      );
                    }
                  },
                ),
              ),

            const SizedBox(height: 12),

            /// SHARE + EXPORT
            Row(
              children: [

                /// SHARE
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: () async {
                      try {
                        await _saveDetectionIfNeeded(); // 🔥 AUTO SAVE
                        await _reportService.shareReport(_toResult());
                      } catch (e) {
                        ErrorDialog.show(context, "Failed to share report");
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                /// EXPORT
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () async {
                      try {
                        await _saveDetectionIfNeeded(); // 🔥 AUTO SAVE
                        await _reportService.exportReport(_toResult());
                      } catch (e) {
                        ErrorDialog.show(context, "Failed to export PDF");
                      }
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