import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    'Mountain View': '中崎町',
    // Add more cities as needed
  };

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final locations = prefs.getStringList('locations') ?? [];
    final trimmedLocations = locations.map((location) => location.trim()).toList();

    _weatherData.clear(); // Clear existing data before fetching new data

    if (trimmedLocations.isEmpty || trimmedLocations.every((location) => location.isEmpty)) {
      await _fetchCurrentDeviceLocationWeather();
    } else {
      // Limit the number of locations to 2
      if (trimmedLocations.length > 1) {
        trimmedLocations.removeAt(0); // Remove the oldest location
      }

      for (final location in trimmedLocations) {
        if (location.isNotEmpty) {
          await _getWeatherForLocation(location);
        }
      }
    }
  }

  Future<void> _fetchCurrentDeviceLocationWeather() async {
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
      final data = await _fetchWeatherDataByCoordinates(locData.latitude!, locData.longitude!);
      if (data != null) {
        _addWeatherData(data);
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchWeatherDataByCoordinates(double latitude, double longitude) async {
    const apiKey = '003ef1d65597b85d2ab6fa19b59383b6'; // Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Error fetching weather data: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching weather data:', e);
    }

    return null;
  }

  Future<void> _getWeatherForLocation(String location) async {
    final locationData = await _getLocationCoordinates(location);

    if (locationData != null) {
      final data = await _fetchWeatherDataByCoordinates(locationData.latitude!, locationData.longitude!);
      if (data != null) {
        _addWeatherData(data);
      }
    }
  }

  Future<LocationData?> _getLocationCoordinates(String location) async {
    // Example using OpenCage Geocoding API (replace with your API key)
    const apiKey = '90c42a6ae6844f05a1d5f665f1b58b6d';
    final url = 'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(location)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['results'][0]['geometry'];
        return LocationData.fromMap({
          'latitude': coordinates['lat'],
          'longitude': coordinates['lng'],
        });
      } else {
        _logger.e('Error fetching coordinates: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching coordinates:', e);
    }
    return null;
  }

  void _addWeatherData(Map<String, dynamic> data) {
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

      String iconUrl = _getIconUrl(weatherDescription, isDayTime);

      // Check if the city already exists in _weatherData
      bool cityExists = false;
      int existingIndex = -1;
      for (int i = 0; i < _weatherData.length; i++) {
        if (_weatherData[i]['city'] == cityName) {
          cityExists = true;
          existingIndex = i;
          break;
        }
      }

      if (cityExists) {
        // Update the existing entry
        _weatherData[existingIndex]['iconUrl'] = iconUrl;
        _weatherData[existingIndex]['rainTime'] = weatherDescription.contains('rain') ? '雨' : '晴れ';
      } else {
        // Add a new entry
        _weatherData.add({
          'city': cityName,
          'iconUrl': iconUrl,
          'rainTime': weatherDescription.contains('rain') ? '雨' : '晴れ',
        });
      }
    });
  }


  String _getIconUrl(String weatherDescription, bool isDayTime) {
    if (weatherDescription.contains('rain')) {
      return 'images/heavy_rain.png'; // Use the same icon for all rain types
    } else {
      return isDayTime ? 'images/sunny.png' : 'images/clearnight.png';
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
              MaterialPageRoute(builder: (context) => DetailMenu(onWeatherChange: (String description, bool dayTime) {
                setState(() {
                  // This callback function is just an example and doesn't do anything specific.
                });
              })),
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
            Positioned(
              top: 30,
              right: 10,
              child: IconButton(
                icon: Image.asset('images/registration.png'), // Use custom image as icon
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationMenu()),
                  ).then((_) => _fetchWeather()); // Refresh weather data after returning from RegistrationMenu
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _weatherData.map((weather) => _buildWeatherInfo(weather)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
