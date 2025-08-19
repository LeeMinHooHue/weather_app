class DailyForecast {
  final String date;
  final double avgTemp;
  final String mainCondition;

  DailyForecast({
    required this.date,
    required this.avgTemp,
    required this.mainCondition,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json["dt_txt"], // chuỗi datetime
      avgTemp: json["main"]["temp"].toDouble(),
      mainCondition: json["weather"][0]["main"],
    );
  }
}
