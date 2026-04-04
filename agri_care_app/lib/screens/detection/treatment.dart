import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../theme/app_theme.dart';
import '../../entities/detections.dart';
import '../../services/detection_service.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/success_dialog.dart';

class TreatmentScreen extends StatelessWidget {
  final File imageFile;
  final Detections detection;

  const TreatmentScreen({
    super.key,
    required this.imageFile,
    required this.detection,
  });

  @override
  Widget build(BuildContext context) {
    final service = DetectionService();

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
              child: Image.file(imageFile, height: 260, fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            /// DISEASE NAME
            Text(
              detection.className,
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
                detection.recommendation,
                style: const TextStyle(height: 1.6),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save detection"),
                onPressed: () async {
                  try {
                    await service.saveDetection(
                      cropName: "Tomato",
                      diseaseName: detection.className,
                      confidence: detection.confidence,
                      recommendation: detection.recommendation,
                      symptoms: detection.symptoms,
                      cause: detection.cause,
                      imagePath: imageFile.path,
                    );

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
                      onRetry: () {
                        Navigator.pop(context);
                      },
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
                        final file = await _generatePdf();
                        await Share.shareXFiles([XFile(file.path)]);
                      } catch (e) {
                        ErrorDialog.show(
                          context,
                          "Failed to share report",
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                /// EXPORT PDF
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () => _exportPdf(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= PDF GENERATOR =================
  Future<File> _generatePdf() async {
    final pdf = pw.Document();

    final imageBytes = await imageFile.readAsBytes();
    final logoBytes =
        (await rootBundle.load('assets/logo_1.png')).buffer.asUint8List();

    final now = DateTime.now();

    final isHealthy =
        detection.className.toLowerCase().contains("healthy");

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            /// HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(pw.MemoryImage(logoBytes), height: 40),
                pw.Text("AgriCare Report",
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),

            pw.SizedBox(height: 20),

            pw.Image(pw.MemoryImage(imageBytes), height: 200),

            pw.SizedBox(height: 20),

            pw.Text("Disease: ${detection.className}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.Text(
                "Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%"),

            pw.Text("Date: ${now.day}/${now.month}/${now.year}"),

            pw.SizedBox(height: 10),

            pw.Text(
              isHealthy ? "Healthy" : "Diseased",
              style: pw.TextStyle(
                color: isHealthy ? PdfColors.green : PdfColors.red,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            /// SYMPTOMS
            pw.Text("Symptoms",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(detection.symptoms),

            pw.SizedBox(height: 20),

            /// CAUSE
            pw.Text("Cause",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(detection.cause),

            pw.SizedBox(height: 20),

            /// TREATMENT
            pw.Text("Treatment",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(detection.recommendation),
          ],
        ),
      ),
    );

    final dir = await _getDownloadDirectory();

    final cleanDisease = detection.className
        .replaceAll(" ", "_")
        .replaceAll(RegExp(r'[^\w\s]+'), '');

    final file = await _createUniqueFile(
      dir.path,
      "AgriCare_Report_$cleanDisease",
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// ================= EXPORT =================
  Future<void> _exportPdf(BuildContext context) async {
    try {
      final file = await _generatePdf();

      SuccessDialog.show(
        context,
        "PDF saved successfully",
        onContinue: () async {
          await OpenFilex.open(file.path);
        },
      );
    } catch (e) {
      ErrorDialog.show(
        context,
        "Failed to export PDF",
      );
    }
  }

  /// ================= DOWNLOAD DIRECTORY =================
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
    }
    return await getApplicationDocumentsDirectory();
  }

  /// ================= UNIQUE FILE =================
  Future<File> _createUniqueFile(String dirPath, String baseName) async {
    int counter = 0;
    String path;

    do {
      final suffix = counter == 0 ? "" : "($counter)";
      path = "$dirPath/$baseName$suffix.pdf";
      counter++;
    } while (await File(path).exists());

    return File(path);
  }
}