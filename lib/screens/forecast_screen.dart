import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/WForecast_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_animation.dart';

class ForecastScreen extends StatefulWidget {
  final String city;
  const ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final _weatherService = WeatherService("645b5ba340e664bbb3180b5fbf110874");
  List<DailyForecast> _forecast = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      final data = await _weatherService.getDailyForecast(widget.city);
      setState(() {
        _forecast = data;
        _loading = false;
      });
    } catch (e) {
      print("Error: $e");
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
    return Scaffold(
      appBar: AppBar(title: Text("Dự báo 5 ngày - ${widget.city}")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _forecast.length,
              itemBuilder: (context, index) {
                final f = _forecast[index];
                return ForecastItem(
                  label: _getLabel(index, f.date),
                  temp: f.avgTemp.round(),
                  condition: f.mainCondition,
                );
              },
            ),
    );
  }
}

/// Widget riêng để hiển thị 1 ngày dự báo
class ForecastItem extends StatelessWidget {
  final String label;
  final int temp;
  final String condition;

  const ForecastItem({
    super.key,
    required this.label,
    required this.temp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                ),
              ),
              Text(
                condition,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
