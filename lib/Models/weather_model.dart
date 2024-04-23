class WeatherModel {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final int clouds;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.clouds,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDirection: json['wind']['deg'],
      clouds: json['clouds']['all'],
      visibility: json['visibility'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          json['sys']['sunrise'] * 1000,
          isUtc: true),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000,
          isUtc: true),
    );
  }
}
