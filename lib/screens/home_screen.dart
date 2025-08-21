import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/Forecast_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/screens/newCity_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_animation.dart';
import 'package:weather_app/utils/weather_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherService = WeatherService('645b5ba340e664bbb3180b5fbf110874');

  Weather? _weather;
  List<DailyForecast> _forecast = [];

  Map<String, dynamic>? _selectedCity; // 👈 lưu city mà user chọn

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      if (_selectedCity != null) {
        // Nếu user đã chọn city → dùng lat/lon từ city đó
        final weather = await _weatherService.getWeatherByLocation(
          _selectedCity!['lat'],
          _selectedCity!['lon'],
        );
        final forecast = await _weatherService.getDailyForecast(
          weather.nameCity,
        );

        setState(() {
          _weather = weather;
          _forecast = forecast;
        });
      } else {
        // Nếu chưa chọn city → dùng GPS
        Position pos = await _weatherService.getCurrentPosition();
        final weather = await _weatherService.getWeatherByLocation(
          pos.latitude,
          pos.longitude,
        );
        final forecast = await _weatherService.getDailyForecast(
          weather.nameCity,
        );

        setState(() {
          _weather = weather;
          _forecast = forecast;
        });
      }
    } catch (e) {
      print("Error fetching weather & forecast: $e");
    }
  }

  // chọn city mới
  Future<void> _selectCity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewCityScreen()),
    ).then((selectedCity) {
      _selectedCity = selectedCity; // có thể null nếu user chỉ xoá city
      _fetchData(); // luôn refresh lại khi về HomeScreen
    });
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
    final temp = _weather?.temperature.round() ?? 0;
    final condition = _weather?.mainCondition ?? "clear";

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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // button add city
                IconButton(
                  onPressed: _selectCity,
                  icon: const Icon(Icons.add, size: 40),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _fetchData,
            child: _weather == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // tên thành phố
                        Text(
                          city,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        // animation thời tiết
                        Lottie.asset(
                          WeatherAnimation.getWeatherAnimation(condition),
                          height: 150,
                        ),
                        // nhiệt độ
                        Text(
                          "$temp °C",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // thời tiết hiện tại
                        Text(
                          condition,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 170),
                        // khung dự báo 5 ngày
                        Container(
                          height: 315,
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
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
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Row(
                                children: const [
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
                              // khung hiển thị 3 ngày tiếp theo
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: min(3, _forecast.length),
                                  itemBuilder: (context, index) {
                                    final f = _forecast[index];
                                    return ForecastItem(
                                      label: _getLabel(index, f.date),
                                      minTemp: f.minTemp.round(),
                                      maxTemp: f.maxTemp.round(),
                                      condition: f.mainCondition,
                                    );
                                  },
                                ),
                              ),
                              // button dự báo 5 ngày
                              buildButtonWidget(context, city),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget buildButtonWidget(BuildContext context, String city) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ForecastScreen(city: city)),
      );
    },
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white10.withOpacity(0.15),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: const Center(
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
  );
}
