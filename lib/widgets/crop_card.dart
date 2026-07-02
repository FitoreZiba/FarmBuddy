import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../theme/app_theme.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;

  const CropCard({super.key, required this.crop, required this.onTap});

  IconData get _icon {
    switch (crop.cropType) {
      case 'Watermelon':
        return Icons.circle; // simple stand-in; replace with custom asset later
      case 'Tomato':
        return Icons.eco_rounded;
      default:
        return Icons.grass_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightSoil),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightSoil,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.soilBrown, size: 20),
            ),
            const SizedBox(height: 10),
            Text(crop.cropType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (crop.variety != null)
              Text(crop.variety!, style: TextStyle(fontSize: 12, color: AppColors.ink.withOpacity(0.6))),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (crop.progressPercent / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.lightSoil,
                valueColor: const AlwaysStoppedAnimation(AppColors.ripeGold),
              ),
            ),
            const SizedBox(height: 4),
            Text('${crop.progressPercent.toStringAsFixed(0)}% to harvest',
                style: TextStyle(fontSize: 11, color: AppColors.ink.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
