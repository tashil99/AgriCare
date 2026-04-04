import 'package:flutter/material.dart';
import 'dart:convert';

import '../theme/app_theme.dart';
import '../entities/results.dart';

class DetectionCard extends StatelessWidget {
  final Results result;
  final VoidCallback onTap;

  const DetectionCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final formattedDate =
        "${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}";

    final isHealthy =
        result.diseaseName.toLowerCase().contains("healthy");

    final statusColor =
        isHealthy ? AppTheme.healthy : AppTheme.disease;

    final badgeBg = statusColor.withOpacity(0.12);

    final statusText = isHealthy ? "Healthy" : "Diseased";

    final accuracy = result.confidence.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [

              /// 📸 IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(
                  base64Decode(result.imageBase64),
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 14),

              /// 📊 INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// DATE
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 6),

                    /// DISEASE NAME (BLACK)
                    Text(
                      result.diseaseName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 LABEL
                    Text(
                      "Detection accuracy",
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 6),

                    /// 🔥 PROGRESS BAR + %
                    Row(
                      children: [

                        /// PROGRESS BAR
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: accuracy,
                              minHeight: 8,
                              backgroundColor: AppTheme.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// PERCENT
                        Text(
                          "${(accuracy * 100).toStringAsFixed(0)}%",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 🔥 STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// ➡ ARROW
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppTheme.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}