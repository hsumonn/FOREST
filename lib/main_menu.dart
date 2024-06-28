import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'detail_menu.dart';
import 'registration_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, dynamic>? _weatherData;
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
  };

  String weatherDescription = '';
  bool isDayTime = true;
  String userName = '';
  String _currentLocation = '';
  String _destination = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadUserName();
    _loadPreferences();
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
        isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);
        weatherDescription = data['weather'][0]['description'].toLowerCase();
        String cityName = data['name'];

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

        _weatherData = {
          'city': cityName,
          'iconUrl': iconUrl,
          'rainTime': weatherDescription.contains('rain') ? '雨' : '晴れ',
        };
      });
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('currentLocation') ?? '';
      _destination = prefs.getString('destination') ?? '';
    });
  }

  List<Color> getGradientColors() {
    if (weatherDescription.contains('rain')) {
      return isDayTime ? [Colors.blueGrey, Colors.white24] : [Colors.black45, Colors.white24];
    } else if (weatherDescription.contains('clear')) {
      return isDayTime ? [Colors.lightBlueAccent, Colors.white] : [Colors.black45, Colors.white24];
    } else if (weatherDescription.contains('haze') || weatherDescription.contains('cloudy')) {
      return isDayTime ? [Colors.lightBlueAccent, Colors.white] : [Colors.black45, Colors.white24];
    } else if (weatherDescription.contains('thunderstorm')) {
      return [Colors.black45, Colors.white24];
    } else {
      return [Colors.lightBlueAccent, Colors.white];
    }
  }

  Widget _buildWeatherInfo(Map<String, dynamic> weather, String currentLocation, String destination) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (currentLocation.isNotEmpty)
          Column(
            children: [
              Text(
                '現在位置: $currentLocation',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => DetailMenu(
                        onWeatherChange: (String newDescription, bool dayTime, List<double> newRainfallData, double newRainProbability) {
                          print('Weather changed: $newDescription, Daytime: $dayTime');
                        },
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
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
          ),
        if (destination.isNotEmpty)
          Column(
            children: [
              Text(
                '目的地: $destination',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => DetailMenu(
                        onWeatherChange: (String newDescription, bool dayTime, List<double> newRainfallData, double newRainProbability) {
                          print('Weather changed: $newDescription, Daytime: $dayTime');
                        },
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
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
                child: _weatherData != null
                    ? _buildWeatherInfo(_weatherData!, _currentLocation, _destination)
                    : CircularProgressIndicator(),
              ),
            ),
            Positioned(
              top: 30,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset('images/registration.png'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationMenu()),
                      ).then((_) {
                        _loadPreferences();
                        _fetchWeather();
                      });
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
