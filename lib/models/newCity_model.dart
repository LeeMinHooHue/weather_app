class NewCity {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final int temp;
  final int tempMin;
  final int tempMax;
  final String condition;

  NewCity({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
  });

  factory NewCity.fromJson(Map<String, dynamic> json) {
    return NewCity(
      name: json['name'],
      country: json['country'],
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      temp: json['temp'],
      tempMin: json['temp_min'],
      tempMax: json['temp_max'],
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "country": country,
      "lat": lat,
      "lon": lon,
      "temp": temp,
      "temp_min": tempMin,
      "temp_max": tempMax,
      "condition": condition,
    };
  }
}
