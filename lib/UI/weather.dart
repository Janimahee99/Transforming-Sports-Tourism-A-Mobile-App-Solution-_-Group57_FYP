import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sportswander/Models/weather_model.dart';
import 'package:sportswander/Services/weather_service.dart';

import 'drawer.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService =
      WeatherService(apiKey: "929e0e75bd5d1b23e0f5f24ea5faa71e");
  WeatherModel? _weatherModel;

  // Fetch weather
  _fetchWeather() async {
    final cityName = await _weatherService.getCurrentCity();
    print(cityName);
    try {
      final weather = await _weatherService.getWeather("Colombo");
      print(weather);
      setState(() {
        _weatherModel = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  // Weather animations
  String getWeatherAnimation(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case "clear":
        return 'assets/sunny.json';
      case "clouds":
        return 'assets/cloud.json';
      case "mist":
      case "smoke":
      case "haze":
      case "fog":
        return 'assets/mist.json';
      case "shower rain":
        return 'assets/partly_shower.json';
      case "drizzle":
      case "rain":
        return 'assets/rain.json';
      case "thunderstorm":
        return 'assets/thunder.json';
      case "snow":
        return 'assets/snow.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // Init State
  @override
  void initState() {
    super.initState();
    // Fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 207, 132, 1).withOpacity(0.57),
      drawer: ProfileDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Center(
        child: _weatherModel != null
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      // City name
                      Text(
                        _weatherModel!.cityName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontFamily: 'MadimiOne'),
                      ),

                      // Temperature and condition
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_weatherModel!.temperature.round()}°C",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 70.0,
                                fontFamily: 'MadimiOne'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _weatherModel!.mainCondition,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontFamily: 'MadimiOne'),
                          ),
                        ],
                      ),
                      SizedBox(height: 1),

                      // Weather animation
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset(
                            getWeatherAnimation(_weatherModel!.mainCondition)),
                      ),

                      SizedBox(height: 1),

                      // Additional weather details

                      Row(
                        children: [
                          Container(
                            transformAlignment: Alignment.centerLeft,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildWeatherDetailRow(Icons.wb_sunny,
                                    "Sunrise: ${_weatherModel!.sunrise.hour}:${_weatherModel!.sunrise.minute} AM"),
                                _buildWeatherDetailRow(Icons.brightness_3,
                                    "Sunset: ${_weatherModel!.sunset.hour}:${_weatherModel!.sunset.minute} PM"),
                              ],
                            ),
                          ),
                          SizedBox(width: 24),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              children: [
                                _buildWeatherDetailRow4(Icons.cloud,
                                    "Cloudiness: ${_weatherModel!.clouds}% "),
                                _buildWeatherDetailRow5(Icons.visibility,
                                    "Visibility: ${_weatherModel!.visibility} m"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                _buildWeatherDetailRow2(Icons.opacity,
                                    "Humidity: ${_weatherModel!.humidity}%"),
                                _buildWeatherDetailRow1(Icons.air,
                                    "Pressure: ${_weatherModel!.pressure} hPa"),
                                _buildWeatherDetailRow3(Icons.waves,
                                    "Wind: ${_weatherModel!.windSpeed} m/s, ${_weatherModel!.windDirection}°"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
    );
  }

  Widget _buildWeatherDetailRow(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow1(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 40),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow2(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 70),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow3(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 28),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow4(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 30),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow5(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 17),
          Text(detail,
              style: TextStyle(
                  color: Colors.white, fontFamily: 'MadimiOne', fontSize: 12)),
        ],
      ),
    );
  }
}
