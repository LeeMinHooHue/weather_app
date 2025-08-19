import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/NewCity_model.dart';

class CityService {
  final String apiKey = "645b5ba340e664bbb3180b5fbf110874";

  Future<List<NewCity>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      List<NewCity> results = [];

      for (var city in data) {
        if (city['country'] == 'VN' &&
            (city['state']?.toLowerCase().contains(query.toLowerCase()) ??
                false ||
                    city['name'].toLowerCase().contains(query.toLowerCase()))) {
          // thêm vào results
        }

        if (city['country'] == 'VN') {
          final lat = city['lat'];
          final lon = city['lon'];

          final weatherUrl = Uri.parse(
            "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi",
          );

          final weatherRes = await http.get(weatherUrl);
          if (weatherRes.statusCode == 200) {
            final weatherData = jsonDecode(weatherRes.body);
            results.add(
              NewCity(
                name: city['name'],
                country: city['country'],
                lat: lat,
                lon: lon,
                temp: weatherData['main']['temp'].round(),
                tempMin: weatherData['main']['temp_min'].round(),
                tempMax: weatherData['main']['temp_max'].round(),
                condition: weatherData['weather'][0]['description'],
              ),
            );
          }
        }
      }
      return results;
    }
    return [];
  }

  Future<List<NewCity>> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList("savedCities") ?? [];
    return citiesJson.map((e) => NewCity.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveCity(NewCity city) async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList("savedCities") ?? [];

    if (citiesJson.any((c) {
      final decoded = jsonDecode(c);
      return decoded['name'] == city.name && decoded['country'] == city.country;
    }))
      return;

    citiesJson.add(jsonEncode(city.toJson()));
    await prefs.setStringList("savedCities", citiesJson);
  }

  Future<void> deleteCity(int index, List<NewCity> savedCities) async {
    final prefs = await SharedPreferences.getInstance();
    savedCities.removeAt(index);
    final citiesJson = savedCities.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList("savedCities", citiesJson);
  }
}
