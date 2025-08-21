import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/Forecast_model.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeatherByLocation(double lat, double lon) async {
    final url = '$BASE_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    print("API URL: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Fail: ${response.body}");
    }
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<DailyForecast>> getDailyForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast'
        '?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric';

    print("Forecast API URL: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List forecasts = data["list"];

      Map<String, List<double>> tempByDay = {};
      Map<String, List<String>> conditionByDay = {};

      for (var f in forecasts) {
        String date = f["dt_txt"].substring(0, 10); // lấy yyyy-MM-dd
        double temp = f["main"]["temp"].toDouble();
        String cond = f["weather"][0]["main"];

        tempByDay.putIfAbsent(date, () => []);
        conditionByDay.putIfAbsent(date, () => []);

        tempByDay[date]!.add(temp);
        conditionByDay[date]!.add(cond);
      }

      List<DailyForecast> results = [];
      tempByDay.forEach((day, temps) {
        double minTemp = temps.reduce((a, b) => a < b ? a : b);
        double maxTemp = temps.reduce((a, b) => a > b ? a : b);

        // chọn điều kiện thời tiết xuất hiện nhiều nhất trong ngày
        var condList = conditionByDay[day]!;
        String mainCond = condList
            .fold<Map<String, int>>({}, (map, cond) {
              map[cond] = (map[cond] ?? 0) + 1;
              return map;
            })
            .entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        results.add(
          DailyForecast(
            date: day,
            minTemp: minTemp,
            maxTemp: maxTemp,
            mainCondition: mainCond,
          ),
        );
      });

      return results;
    } else {
      print("Forecast Response: ${response.body}");
      throw Exception("Failed to load forecast");
    }
  }
}
