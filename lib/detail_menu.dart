import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registration_menu.dart';
import 'main_menu.dart';

void main() {
  runApp(const Detail());
}

class Detail extends StatelessWidget {
  const Detail({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const WeatherApp(),
      routes: {
        '/mainMenu': (context) => const MainMenu(),
        '/registrationMenu': (context) => const RegistrationMenu(),
      },
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
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
      return [Colors.lightBlueAccent, Colors.white];
    }
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
        child: Center(
          child: DetailMenu(onWeatherChange: updateWeather, location: '',),
        ),
      ),
    );
  }
}

class WeatherData {
  final String description;
  final String icon;
  final double temperature;
  final String cityName;
  final List<DailyForecast> dailyForecasts;

  WeatherData({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.cityName,
    required this.dailyForecasts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> currentData, List<dynamic> forecastData) {
    List<DailyForecast> dailyForecasts = [];

    // Process current weather data
    String description = currentData['weather'][0]['description'] ?? '';
    String icon = currentData['weather'][0]['icon'] ?? '';
    double temperature = (currentData['main']['temp'] as num?)?.toDouble() ?? 0.0;
    String cityName = currentData['name'] ?? '';

    // Process forecast data for 5 days
    Map<String, DailyForecast> forecastMap = {};

    for (var item in forecastData) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String day = '${dt.day + 1}/${dt.month}';

      if (!forecastMap.containsKey(day)) {
        DailyForecast forecast = DailyForecast(
          day: day,
          rainProbability: (item['rainProbability'] as num?)?.toDouble() ?? 0.0,
          temperature: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
          description: item['weather'][0]['description'] ?? '',
          icon: item['weather'][0]['icon'] ?? '',
        );
        forecastMap[day] = forecast;
      }

      if (forecastMap.length >= 5) break; // Limit to 5 days
    }

    dailyForecasts = forecastMap.values.toList();

    return WeatherData(
      description: description,
      icon: icon,
      temperature: temperature,
      cityName: cityName,
      dailyForecasts: dailyForecasts,
    );
  }
}

class DailyForecast {
  final String day;
  final double temperature;
  final String description;
  final String icon;
  final double rainProbability;

  DailyForecast({
    required this.day,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.rainProbability,
  });
}

class DetailMenu extends StatefulWidget {
  final void Function(String newDescription, bool dayTime, List<double> newRainfallData, double newRainProbability) onWeatherChange;
  final String location;

  const DetailMenu({super.key, required this.onWeatherChange, required this.location});

  @override
  _DetailMenuState createState() => _DetailMenuState();
}


class _DetailMenuState extends State<DetailMenu> {
  late Future<WeatherData> futureWeatherData;

  @override
  void initState() {
    super.initState();
    futureWeatherData = fetchWeatherData(widget.location);
  }

  Future<WeatherData> fetchWeatherData(String location) async {
    //const apiKeyOpenWeatherMap = 'cf3c7bba4d5b23a7aed18c0a3c624324'; // Replace with your OpenWeatherMap API key

    // Construct URLs for current and forecast weather data
    final openWeatherMapCurrentUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';
    final openWeatherMapForecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';

    final responseCurrent = await http.get(Uri.parse(openWeatherMapCurrentUrl));
    final responseForecast = await http.get(Uri.parse(openWeatherMapForecastUrl));

    if (responseCurrent.statusCode == 200 && responseForecast.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(
        json.decode(responseCurrent.body),
        json.decode(responseForecast.body)['list'],
      );
      return weatherData;
    } else {
      throw Exception('Failed to load weather data');
    }
  }


  List<Color> getGradientColors(String weatherDescription, bool isDayTime) {
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


  String getIconUrl(String description, bool isDayTime, int hour) {
    if (description.contains('rain')) {
      return 'images/heavy_rain.png';
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
      'Tokyo': '東京',
      'Kyoto': '京都',
      'Osaka': '大阪',
      'Nagoya': '名古屋',
      'Sapporo': '札幌',
      'Fukuoka': '福岡',
      'Hiroshima': '広島',
      'Hokkaido': '北海道',
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
          bool isDayTime = DateTime
              .now()
              .hour > 6 && DateTime
              .now()
              .hour < 18;


          return Scaffold(
              body:SizedBox(
                width: 500,
                height: 800,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: getGradientColors(weatherDescription, isDayTime),
                        ),
                      ),
                    ),
                    // New icon on the left side
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
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
                              MaterialPageRoute(
                                builder: (context) => const MainMenu(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Old icon on the right side
                    Padding(
                      padding: const EdgeInsets.only(top: 20, right: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'images/registration.png', // Replace with your icon image path
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegistrationMenu(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),

                    // Moving to the center of the screen
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
                          const SizedBox(height: 8),
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
                              height: 140,
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
                                        getIconUrl(weatherDescription, futureIsDayTime, displayHour),
                                        width: 75,
                                        height: 65,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(snapshot.data!.temperature - index).toInt()} °C',
                                        style: const TextStyle(
                                          fontSize: 16,
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
                          const SizedBox(height: 5),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: WeatherForecastTable(dailyForecasts: snapshot.data!.dailyForecasts),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class WeatherForecastTable extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;

  const WeatherForecastTable({super.key, required this.dailyForecasts});

  @override
  Widget build(BuildContext context) {
    print('Daily Forecasts Count: ${dailyForecasts.length}');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dailyForecasts.map((forecast) {
            print('Forecast: ${forecast.day}, ${forecast.temperature}, ${forecast.description}');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.1),
              child: WeatherForecastRow(
                day: forecast.day,
                rainProbability: forecast.rainProbability,
                description: forecast.description,
                temp: '${forecast.temperature.toInt()}°C',
                icon: getIconForDescription(forecast.description), // Pass IconData directly here
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

IconData getIconForDescription(String description) {
  if (description.contains('rain')) {
    return Icons.cloud;
  } else if (description.contains('clear')) {
    return Icons.wb_sunny;
  } else if (description.contains('haze') || description.contains('clouds')) {
    return Icons.wb_cloudy;
  } else if (description.contains('thunderstorm')) {
    return Icons.flash_on;
  } else {
    return Icons.wb_sunny;
  }
}


String getJapaneseDay(String day) {
  Map<int, String> dayMapping = {
    1: '月', // Monday
    2: '火', // Tuesday
    3: '水', // Wednesday
    4: '木', // Thursday
    5: '金', // Friday
    6: '土', // Saturday
    7: '日', // Sunday
  };

  List<String> parts = day.split('/');
  if (parts.length != 2) return day;

  DateTime date = DateTime(2024, int.parse(parts[1]), int.parse(parts[0]));
  int weekday = date.weekday;
  return dayMapping[weekday] ?? day;
}
IconData? getAdditionalIcon(String description) {
  switch (description.toLowerCase()) {
    case 'rainy':
      return Icons.umbrella;
    default:
      return null;
  }
}
IconData getWeatherIcon(String description) {
  switch (description.toLowerCase()) {
    case 'sunny':
      return Icons.wb_sunny
      ;
    case 'cloudy':
      return Icons.wb_cloudy;
    case 'rainy':
      return Icons.beach_access; // umbrella icon
    default:
      return Icons.wb_sunny;
  }
}

class WeatherForecastRow extends StatelessWidget {
  final String day;
  final String description;
  final String temp;
  final IconData icon;
  final double rainProbability;

  const WeatherForecastRow({super.key,
    required this.day,
    required this.description,
    required this.temp,
    required this.icon,
    required this.rainProbability,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 18),
              Text(
                getJapaneseDay(day),
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                day,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 23),
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 18),
              Text(
                temp,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 18),

              const Icon(Icons.umbrella, color: Colors.blue, size: 20), // This line is fine

              _buildRainProbabilityIcon(rainProbability),
              const SizedBox(width: 18),

              Text(
                '${(rainProbability * 100).toInt()}%', // This line is fine
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


Widget _buildRainProbabilityIcon(double rainProbability) {
  if (rainProbability > 0) {
    return const Icon(
      Icons.circle,
      color: Colors.blue,
      size: 24,
    );
  } else {
    return const Icon(
      Icons.close,
      color: Colors.red,
      size: 24,
    );
  }
}
class WeatherForecast extends StatelessWidget {
  final List<Map<String, String>> forecast;

  const WeatherForecast({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: forecast.map((dayForecast) {
        return WeatherForecastRow(
          day: dayForecast['day']!,
          description: dayForecast['description']!,
          temp: dayForecast['temp']!,
          rainProbability: (dayForecast['rainProbability'] as num).toDouble(),
          icon: getWeatherIcon(dayForecast['description']!),
        );
      }).toList(),
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
