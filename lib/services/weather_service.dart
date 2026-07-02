import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
static const _apiKey = '78774cf126df6b9828922ed4c2e50c77';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final uri = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather fetch failed (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

 
  Future<List<Map<String, dynamic>>> getDailyForecast(double lat, double lon) async {
    final uri = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Forecast fetch failed (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['list'] as List).cast<Map<String, dynamic>>();

    final Map<String, Map<String, dynamic>> byDay = {};
    for (final entry in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch((entry['dt'] as int) * 1000);
      final dayKey = '${dt.year}-${dt.month}-${dt.day}';
      final temp = (entry['main']['temp'] as num).toDouble();
      final rain = ((entry['rain']?['3h']) as num?)?.toDouble() ?? 0;
      final condition = (entry['weather'] as List).isNotEmpty
          ? entry['weather'][0]['main'] as String
          : null;

      byDay.putIfAbsent(dayKey, () => {
            'date': DateTime(dt.year, dt.month, dt.day),
            'high': temp,
            'low': temp,
            'precip': 0.0,
            'condition': condition,
          });
      final day = byDay[dayKey]!;
      if (temp > (day['high'] as double)) day['high'] = temp;
      if (temp < (day['low'] as double)) day['low'] = temp;
      day['precip'] = (day['precip'] as double) + rain;
    }
    return byDay.values.toList();
  }
}
