class Weather {
  final String nameCity;
  final double temperature;
  final String mainCondition;

  Weather({
    required this.nameCity,
    required this.temperature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      nameCity: json['name'],
      temperature: json["main"]['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
