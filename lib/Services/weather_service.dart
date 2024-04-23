import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sportswander/Models/weather_model.dart';

class WeatherService {
  static const Base_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;
  WeatherService({required this.apiKey});
  Future<WeatherModel> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$Base_URL?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.requestPermission();
//get permission from user
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    //fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    //convert the location into list of placemarks objects
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    //extract the city name from the first placemark object
    String? city = placemarks[0].locality;

    return city ?? "No City";
  }
}
