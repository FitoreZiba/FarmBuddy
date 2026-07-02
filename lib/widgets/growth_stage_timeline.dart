import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../theme/app_theme.dart';

/// Custom-built stage timeline + GDD progress bar for Crop Detail.
/// Deliberately not a stock Stepper/LinearProgressIndicator — built from
/// scratch so the stage dots, connecting track, and gold progress fill
/// all share one cohesive visual language.
class GrowthStageTimeline extends StatelessWidget {
  final CropStage currentStage;
  final double progressPercent; // 0-100, drives the gold GDD bar
  final String? estimateLabel;

  const GrowthStageTimeline({
    super.key,
    required this.currentStage,
    required this.progressPercent,
    this.estimateLabel,
  });

  static const _stages = [
    CropStage.seed,
    CropStage.germination,
    CropStage.vegetative,
    CropStage.flowering,
    CropStage.fruiting,
    CropStage.harvested,
  ];

  static const _labels = {
    CropStage.seed: 'Seed',
    CropStage.germination: 'Germ.',
    CropStage.vegetative: 'Veg.',
    CropStage.flowering: 'Flower',
    CropStage.fruiting: 'Fruit',
    CropStage.harvested: 'Harvest',
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexOf(currentStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_stages.length, (i) {
              final reached = i <= currentIndex;
              final isLast = i == _stages.length - 1;
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _StageDot(filled: reached, isCurrent: i == currentIndex),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: i < currentIndex ? AppColors.leafGreen : AppColors.lightSoil,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[_stages[i]]!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: reached ? FontWeight.w700 : FontWeight.w400,
                        color: reached ? AppColors.deepGreen : AppColors.ink.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Growing Degree Days progress',
          style: TextStyle(fontSize: 12, color: AppColors.ink.withOpacity(0.6)),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 16, color: AppColors.lightSoil),
              FractionallySizedBox(
                widthFactor: (progressPercent / 100).clamp(0, 1),
                child: Container(
                  height: 16,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.ripeGold, Color(0xFFC98A2C)]),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${progressPercent.toStringAsFixed(0)}% to maturity',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            if (estimateLabel != null)
              Text(estimateLabel!, style: TextStyle(fontSize: 12, color: AppColors.ink.withOpacity(0.6))),
          ],
        ),
      ],
    );
  }
}

class _StageDot extends StatelessWidget {
  final bool filled;
  final bool isCurrent;
  const _StageDot({required this.filled, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCurrent ? 18 : 14,
      height: isCurrent ? 18 : 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.leafGreen : Colors.white,
        border: Border.all(color: filled ? AppColors.leafGreen : AppColors.lightSoil, width: 2),
        boxShadow: isCurrent
            ? [BoxShadow(color: AppColors.leafGreen.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
    );
  }
}
