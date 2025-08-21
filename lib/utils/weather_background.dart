class WeatherBackground {
  static String getBackground(String condition, {bool isDay = true}) {
    condition = condition.toLowerCase();
    if (condition.contains("clear")) {
      return isDay ? "assets/clear.jpg" : "assets/clear_night.jpg";
    } else if (condition.contains("cloud")) {
      return isDay ? "assets/cloud_sky.jpg" : "assets/cloud_night.jpg";
    } else if (condition.contains("rain")) {
      return "assets/raining.jpg";
    } else if (condition.contains("sunny")) {
      return "assets/sunny.gif";
    } else {
      return "assets/clear.jpg";
    }
  }
}
