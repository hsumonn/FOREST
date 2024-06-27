import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    print('Weather Description in updateWeather: $weatherDescription');
    print('Is Day Time: $isDayTime');
  }

  List<Color> getGradientColors() {
    print('Getting gradient colors for: $weatherDescription, Daytime: $isDayTime');
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
  final void Function(String newDescription, bool dayTime, List<double> newRainfallData, double newRainProbability) onWeatherChange;

  const DetailMenu({super.key, required this.onWeatherChange});

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
          print('Weather Description in FutureBuilder: $weatherDescription');

          String iconUrl;

          return SizedBox(
            width: 340,
            height: 740,
            child: Stack(
              children: [
                // New icon on the left side
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20), // Adjusted to left padding
                  child: Align(
                    alignment: Alignment.topLeft, // Align to the top left corner
                    child: IconButton(
                      icon: Image.asset(
                        'images/modoru.png', // Replace with your icon image path
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MainMenu()),
                        );
                      },
                    ),
                  ),
                ),

                // Existing icon on the right side
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
                            itemCount: 12,
                            controller: PageController(initialPage: 2, viewportFraction: 0.2),
                            itemBuilder: (context, index) {
                              DateTime now = DateTime.now();
                              int displayHour = (now.hour + index) % 24;
                              bool futureIsDayTime = displayHour > 6 && displayHour < 18;
                              String hourLabel = '${displayHour.toString().padLeft(2, '0')}:00';
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
                                    getIconUrl(weatherDescription, futureIsDayTime, displayHour),                                    width: 75,
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
                          child: WeatherForecastTable(),
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

class WeatherForecastTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            WeatherForecastRow(hour: '18:00', probability: '83%', temp: '23°', icon: Icons.cloud,),
            WeatherForecastRow(hour: '19:00', probability: '40%', temp: '23°', icon: Icons.cloud),
            WeatherForecastRow(hour: '20:00', probability: '34%', temp: '23°', icon: Icons.cloud),
            WeatherForecastRow(hour: '21:00', probability: '40%', temp: '23°', icon: Icons.cloud),
            WeatherForecastRow(hour: '22:00', probability: '51%', temp: '22°', icon: Icons.cloud),
            WeatherForecastRow(hour: '23:00', probability: '47%', temp: '22°', icon: Icons.cloud),
          ],
        ),
      ),
    );
  }
}

class WeatherForecastRow extends StatelessWidget {
  final String hour;
  final String probability;
  final String temp;
  final IconData icon;

  const WeatherForecastRow({
    required this.hour,
    required this.probability,
    required this.temp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(hour, style: TextStyle(color: Colors.white)),
        Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 5),
            Text(probability, style: TextStyle(color: Colors.white)),
          ],
        ),

        Text(temp, style: TextStyle(color: Colors.white)),
      ],
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
