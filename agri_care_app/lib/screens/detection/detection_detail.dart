import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../../theme/app_theme.dart';
import '../../entities/results.dart';

class DetectionDetailScreen extends StatelessWidget {
  final Results result;

  const DetectionDetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageBytes = base64Decode(result.imageBase64);
    final accuracy = result.confidence;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text("Diagnosis")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [

            Text(result.diseaseName,
                style: theme.textTheme.headlineMedium),

            const SizedBox(height: 10),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.memory(imageBytes,
                  height: 260, fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            /// INFO
            Text(
              "Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%",
            ),

            const SizedBox(height: 20),

            /// SYMPTOMS
            Text("Symptoms",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.symptoms),

            const SizedBox(height: 20),

            /// CAUSE
            Text("Cause",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.cause),

            const SizedBox(height: 20),

            /// TREATMENT
            Text("Treatment",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.recommendation),

            const SizedBox(height: 30),

            /// SHARE + EXPORT
            Row(
              children: [

                /// ✅ SHARE PDF
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: () async {
                      final file = await _generatePdf(imageBytes);
                      await Share.shareXFiles([XFile(file.path)]);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                /// ✅ EXPORT PDF
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () =>
                        _exportPdf(context, imageBytes),
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
  Future<File> _generatePdf(Uint8List imageBytes) async {
    final pdf = pw.Document();

    final logoBytes =
        (await rootBundle.load('assets/logo.png'))
            .buffer
            .asUint8List();

    final isHealthy =
        result.diseaseName.toLowerCase().contains("healthy");

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

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

            pw.Text("Disease: ${result.diseaseName}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.Text(
                "Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%"),

            pw.Text(
              isHealthy ? "Healthy" : "Diseased",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text("Symptoms",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(result.symptoms),

            pw.SizedBox(height: 20),

            pw.Text("Cause",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(result.cause),

            pw.SizedBox(height: 20),

            pw.Text("Treatment",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(result.recommendation),
          ],
        ),
      ),
    );

    final dir = await _getDownloadDirectory();

    final cleanDisease = result.diseaseName
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
  Future<void> _exportPdf(
      BuildContext context, Uint8List imageBytes) async {

    final file = await _generatePdf(imageBytes);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("PDF Saved"),
        content: Text("Saved to:\n${file.path}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await OpenFilex.open(file.path);
            },
            child: const Text("Open"),
          ),
        ],
      ),
    );
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
  Future<File> _createUniqueFile(
      String dirPath, String baseName) async {
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