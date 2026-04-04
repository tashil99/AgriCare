import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../entities/results.dart';
import '../../services/detection_service.dart';
import '../../widgets/detection_card.dart';
import '../detection/detection_detail.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DetectionService service = DetectionService();

  List<Results> detections = [];
  List<Results> filtered = [];

  bool loading = true;

  String selectedFilter = "All";
  String selectedSort = "Newest";

  @override
  void initState() {
    super.initState();
    loadDetections();
  }

  Future<void> loadDetections() async {
    final data = await service.fetchDetections();

    setState(() {
      detections = data;
      filtered = data;
      loading = false;
    });
  }

  void applyFilters() {
    List<Results> temp = [...detections];

    if (selectedFilter != "All") {
      temp = temp.where((d) =>
          d.diseaseName.toLowerCase().contains(selectedFilter.toLowerCase())).toList();
    }

    if (selectedSort == "Newest") {
      temp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      temp.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    setState(() {
      filtered = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final healthyCount = detections
        .where((d) => d.diseaseName.toLowerCase().contains("healthy"))
        .length;

    final diseasedCount = detections.length - healthyCount;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: loadDetections,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [

              /// HEADER
              _animatedItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detection History",
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "View and manage your previous scans",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// STATS
              _animatedItem(
                child: Row(
                  children: [
                    _statCard("Healthy", healthyCount, AppTheme.healthy),
                    const SizedBox(width: 10),
                    _statCard("Diseased", diseasedCount, AppTheme.disease),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// FILTER CHIPS
              _animatedItem(
                child: SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 2, right: 12),
                    children: [
                      _chip("All"),
                      _chip("Healthy"),
                      _chip("Blight"),
                      _chip("Mold"),
                      _chip("Spot"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// SORT
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();

                    setState(() {
                      selectedSort =
                          selectedSort == "Newest" ? "Oldest" : "Newest";
                      applyFilters();
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_vert, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        selectedSort,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// LIST
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      "No detections found",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(filtered.length, (index) {
                    final result = filtered[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TweenAnimationBuilder(
                        duration: Duration(milliseconds: 400 + index * 80),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: DetectionCard(
                          result: result,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetectionDetailScreen(result: result),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ANIMATION
  Widget _animatedItem({required Widget child}) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 🔥 UPDATED CHIP (NO ICON + ROUNDER)
  Widget _chip(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();

          setState(() {
            selectedFilter = label;
            applyFilters();
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.05 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primarySoft
                  : AppTheme.surface,

              /// 🔥 MORE ROUNDED (PILL SHAPE)
              borderRadius: BorderRadius.circular(30),

              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// STATS
  Widget _statCard(String title, int value, Color color) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}