import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:umbrella/registration_menu.dart';
import 'dart:convert';
import 'caution_menu.dart';

//雨の詳細をグローバル変数に。
String globalCurrentDiscription = '';
String globalDestinationDiscription = '';
String globalKanjiCurrentLocation = '';
String globalKanjiDestination = '';

//雨が降るかのジャッジ
bool globalCurrentjudge = false;
bool globalDestinationjudge = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final parts = response.payload!.split('|');
          print('Notification payload received: $parts');
          if (parts.length >= 2) {
            final title = parts[0];
            final message = parts[1];
            Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
              builder: (context) => CautionMenu(title: title, payload: message),
            ));
          } else {
            print("Invalid payload format");
          }
        }
      });

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Weather Notification App',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Weather Notification Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String _currentLocation = '';
  String _destination = '';
  String weather_current = '';
  String weather_destination = '';
  List<int> _selectedDays = [];
  final String apiKey = 'cf3c7bba4d5b23a7aed18c0a3c624324';

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



  @override
  void initState() {
    super.initState();
    _initializePreferencesAndCheckWeather();
  }

  Future<void> _initializePreferencesAndCheckWeather() async {
    await _loadPreferences();
    await _checkWeatherAndNotify();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('currentLocation') ?? '';
      _destination = prefs.getString('destination') ?? '';
      _selectedDays = prefs.getStringList('selectedDays')
          ?.map((e) => int.parse(e))
          .toList() ??
          [];
    });
    print('Preferences loaded: $_currentLocation, $_destination, $_selectedDays');
  }

  Future<void> _checkWeatherAndNotify() async {
    final now = DateTime.now();
    final nowNum = now.weekday;

    /*if (_currentLocation.isEmpty) {
      print('Current location is empty, skipping weather check.');
      return;
    }*/

    final urlCurrent =
        'https://api.openweathermap.org/data/2.5/weather?q=$_currentLocation&appid=$apiKey&lang=ja';

    final urlDistination =
        'https://api.openweathermap.org/data/2.5/weather?q=$_destination&appid=$apiKey&lang=ja';

    if (!(_selectedDays.contains(nowNum))) {
      try {
        print('Fetching weather data for $_currentLocation from: $urlCurrent');
        final responseCurrent = await http.get(Uri.parse(urlCurrent));
        print('API response status: ${responseCurrent.statusCode}');
        if (responseCurrent.statusCode == 200) {
          final dataCurrent = json.decode(responseCurrent.body);
          weather_current = dataCurrent['weather'][0]['main'];
          String cityName = dataCurrent['name'];
          if (cityToKanji.containsKey(cityName)) {
            globalKanjiCurrentLocation = cityToKanji[cityName]!;
          }
          globalCurrentDiscription = dataCurrent['weather'][0]['description'];
          print('Weather data received: $weather_current');
          if (weather_current == 'Rain') {
            globalCurrentjudge = true;
          }
          /*setState(() {
            _currentLocation = data_current['name']; // Example update
          });*/
        } else {
          print(
              'Failed to load weather data: ${responseCurrent.reasonPhrase}');
        }
        //distinationの天気を取得する
        print('Fetching weather data for $_destination from: $urlDistination');
        final responseDistination = await http.get(Uri.parse(urlDistination));
        print('API response status: ${responseDistination.statusCode}');
        if (responseDistination.statusCode == 200) {
          final dataDestination = json.decode(responseDistination.body);
          weather_destination = dataDestination['weather'][0]['main'];
          String cityName = dataDestination['name'];
          if (cityToKanji.containsKey(cityName)) {
            globalKanjiDestination = cityToKanji[cityName]!;
          }
          globalDestinationDiscription = dataDestination['weather'][0]['description'];
          print('Weather data received: $weather_destination');
          if (weather_destination == 'Rain') {
            globalDestinationjudge = true;
          }
          /*setState(() {
            _destination = data_destination['name']; // Example update
          });*/
          print(globalDestinationjudge);

          //どちらかが雨が降る場合
          if (globalDestinationjudge || globalCurrentjudge) {
            while(true) {
              DateTime nowTime = DateTime.now();
              if (globalHour == null && globalminute == null || globalHour == 0) {
                if (nowTime.hour == 7 && nowTime.minute == 0) {
                  if (globalDestinationjudge && globalCurrentjudge) {
                    showLocalNotification(
                        '天気予報：',
                        '$_currentLocationと$_destination で雨が降る予定があります🌧️');
                  } else {
                    if (globalCurrentjudge) {
                      showLocalNotification(
                          '天気予報：', '$_currentLocation で雨が降る予定があります。🌧️');
                    } else {
                      showLocalNotification(
                          '天気予報：', '$_destination で雨が降る予定があります。🌧️');
                    }
                    break;
                  }
                }
              }
              if (globalHour != 0) {
                if (nowTime.hour == globalHour && nowTime.minute == globalminuteTmp) {
                  if (globalDestinationjudge && globalCurrentjudge) {
                    showLocalNotification(
                        '天気予報：',
                        '$_currentLocationと$_destination で雨が降る予定があります🌧️');
                  } else {
                    if (globalCurrentjudge) {
                      showLocalNotification(
                          '天気予報：', '$_currentLocation で雨が降る予定があります。🌧️');
                    } else {
                      showLocalNotification(
                          '天気予報：', '$_destination で雨が降る予定があります。🌧️');
                    }
                    break;
                  }
                }
              }
            }
          }
        }else {
          print('Failed to load weather data: ${responseCurrent.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching weather data: $e');
      }
    }
  }

  void showLocalNotification(String title, String message) {
    const androidNotificationDetail = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosNotificationDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificationDetail,
      android: androidNotificationDetail,
    );

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
      payload: '$title|$message',
    );
    print('Notification shown: $title - $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current Location: $_currentLocation'),
            Text('Destination: $_destination'),
            Text('Selected Days: $_selectedDays'),
          ],
        ),
      ),
    );
  }
}