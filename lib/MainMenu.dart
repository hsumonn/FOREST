import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'Caution.dart'; // Ensure Caution.dart is in the same directory or provide the correct path

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _weatherData = [];
  Map<String, String> cityToKanji = {
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
    var hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      hasPermission = await location.requestPermission();
    }

    if (hasPermission == PermissionStatus.granted) {
      final locData = await location.getLocation();
      final apiKey = '003ef1d65597b85d2ab6fa19b59383b6'; // Replace with your OpenWeatherMap API key
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=$apiKey';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      setState(() {
        final now = DateTime.now();
        final sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
        final sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
        final hoursUntilRain = sunset.difference(now).inHours;
        String cityName = data['name'];

        // Convert city name to Kanji if it exists in the map
        if (cityToKanji.containsKey(cityName)) {
          cityName = cityToKanji[cityName]!;
        }

        String iconUrl;
        if (data['weather'][0]['main'].toLowerCase().contains('rain')) {
          if (data['weather'][0]['description'].toLowerCase().contains('light')) {
            iconUrl = 'images/light_rain.png';
          } else {
            iconUrl = 'images/heavy_rain.png';
          }
        } else {
          if (now.isAfter(sunrise) && now.isBefore(sunset)) {
            iconUrl = 'images/sunny.png';
          } else {
            iconUrl = 'images/clearnight.png';
          }
        }

        _weatherData.add({
          'city': cityName,
          'iconUrl': iconUrl,
          'isRain': data['weather'][0]['main'].toLowerCase().contains('rain'),
          'rainTime': data['weather'][0]['main'].toLowerCase().contains('rain')
              ? '${hoursUntilRain}時間後-雨'
              : '晴れ',
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
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Caution()),
            );
          },
          child: Image.asset(
            weather['iconUrl'],
            width: 150, // Adjust the width as needed
            height: 150, // Adjust the height as needed
          ),
        ),
        Text(
          weather['rainTime'],
          style: const TextStyle(fontSize: 20, color: Colors.white),
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
              top: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset('images/registration.png'), // Use custom image as icon
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Caution()), // Navigate to Caution.dart
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('images/Change.png'), // Use custom image as icon
                    onPressed: () {
                      // Add your code here for the Change button
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
