import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umbrella/detail_menu.dart';
import 'package:umbrella/registration_menu.dart';

String globalAutoLocation = '';
String globalCurrentLocation = '';
String globalDestinationLocation = '';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainMenu(),
  ));
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, dynamic>? _autoWeatherData;
  Map<String, dynamic>? _currentWeatherData;
  Map<String, dynamic>? _destinationWeatherData;
  final Logger _logger = Logger();
  final Map<String, String> cityToKanji = {
    'Hokkaido': '北海道',
    'Aomori': '青森',
    'Iwate': '岩手',
    'Miyagi': '宮城',
    'Akita': '秋田',
    'Yamagata': '山形',
    'Fukushima': '福島',
    'Ibaraki': '茨城',
    'Tochigi': '栃木',
    'Gunma': '群馬',
    'Saitama': '埼玉',
    'Chiba': '千葉',
    'Tokyo': '東京',
    'Kanagawa': '神奈川',
    'Niigata': '新潟',
    'Toyama': '富山',
    'Ishikawa': '石川',
    'Fukui': '福井',
    'Yamanashi': '山梨',
    'Nagano': '長野',
    'Gifu': '岐阜',
    'Shizuoka': '静岡',
    'Aichi': '愛知',
    'Mie': '三重',
    'Shiga': '滋賀',
    'Kyoto': '京都',
    'Osaka': '大阪',
    'Hyogo': '兵庫',
    'Nara': '奈良',
    'Wakayama': '和歌山',
    'Tottori': '鳥取',
    'Shimane': '島根',
    'Okayama': '岡山',
    'Hiroshima': '広島',
    'Yamaguchi': '山口',
    'Tokushima': '徳島',
    'Kagawa': '香川',
    'Ehime': '愛媛',
    'Kochi': '高知',
    'Fukuoka': '福岡',
    'Saga': '佐賀',
    'Nagasaki': '長崎',
    'Kumamoto': '熊本',
    'Oita': '大分',
    'Miyazaki': '宮崎',
    'Kagoshima': '鹿児島',
    'Okinawa': '沖縄',
  };

  String weatherDescription = '';
  bool isDayTime = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadPreferences();
  }

  Future<void> _fetchWeather({String? location}) async {
    String url;

    if (location == null) {
      final locData = await _getLocation();
      if (locData == null) return;
      url =
      'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';
    } else {
      url =
      'https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';
    }

    try {
      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _updateWeatherData(data, location: location);
        });
      } else {
        _logger.e('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching weather data:', e);
    }
  }

  Future<LocationData?> _getLocation() async {
    final location = Location();
    LocationData? locData;

    try {
      var hasPermission = await location.hasPermission();
      if (hasPermission == PermissionStatus.denied) {
        hasPermission = await location.requestPermission();
      }

      if (hasPermission == PermissionStatus.granted) {
        locData = await location.getLocation();
      } else {
        _logger.w('Location permission denied');
      }
    } catch (e) {
      _logger.e('Error fetching location:', e);
    }

    return locData;
  }

  void _updateWeatherData(Map<String, dynamic> data, {String? location}) {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Determine daytime and nighttime based on current time
    isDayTime = currentHour >= 5 && currentHour < 18;

    weatherDescription = data['weather'][0]['description'].toLowerCase();
    String cityName = data['name'];

    if (cityToKanji.containsKey(cityName)) {
      cityName = cityToKanji[cityName]!;
    }

    String iconUrl;
    String weatherKanji;
    if (weatherDescription.contains('rain')) {
      iconUrl = 'images/heavy_rain.png';
      weatherKanji = '雨';
    } else if (weatherDescription.contains('cloud')) {
      iconUrl = 'images/cloudy.png';
      weatherKanji = '曇り';
    } else {
      iconUrl = isDayTime ? 'images/sunny.png' : 'images/clearnight.png';
      weatherKanji = '晴れ';
    }

    final weatherData = {
      'city': cityName,
      'iconUrl': iconUrl,
      'weather': weatherKanji,
    };

    if (location == globalAutoLocation) {
      _autoWeatherData = weatherData;
    } else if (location == globalCurrentLocation) {
      _currentWeatherData = weatherData;
    } else if (location == globalDestinationLocation) {
      _destinationWeatherData = weatherData;
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      globalAutoLocation = prefs.getString('autoLocation') ?? '';
      globalCurrentLocation = prefs.getString('currentLocation') ?? '';
      globalDestinationLocation = prefs.getString('destination') ?? '';
    });

    if (globalAutoLocation.isNotEmpty) {
      await _fetchWeather(location: globalAutoLocation);
    }

    if (globalCurrentLocation.isNotEmpty) {
      await _fetchWeather(location: globalCurrentLocation);
    }

    if (globalDestinationLocation.isNotEmpty) {
      await _fetchWeather(location: globalDestinationLocation);
    }

    // Determine auto location if currentLocation is not provided
    if (globalCurrentLocation.isEmpty) {
      _fetchAutoLocation().then((autoLocation) {
        if (autoLocation != null) {
          setState(() {
            globalAutoLocation = autoLocation;
          });
          _fetchWeather(location: globalAutoLocation);
        }
      });
    }
  }

  Future<String?> _fetchAutoLocation() async {
    try {
      final locData = await _getLocation();
      if (locData != null) {
        final url =
            'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';
        final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['name'];
        } else {
          _logger.e('Failed to fetch auto location: ${response.statusCode}');
          return null;
        }
      } else {
        _logger.e('Failed to fetch current location data');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching auto location:', e);
      return null;
    }
  }

  List<Color> getGradientColors() {
    if ((_currentWeatherData != null &&
        _currentWeatherData!['weather'].contains('雨')) ||
        (_destinationWeatherData != null &&
            _destinationWeatherData!['weather'].contains('雨')) ||
        (_autoWeatherData != null &&
            _autoWeatherData!['weather'].contains('雨'))) {
      return isDayTime
          ? [Colors.blueGrey, Colors.white]
          : [Colors.black45, Colors.white];
    } else if (weatherDescription.contains('clear')) {
      return isDayTime
          ? [Colors.lightBlueAccent, Colors.white]
          : [Colors.black45, Colors.white];
    } else if (weatherDescription.contains('haze') ||
        weatherDescription.contains('cloudy')) {
      return isDayTime
          ? [Colors.lightBlueAccent, Colors.white]
          : [Colors.black45, Colors.white];
    } else if (weatherDescription.contains('thunderstorm')) {
      return [Colors.black45, Colors.white];
    } else {
      return [Colors.lightBlueAccent, Colors.white];
    }
  }

  Widget _buildWeatherInfo(Map<String, dynamic> weather, String location) {
    String displayLocation = '';

    if (location == globalCurrentLocation) {
      displayLocation = '現在地';
    } else if (location == globalDestinationLocation) {
      displayLocation = '勤務地';
    } else if (location == globalAutoLocation) {
      displayLocation = '現在地';
    }
    String passLocation = '';
    if (location == globalAutoLocation) {
      passLocation = globalAutoLocation; // Example, replace with actual location based on the image
    } else if (location == globalCurrentLocation) {
      passLocation = globalCurrentLocation; // Example, replace with actual location based on the image
    } else if (location == globalDestinationLocation) {
      passLocation = globalDestinationLocation; // Example, replace with actual location based on the image
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '$displayLocation: ${weather['city']}',
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DetailMenu(
                      onWeatherChange: (String newDescription, bool dayTime,
                          List<double> newRainfallData,
                          double newRainProbability) {
                        _logger.i('Weather changed: $newDescription, $dayTime');
                        setState(() {
                          weatherDescription = newDescription;
                          isDayTime = dayTime;
                        });
                      },
                      location: passLocation,
                    ),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            children: [
              Image.asset(
                weather['iconUrl'],
                width: 170,
                height: 170,
              ),
              const SizedBox(height: 10),
              Text(
                '${weather['weather']}',
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getGradientColors(),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_currentWeatherData != null &&
                        _destinationWeatherData != null)
                      Column(
                        children: [
                          _buildWeatherInfo(
                              _currentWeatherData!, globalCurrentLocation),
                          const SizedBox(height: 30), // Adjust spacing as needed
                          _buildWeatherInfo(
                              _destinationWeatherData!, globalDestinationLocation),
                        ],
                      ),
                    if (_currentWeatherData != null &&
                        _destinationWeatherData == null)
                      _buildWeatherInfo(
                          _currentWeatherData!, globalCurrentLocation),
                    if (_currentWeatherData == null &&
                        _destinationWeatherData != null)
                      Column(
                        children: [
                          _buildWeatherInfo(_autoWeatherData!, globalAutoLocation),
                          const SizedBox(height: 30), // Adjust spacing as needed
                          _buildWeatherInfo(
                              _destinationWeatherData!, globalDestinationLocation),
                        ],
                      ),
                    if (_currentWeatherData == null &&
                        _destinationWeatherData == null &&
                        _autoWeatherData != null)
                      _buildWeatherInfo(_autoWeatherData!, globalAutoLocation),
                    if (_currentWeatherData == null &&
                        _destinationWeatherData == null &&
                        _autoWeatherData == null)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 10,
              child: IconButton(
                icon: Image.asset('images/registration.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationMenu(),
                    ),
                  ).then((_) {
                    _loadPreferences();
                  });
                },
              ),
            ),
            Positioned(
              top: 40,
              right: MediaQuery.of(context).size.width / 2 - 65,
              child: const Text(
                '現在の天気',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
