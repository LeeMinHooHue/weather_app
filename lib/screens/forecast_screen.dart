import 'package:flutter/material.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/forecast_widget.dart';

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
      body: RefreshIndicator(
        onRefresh: _loadForecast,
        child: _loading
            ? SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: const Center(child: CircularProgressIndicator()),
              )
            : ForecastList(
                forecast: _forecast,
                getLabel: _getLabel,
                maxItem: 7,
              ),
      ),
    );
  }
}
