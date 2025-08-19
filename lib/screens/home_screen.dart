import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/WForecast_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/screens/newCity_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_animation.dart';
import 'package:weather_app/utils/weather_background.dart'; // 👈 thêm import này

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherService = WeatherService('645b5ba340e664bbb3180b5fbf110874');
  Weather? _weather;
  List<DailyForecast> _forecast = [];

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _fetchForecast();
  }

  Future<void> _fetchWeather() async {
    try {
      Position pos = await _weatherService.getCurrentPosition();
      final weather = await _weatherService.getWeatherByLocation(
        pos.latitude,
        pos.longitude,
      );
      setState(() => _weather = weather);
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  Future<void> _fetchForecast() async {
    try {
      Position pos = await _weatherService.getCurrentPosition();
      final city = await _weatherService.getWeatherByLocation(
        pos.latitude,
        pos.longitude,
      ); // hoặc dùng city name
      final forecast = await _weatherService.getDailyForecast(city.nameCity);
      setState(() => _forecast = forecast);
    } catch (e) {
      print("Error fetching forecast: $e");
    }
  }

  String _getLabel(int index, String date) {
    if (index == 0) return "Hôm nay";
    if (index == 1) return "Ngày mai";

    final d = DateTime.parse(date);
    const weekdays = [
      "Chủ nhật",
      "Thứ 2",
      "Thứ 3",
      "Thứ 4",
      "Thứ 5",
      "Thứ 6",
      "Thứ 7",
    ];
    return weekdays[d.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final city = _weather?.nameCity ?? "Loading...";
    final temp = _weather?.temperature.round();
    final condition = _weather?.mainCondition ?? "clear"; // 👈 fallback Clear

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              WeatherBackground.getBackground(
                condition,
                isDay: DateTime.now().hour >= 6 && DateTime.now().hour < 18,
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // 👈 để nhìn thấy background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      final selectedCity = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewCityScreen()),
                      );

                      if (selectedCity != null) {
                        final weather = await _weatherService
                            .getWeatherByLocation(
                              selectedCity['lat'],
                              selectedCity['lon'],
                            );
                        setState(() => _weather = weather);
                      }
                    },
                    icon: const Icon(Icons.add, size: 40),
                  ),
                ],
              ),
            ),
          ),
          body: Center(
            child: _weather == null
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Lottie.asset(
                        WeatherAnimation.getWeatherAnimation(condition),
                        height: 150,
                      ),
                      Text(
                        "$temp °C",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        condition,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(height: 150),
                      Container(
                        height: 295,
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Dự báo 5 ngày',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                itemCount: min(3, _forecast.length),
                                itemBuilder: (context, index) {
                                  final f = _forecast[index];
                                  return ForecasttItem(
                                    label: _getLabel(index, f.date),
                                    temp: f.avgTemp.round(),
                                    condition: f.mainCondition,
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForecastScreen(city: city),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white10.withOpacity(0.15),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Dự báo 5 ngày',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Forecast items
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class ForecasttItem extends StatelessWidget {
  final String label;
  final int temp;
  final String condition;

  const ForecasttItem({
    super.key,
    required this.label,
    required this.temp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Lottie.asset(
          WeatherAnimation.getWeatherAnimation(condition),
          height: 60,
          width: 60,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "$temp°C",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              condition,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
