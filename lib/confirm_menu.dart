import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'caution_menu.dart';
import 'registration_menu.dart';

//雨の詳細をグローバル変数に。
String globalCurrentDiscription = '';
String globalDestinationDiscription = '';

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
    final now_num = now.weekday;

    /*if (_currentLocation.isEmpty) {
      print('Current location is empty, skipping weather check.');
      return;
    }*/

    final url_current =
        'https://api.openweathermap.org/data/2.5/weather?q=$_currentLocation&appid=$apiKey&lang=ja';

    final url_distination =
        'https://api.openweathermap.org/data/2.5/weather?q=$_destination&appid=$apiKey&lang=ja';

    if (!(_selectedDays.contains(now_num))) {
      try {
        print('Fetching weather data for $_currentLocation from: $url_current');
        final response_current = await http.get(Uri.parse(url_current));
        print('API response status: ${response_current.statusCode}');
        if (response_current.statusCode == 200) {
          final data_current = json.decode(response_current.body);
          weather_current = data_current['weather'][0]['main'];
          globalCurrentDiscription = data_current['weather'][0]['description'];
          print('Weather data received: $weather_current');
          if (weather_current == 'Rain') {
            globalCurrentjudge = true;
          }
          /*setState(() {
            _currentLocation = data_current['name']; // Example update
          });*/
        } else {
          print(
              'Failed to load weather data: ${response_current.reasonPhrase}');
        }
        //distinationの天気を取得する
        print('Fetching weather data for $_destination from: $url_distination');
        final response_distination = await http.get(Uri.parse(url_distination));
        print('API response status: ${response_distination.statusCode}');
        if (response_distination.statusCode == 200) {
          final data_destination = json.decode(response_distination.body);
          weather_destination = data_destination['weather'][0]['main'];
          globalDestinationDiscription = data_destination['weather'][0]['description'];
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
              if(nowTime.hour == globalHour && nowTime.minute == globalminuteTmp) {
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
        }else {
          print('Failed to load weather data: ${response_current.reasonPhrase}');
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