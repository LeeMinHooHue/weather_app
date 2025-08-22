import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/widgets/forecastitem_widget.dart';

class ForecastList extends StatelessWidget {
  final List<DailyForecast> forecast;
  final String Function(int, String) getLabel;
  final int? maxItem;

  const ForecastList({
    Key? key,
    required this.forecast,
    required this.getLabel,
    required this.maxItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: min(maxItem!, forecast.length),
      itemBuilder: (context, index) {
        final f = forecast[index];
        return ForecastItem(
          label: getLabel(index, f.date),
          minTemp: f.minTemp.round(),
          maxTemp: f.maxTemp.round(),
          condition: f.mainCondition,
        );
      },
    );
  }
}
