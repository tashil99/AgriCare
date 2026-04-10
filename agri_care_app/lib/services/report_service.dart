import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../entities/results.dart';

class ReportService {

  static const bg = PdfColor.fromInt(0xFFF7F9F7);
  static const card = PdfColors.white;
  static const primary = PdfColor.fromInt(0xFF2E7D32);
  static const soft = PdfColor.fromInt(0xFFE8F5E9);

  Uint8List _safeDecode(String base64Str) {
    try {
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      return base64Decode(base64Str);
    } catch (_) {
      return Uint8List(0);
    }
  }

  Future<Uint8List?> _logo() async {
    try {
      final data = await rootBundle.load('assets/logo_1.png');
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// CLEAN TEXT
  String _clean(String? text, String fallback) {
    if (text == null) return fallback;

    String cleaned = text;

    cleaned = cleaned.replaceAll(RegExp(r'\*\*'), '');
    cleaned = cleaned.replaceAll('*', '');
    cleaned = cleaned.replaceAll(RegExp(r'Here are.*?:'), '');
    cleaned = cleaned.replaceAll('\r', '');
    cleaned = cleaned.trim();

    if (cleaned.isEmpty) return fallback;

    return cleaned;
  }

  /// BULLET HANDLER
  pw.Widget _bullet(String text, pw.Font font) {

    List<String> lines = [];

    if (text.contains('●') || text.contains('•')) {
      lines = text
          .split(RegExp(r'[●•]'))
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList();
    } else {
      lines = text
          .split(RegExp(r'\.\s+'))
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList();
    }

    if (lines.isEmpty) {
      lines = [text];
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("• ", style: pw.TextStyle(font: font)),
              pw.Expanded(child: pw.Text(line)),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// SECTION
  pw.Widget _section({
    required String title,
    required String content,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: card,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              /// GREEN BOX
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: primary,
                ),
              ),

              pw.SizedBox(width: 6),

              /// TITLE
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 14,
                  color: primary,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          _bullet(content, regular),
        ],
      ),
    );
  }

  /// PROGRESS BAR
pw.Widget _progressBar(double value, bool isHealthy) {
  return pw.Container(
    height: 6,
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300,
    ),
    child: pw.LayoutBuilder(
      builder: (context, constraints) {
        return pw.Container(
          width: constraints!.maxWidth * value,
          color: isHealthy ? PdfColors.green : PdfColors.red,
        );
      },
    ),
  );
}

  Future<File> generateReport(Results result) async {
    final pdf = pw.Document();

    final image = result.imageBase64.isNotEmpty
        ? _safeDecode(result.imageBase64)
        : Uint8List(0);

    final logo = await _logo();

    final font = pw.Font.ttf(
        await rootBundle.load("assets/fonts/Poppins-Regular.ttf"));
    final bold = pw.Font.ttf(
        await rootBundle.load("assets/fonts/Poppins-Bold.ttf"));

    final isHealthy =
        result.diseaseName.toLowerCase().contains("healthy");

    final symptoms = _clean(result.symptoms, "No symptoms available.");
    final cause = _clean(result.cause, "No cause information available.");
    final treatment = _clean(
        result.recommendation,
        "No treatment available. Please consult an expert.");

    final confidence = result.confidence.clamp(0.0, 1.0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: font, bold: bold),

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              "Generated by AgriCare - Your AI Crop Doctor",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          );
        },

        build: (_) => [

          /// HEADER
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  if (logo != null)
                    pw.Image(pw.MemoryImage(logo), height: 35),
                  pw.SizedBox(width: 8),
                  pw.Text("AgriCare",
                      style: pw.TextStyle(font: bold, fontSize: 16)),
                ],
              ),
              pw.Text(
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          pw.Text(
            "Crop Disease Diagnosis Report",
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),

          pw.SizedBox(height: 15),

          /// IMAGE + SUMMARY
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Expanded(
                child: pw.Container(
                  height: 160,
                  child: image.isNotEmpty
                      ? pw.ClipRRect(
                          horizontalRadius: 12,
                          verticalRadius: 12,
                          child: pw.Image(
                            pw.MemoryImage(image),
                            fit: pw.BoxFit.cover,
                          ),
                        )
                      : pw.Center(child: pw.Text("No Image")),
                ),
              ),

              pw.SizedBox(width: 15),

              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: soft,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [

                      pw.Text("Diagnosis Summary",
                          style: pw.TextStyle(font: bold)),

                      pw.SizedBox(height: 8),

                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: isHealthy
                              ? PdfColors.green200
                              : PdfColors.red200,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          isHealthy ? "Healthy" : "Diseased",
                          style: pw.TextStyle(
                              font: bold, fontSize: 10),
                        ),
                      ),

                      pw.SizedBox(height: 8),

                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: "Disease: ",
                              style: pw.TextStyle(font: bold),
                            ),
                            pw.TextSpan(text: result.diseaseName),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text("Detection Accuracy"),
                      pw.SizedBox(height: 4),

                      _progressBar(confidence, isHealthy),

                      pw.SizedBox(height: 4),

                      pw.Text(
                        "${(confidence * 100).toStringAsFixed(1)}%",
                        style: pw.TextStyle(font: bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          _section(
            title: "Symptoms",
            content: symptoms,
            bold: bold,
            regular: font,
          ),

          pw.SizedBox(height: 10),

          _section(
            title: "Cause",
            content: cause,
            bold: bold,
            regular: font,
          ),

          pw.SizedBox(height: 10),

          _section(
            title: "Treatment",
            content: treatment,
            bold: bold,
            regular: font,
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/AgriCare_Report.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> exportReport(Results result) async {
    final file = await generateReport(result);
    await OpenFilex.open(file.path);
  }

  Future<void> shareReport(Results result) async {
    final file = await generateReport(result);
    await Share.shareXFiles([XFile(file.path)]);
  }
}