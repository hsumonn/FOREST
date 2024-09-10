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
          child: DetailMenu(onWeatherChange: updateWeather, location: ''),
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
  final double rainProbability;
  final List<DailyForecast> dailyForecasts;
  final List<HourlyForecast> hourlyForecasts;
  WeatherData({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.cityName,
    required this.rainProbability,
    required this.dailyForecasts,
    required this.hourlyForecasts, // Add this line

  });

  factory WeatherData.fromJson(Map<String, dynamic> currentData, List<dynamic> forecastData, List<dynamic> hourlyData) {
    List<DailyForecast> dailyForecasts = [];
    List<HourlyForecast> hourlyForecasts = [];

    // Process current weather data
    String description = currentData['weather'][0]['description'] ?? '';
    String icon = currentData['weather'][0]['icon'] ?? '';
    double temperature = (currentData['main']['temp'] as num?)?.toDouble() ?? 0.0;
    String cityName = currentData['name'] ?? '';
    double rainProbability = (currentData['rain']?['1h'] as num?)?.toDouble() ?? 0.0; // or another relevant field

    // Process forecast data for 5 days
    Map<String, DailyForecast> forecastMap = {};

    for (var item in forecastData) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String day = '${dt.day + 1}/${dt.month}';

      if (!forecastMap.containsKey(day)) {
        DailyForecast forecast = DailyForecast(
          day: day,
          rainProbability: (item['pop'] as num?)?.toDouble() ?? 0.0,
          temperature: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
          description: item['weather'][0]['description'] ?? '',
          icon: item['weather'][0]['icon'] ?? '',
        );
        forecastMap[day] = forecast;
      }

      if (forecastMap.length >= 5) break; // Limit to 5 days
    }

    dailyForecasts = forecastMap.values.toList();

    // Process hourly forecast data
    for (var i = 0; i < hourlyData.length; i++) {
      var item = hourlyData[i];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      HourlyForecast forecast = HourlyForecast(
        time: dt,
        temperature: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
        description: item['weather'][0]['description'] ?? '',
        icon: item['weather'][0]['icon'] ?? '',
        rainProbability: (item['pop'] as num?)?.toDouble() ?? 0.0, // Get rain probability
      );
      hourlyForecasts.add(forecast);

      if (i < hourlyData.length - 1) {
        // Interpolate between this forecast and the next one
        var nextItem = hourlyData[i + 1];
        double nextTemp = (nextItem['main']['temp'] as num?)?.toDouble() ?? 0.0;
        for (int j = 1; j <= 2; j++) {
          DateTime intermediateTime = dt.add(Duration(hours: j));
          double interpolatedTemp = forecast.temperature + (nextTemp - forecast.temperature) * (j / 3);
          HourlyForecast interpolatedForecast = HourlyForecast(
            time: intermediateTime,
            temperature: interpolatedTemp,
            description: forecast.description,
            icon: forecast.icon,
            rainProbability: forecast.rainProbability, // Carry rain probability to interpolated forecasts
          );
          hourlyForecasts.add(interpolatedForecast);
        }
      }
    }

    return WeatherData(
      description: description,
      icon: icon,
      temperature: temperature,
      rainProbability: rainProbability, // Use the calculated rainProbability
      cityName: cityName,
      dailyForecasts: dailyForecasts,
      hourlyForecasts: hourlyForecasts,
    );
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
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String description;
  final String icon;
  final double rainProbability;

  HourlyForecast({
    required this.time,
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
    final openWeatherMapCurrentUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';
    final openWeatherMapForecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=cf3c7bba4d5b23a7aed18c0a3c624324';

    final responseCurrent = await http.get(Uri.parse(openWeatherMapCurrentUrl));
    final responseForecast = await http.get(Uri.parse(openWeatherMapForecastUrl));

    if (responseCurrent.statusCode == 200 && responseForecast.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(
        json.decode(responseCurrent.body),
        json.decode(responseForecast.body)['list'],
        json.decode(responseForecast.body)['list'], // Use the same data for hourly
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
                width: 800,
                height: 1000,
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
                      padding: const EdgeInsets.only(top: 50, left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Image.asset(
                            'images/modoru1111.png', // Replace with your icon image path
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
                      padding: const EdgeInsets.only(top: 50, right: 20),
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
                      padding: const EdgeInsets.only(top: 110),
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
                            snapshot.data!.getIconUrl(weatherDescription, isDayTime, DateTime.now().hour),
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
                          Text(
                            'Rain Probability:${(snapshot.data!.rainProbability * 100).toInt()}%', // This line is fine
                            style: const TextStyle(fontSize: 18, color: Colors.white),
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
                              height: 150,
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 12,
                                controller: PageController(initialPage: 2, viewportFraction: 0.2),
                                itemBuilder: (context, index) {
                                  HourlyForecast forecast = snapshot.data!.hourlyForecasts[index];
                                  String hourLabel = '${forecast.time.hour.toString().padLeft(1, '0')}:00';
                                  print('Hour: $hourLabel, Temp: ${forecast.temperature}, Description: ${forecast.description}');
                                  return Container(
                                    color: Colors.grey.withOpacity(0.6),
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
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
                                          snapshot.data!.getIconUrl(forecast.description, isDayTime, forecast.time.hour),
                                          width: 75,
                                          height: 65,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${forecast.temperature.toInt()}°C',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomPaint(
                            size: const Size(double.infinity, 3),
                            painter: StraightLinePainter(),
                          ),
                          const SizedBox(height: 30),

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
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dailyForecasts.map((forecast) {
            print('Forecast: ${forecast.day}, ${forecast.temperature}, ${forecast.description}');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.1),
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
    return Icons.wb_sunny;
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
              const SizedBox(width: 24),

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
      color: Colors.blueGrey,
      size: 24,
    );
  } else {
    return const Icon(
      Icons.close,
      color: Colors.grey,
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