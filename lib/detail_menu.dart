import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:umbrella/registration_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            //colors: <Color>[Colors.grey, Colors.lightBlueAccent],
            colors: <Color>[Colors.lightBlueAccent, Colors.white],
          ),
        ),
        child: const DetailMenu(),
      ),
    );
  }
}

class WeatherData {
  final String description;
  final String icon;
  final double temperature;
  final String cityName;

  WeatherData({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: json['main']['temp'],
      cityName: json['name'],
    );
  }
}

class DetailMenu extends StatefulWidget {
  const DetailMenu({super.key});

  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  late Future<WeatherData> futureWeatherData;

  @override
  void initState() {
    super.initState();
    futureWeatherData = fetchWeatherData();
  }

  Future<WeatherData> fetchWeatherData() async {
    const apiKey = 'eed754aeda9ee52d698e40be18de7b9c'; // Replace with your OpenWeatherMap API key

    Location location = Location();
    LocationData locData = await location.getLocation();

    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageNames = [
      'light_rain_noon.png',
      'heavy_rain.png',
      'light_rain_night.png',
      'sunny.png',
      'light_rain_noon.png',
      'thunder.png',
      'heavy_rain.png',
      'clearnight.png',
      'cloudy.png',
      'sunny.png',
      'sunny.png',
      'sunny.png'
    ];

    final Map<String, String> cityToKanji = {
      'Osaka': '大阪',
      'Tokyo': '東京',
      'Kyoto': '京都',
      'Mountain View': '中崎町',
      // Add more city mappings as needed
    };

    return FutureBuilder<WeatherData>(
      future: futureWeatherData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String cityName = snapshot.data!.cityName;
          if (cityToKanji.containsKey(cityName)) {
            cityName = cityToKanji[cityName]!;
          }

          String weatherDescription = snapshot.data!.description.toLowerCase();
          bool isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;
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

          return SizedBox(
            width: 340,
            height: 740,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'images/registration.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistrationMenu()), // Navigate to RegistrationMenu.dart
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        iconUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${snapshot.data!.temperature.toInt()}°C',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 70),
                      CustomPaint(
                        size: const Size(double.infinity, 3),
                        painter: StraightLinePainter(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 120,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageNames.length,
                            controller: PageController(initialPage: 2, viewportFraction: 0.2),
                            itemBuilder: (context, index) {
                              DateTime now = DateTime.now();
                              String hourLabel = DateTime(now.year, now.month, now.day, now.hour + index + 1).hour.toString()+ ':00';
                              return Column(
                                children: [
                                  Text(
                                    hourLabel,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Image.asset(
                                    'images/${imageNames[index]}',
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(snapshot.data!.temperature - index).toInt()} °C',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      CustomPaint(
                        size: const Size(double.infinity, 3),
                        painter: StraightLinePainter(),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomPaint(
                            painter: GraphPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class StraightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.1);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}