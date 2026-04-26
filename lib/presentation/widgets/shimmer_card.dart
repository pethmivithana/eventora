// lib/presentation/widgets/shimmer_card.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor:
            isDark ? const Color(0xFF1E1640) : const Color(0xFFEEE9FF),
        highlightColor:
            isDark ? const Color(0xFF2D2450) : const Color(0xFFF8F5FF),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1640)
                : const Color(0xFFEEE9FF),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(
                            height: 11,
                            width: 80,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 11, color: Colors.white),
              const SizedBox(height: 8),
              Container(
                  height: 11, width: 200, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}