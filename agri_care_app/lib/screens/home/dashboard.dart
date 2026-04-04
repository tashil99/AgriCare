import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_theme.dart';
import '../../entities/results.dart';
import '../../services/api_service.dart';
import '../../widgets/detection_card.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loader.dart';
import '../../utils/error_handler.dart';
import '../detection/detection_detail.dart';
import '../detection/detection_result.dart';
import '../detection/scanning.dart';
import 'history.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final supabase = Supabase.instance.client;

  late Future<List<Results>> _detectionsFuture;

  @override
  void initState() {
    super.initState();
    _detectionsFuture = fetchDetections();
  }

  Future<List<Results>> fetchDetections() async {
    final response = await supabase
        .from('detections')
        .select()
        .order('created_at', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);
    return data.map((e) => Results.fromMap(e)).toList();
  }

  /// IMAGE PICKER
  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take photo"),
              onTap: () {
                Navigator.pop(context);
                _pickAndAnalyzeImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndAnalyzeImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ANALYZE IMAGE
  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanningScreen()),
    );

    try {
      final detections = await _apiService
          .analyzeImage(file)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageFile: file,
            detections: detections,
          ),
        ),
      );

      setState(() {
        _detectionsFuture = fetchDetections();
      });
    } on TimeoutException {
      Navigator.pop(context);
      ErrorDialog.show(context, "Detection timeout. Try again.");
    } catch (e) {
      Navigator.pop(context);
      ErrorDialog.show(context, ErrorHandler.getMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4E1), Color(0xFFDFF2C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              setState(() {
                _detectionsFuture = fetchDetections();
              });
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [

                /// TITLE
                Text("Your crops",
                    style: theme.textTheme.headlineMedium),

                const SizedBox(height: 22),

                _animated(_scanCard()),

                const SizedBox(height: 22),

                /// ================= STATS =================
                FutureBuilder<List<Results>>(
                  future: _detectionsFuture,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const PremiumLoader();
                    }

                    final data = snapshot.data ?? [];

                    final healthy = data.where((d) =>
                        d.diseaseName.toLowerCase().contains("healthy")).length;

                    final diseased = data.length - healthy;

                    return Row(
                      children: [
                        _stat("Healthy", healthy, AppTheme.healthy),
                        const SizedBox(width: 10),
                        _stat("Diseased", diseased, AppTheme.disease),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 25),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent detections",
                        style: theme.textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: const Text("See full history"),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ================= DETECTIONS =================
                FutureBuilder<List<Results>>(
                  future: _detectionsFuture,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const PremiumLoader();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _animated(
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No recent detections",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final latestOne = snapshot.data!.take(1).toList();

                    return Column(
                      children: latestOne.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _animated(
                          DetectionCard(
                            result: r,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetectionDetailScreen(result: r),
                                ),
                              );
                            },
                          ),
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ANIMATION
  Widget _animated(Widget child) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  /// SCAN CARD
  Widget _scanCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [

          SizedBox(
            height: 120,
            child: Lottie.asset(
              'assets/animations/plant_scan.json',
              repeat: true,
            ),
          ),

          const SizedBox(height: 16),

          Text("Scan your crop",
              style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _showImageSourcePicker,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text("Take a picture"),
              style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }

  /// STATS CARD
  Widget _stat(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}