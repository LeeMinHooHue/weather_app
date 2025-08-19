class WeatherAnimation {
  static String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case "thunderstorm":
        return 'assets/storm.json';
      case "rain":
        return 'assets/rainy.json';
      case "clouds":
        return 'assets/windy.json';
      default:
        return 'assets/sunny.json';
    }
  }
}
