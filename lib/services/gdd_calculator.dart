import '../models/weather_snapshot.dart';


class GddCalculator {
  static double dailyGdd({
    required double tempHighC,
    required double tempLowC,
    required double baseTempC,
  }) {
    final mean = (tempHighC + tempLowC) / 2;
    final gdd = mean - baseTempC;
    return gdd > 0 ? gdd : 0;
  }

  
  static double accumulate({
    required List<WeatherSnapshot> snapshots,
    required double baseTempC,
  }) {
    double total = 0;
    for (final s in snapshots) {
      total += dailyGdd(tempHighC: s.tempHighC, tempLowC: s.tempLowC, baseTempC: baseTempC);
    }
    return total;
  }

  static double percentToMaturity({
    required double accumulatedGDD,
    required double gddToMaturity,
  }) {
    if (gddToMaturity <= 0) return 0;
    final pct = (accumulatedGDD / gddToMaturity) * 100;
    return pct.clamp(0, 100);
  }

 
  static DateTime? estimateHarvestDate({
    required DateTime plantingDate,
    required double accumulatedGDD,
    required double gddToMaturity,
  }) {
    final daysElapsed = DateTime.now().difference(plantingDate).inDays;
    if (daysElapsed <= 0 || accumulatedGDD <= 0) return null;
    final avgDailyGdd = accumulatedGDD / daysElapsed;
    if (avgDailyGdd <= 0) return null;
    final remainingGdd = gddToMaturity - accumulatedGDD;
    if (remainingGdd <= 0) return DateTime.now();
    final daysRemaining = (remainingGdd / avgDailyGdd).ceil();
    return DateTime.now().add(Duration(days: daysRemaining));
  }
}
