class DailyForecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String mainCondition;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.mainCondition,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json["dt_txt"], // chuỗi datetime
      minTemp: json["main"]["temp"].toDouble(),
      maxTemp: json["main"]["temp"].toDouble(),
      mainCondition: json["weather"][0]["main"],
    );
  }
}
