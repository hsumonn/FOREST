import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:location/location.dart';
import 'package:umbrella/registration_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String weatherDescription = '';
  bool isDayTime = true;
  List<double> rainfallData = [];
  double rainProbability = 0.0;

  void updateWeather(String newDescription, bool dayTime, List<double> newRainfallData, double newRainProbability) {
    setState(() {
      weatherDescription = newDescription;
      isDayTime = dayTime;
      rainfallData = newRainfallData;
      rainProbability = newRainProbability;
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
      return isDayTime ? [Colors.purpleAccent, Colors.blue] : [Colors.black45, Colors.white24];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getGradientColors(),
          ),
        ),
        child: DetailMenu(onWeatherChange: updateWeather),
      ),
    );
  }
}

class WeatherData {
  final String description;
  final String icon;
  final double temperature;
  final String cityName;
  final List<double> rainfallData;
  final double rainProbability;

  WeatherData({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.cityName,
    required this.rainfallData,
    required this.rainProbability,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    List<double> rainfallData = [];

    if (json.containsKey('rain') && json['rain'].containsKey('1h')) {
      double rain1h = json['rain']['1h'].toDouble();
      rainfallData.add(rain1h);
    }

    double rainProbability = 0.0;
    if (json.containsKey('pop')) {
      rainProbability = json['pop'].toDouble() * 100;
    }

    return WeatherData(
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: json['main']['temp'],
      cityName: json['name'],
      rainfallData: rainfallData,
      rainProbability: rainProbability,
    );
  }
}

class DetailMenu extends StatefulWidget {
  final Function(String weatherDescription, bool isDayTime, List<double> rainfallData, double rainProbability) onWeatherChange;

  const DetailMenu({required this.onWeatherChange, super.key});

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
    const apiKey = 'eed754aeda9ee52d698e40be18de7b9c';
    Location location = Location();
    LocationData locData = await location.getLocation();

    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${locData.latitude}&lon=${locData.longitude}&units=metric&appid=$apiKey&country=jp';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(json.decode(response.body));

      bool isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;
      widget.onWeatherChange(weatherData.description, isDayTime, weatherData.rainfallData, weatherData.rainProbability);

      return weatherData;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  String getIconUrl(String description, bool isDayTime, int hour) {
    if (description.contains('rain')) {
      if (description.contains('light')) {
        return isDayTime ? 'images/light_rain_noon.png' : 'images/light_rain_night.png';
      } else {
        return 'images/heavy_rain.png';
      }
    } else if (description.contains('clear')) {
      return isDayTime ? 'images/sunny.png' : 'images/clearnight.png';
    } else if (description.contains('haze')) {
      return isDayTime ? 'images/cloudy.png' : 'images/clearnight.png';
    } else if (description.contains('thunderstorm')) {
      return 'images/thunder.png';
    } else {
      return 'images/sunny.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> cityToKanji = {
      'Osaka': '大阪',
      'Tokyo': '東京',
      'Kyoto': '京都',
      'Mountain View': '中崎町',
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
                              MaterialPageRoute(builder: (context) => const RegistrationMenu()),
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
                        getIconUrl(weatherDescription, isDayTime, DateTime.now().hour),
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
                      const SizedBox(height: 5),
                      Text(
                        'Rain Probability: ${snapshot.data!.rainProbability.toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 70),
                      CustomPaint(
                        size: const Size(double.infinity, 2),
                        painter: StraightLinePainter(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 150,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 12,
                            controller: PageController(initialPage: 2, viewportFraction: 0.2),
                            itemBuilder: (context, index) {
                              DateTime now = DateTime.now();
                              int displayHour = (now.hour + index) % 24; // Ensure hour is within 0-23 range
                              bool futureIsDayTime = displayHour > 6 && displayHour < 18;
                              String hourLabel = '${displayHour.toString().padLeft(2, '0')}:00';
                              return Column(
                                children: [
                                  Text(
                                    hourLabel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Image.asset(
                                    getIconUrl(weatherDescription, futureIsDayTime, displayHour),
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(snapshot.data!.temperature - index).toInt()}°C',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (snapshot.data!.rainProbability > 0)
                                    Text(
                                      '${snapshot.data!.rainProbability.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 10,
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
                        size: const Size(double.infinity, 2),
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