import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'detail_menu.dart'; // Import DetailMenu.dart or provide the correct path
import 'registration_menu.dart'; // Import registration_menu.dart or provide the correct path

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _weatherData = [];
  final Logger _logger = Logger();
  final Map<String, String> cityToKanji = {
    'Tokyo': '東京',
    'Kyoto': '京都',
    'Osaka': '大阪',
    'Nagoya': '名古屋',
    'Sapporo': '札幌',
    'Fukuoka': '福岡',
    'Hiroshima': '広島',
    'Mountain View': '中崎',
    // Add more cities as needed
  };

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final location = Location();
    LocationData? locData;
    PermissionStatus? hasPermission;

    try {
      hasPermission = await location.hasPermission();
      if (hasPermission == PermissionStatus.denied) {
        hasPermission = await location.requestPermission();
      }

      if (hasPermission == PermissionStatus.granted) {
        locData = await location.getLocation();
      }
    } catch (e) {
      _logger.e('Error fetching location:', e);
    }

    if (locData != null) {
      const apiKey = '003ef1d65597b85d2ab6fa19b59383b6'; // Replace with your OpenWeatherMap API key
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=$apiKey';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      setState(() {
        final now = DateTime.now();
        final sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
        final sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
        final isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);
        final weatherDescription = data['weather'][0]['description'].toLowerCase();
        String cityName = data['name'];

        // Convert city name to Kanji if it exists in the map
        if (cityToKanji.containsKey(cityName)) {
          cityName = cityToKanji[cityName]!;
        }

        String iconUrl;
        if (weatherDescription.contains('rain')) {
          if (weatherDescription.contains('light')) {
            iconUrl = isDayTime ? 'images/light_rain_noon.png' : 'images/light_rain_night.png';
          } else {
            iconUrl = 'images/heavy_rain.png';
          }
        } else {
          iconUrl = isDayTime ? 'images/sunny.png' : 'images/clearnight.png';
        }

        _weatherData.add({
          'city': cityName,
          'iconUrl': iconUrl,
          'rainTime': weatherDescription.contains('rain') ? '雨' : '晴れ',
        });
      });
    }
  }

  Widget _buildWeatherInfo(Map<String, dynamic> weather) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          weather['city'],
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailMenu()),
            );
          },
          child: Image.asset(
            weather['iconUrl'],
            width: 160,
            height: 160,
          ),
        ),
        Text(
          weather['rainTime'],
          style: const TextStyle(fontSize: 25, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF9BE2F9), // Background color
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _weatherData.map((weather) => _buildWeatherInfo(weather)).toList(),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset('images/registration.png'), // Use custom image as icon
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationMenu()), // Navigate to RegistrationMenu.dart
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
