import 'package:flutter/material.dart';
import '../models/plot.dart';
import '../theme/app_theme.dart';

class PlotCard extends StatelessWidget {
  final Plot plot;
  final int cropCount;
  final VoidCallback onTap;

  const PlotCard({super.key, required this.plot, required this.cropCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightSoil),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grass_rounded, color: AppColors.ripeGold, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plot.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(
                    '$cropCount crop${cropCount == 1 ? '' : 's'} • ${plot.soilType ?? 'soil unset'}',
                    style: TextStyle(fontSize: 13, color: AppColors.ink.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.soilBrown),
          ],
        ),
      ),
    );
  }
}
