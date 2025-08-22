import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/screens/new_city_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_animation.dart';
import 'package:weather_app/utils/weather_background.dart';
import 'package:weather_app/widgets/custom_container.dart';
import 'package:weather_app/widgets/forecast_widget.dart';

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
              //background theo thời tiết hiện tại
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
                // button thêm thành phố
                IconButton(
                  onPressed: _selectCity,
                  icon: const Icon(Icons.add, size: 40, color: Colors.white),
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
                        //thành phố,nhiệt độ,thời tiết hiện tại
                        buildWeatherByLocal(
                          context,
                          _forecast,
                          _getLabel,
                          city,
                          condition,
                          temp,
                        ),
                        const SizedBox(height: 170),
                        // khung dự báo 5 ngày
                        CustomContainer(
                          height: 320,
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Header
                              buildHeader5DaysForecast(),
                              // danh sách dự báo
                              SizedBox(
                                height: 200,
                                child: ForecastList(
                                  maxItem: 3,
                                  forecast: _forecast,
                                  getLabel: _getLabel,
                                ),
                              ),
                              //nút xem dự báo 5 ngày
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

Widget buildWeatherByLocal(
  BuildContext context,
  List<DailyForecast> forecast,
  String Function(int, String) getLabel,
  String city,
  String condition,
  final temp,
) {
  return Column(
    children: [
      //tên thành phố
      Text(city, style: const TextStyle(fontSize: 22, color: Colors.white)),
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
      Text(condition, style: const TextStyle(color: Colors.white70)),
    ],
  );
}

Widget buildHeader5DaysForecast() {
  return Row(
    children: const [
      Icon(Icons.calendar_today, color: Colors.white, size: 18),
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
  );
}
