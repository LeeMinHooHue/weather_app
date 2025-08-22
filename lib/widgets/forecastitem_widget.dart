import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/utils/weather_animation.dart';

class ForecastItem extends StatelessWidget {
  final String label;
  final int minTemp;
  final int maxTemp;
  final String condition;

  const ForecastItem({
    super.key,
    required this.label,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ForecastCard(
        label: label,
        minTemp: minTemp,
        maxTemp: maxTemp,
        condition: condition,
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final String label;
  final int minTemp;
  final int maxTemp;
  final String condition;

  const ForecastCard({
    super.key,
    required this.label,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              "$minTemp°C - $maxTemp°C",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              condition,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
