import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterLocalNotificationsPlugin()
    ..resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission()
    ..initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ローカルプッシュ通知 テスト',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('通知テスト'),
        ),
        body: Center(
          child: FilledButton(
            onPressed: _onPressed,
            child: const Text('通知ボタン'),
          ),
        ),
      ),
    );
  }

  void _onPressed() {
    showLocalNotification('今日のXX時に', '雨が降ります');
  }

  void showLocalNotification(String title, String message) {
    const androidNotificationDetail = AndroidNotificationDetails(
        'channel_id', // channel Id
        'channel_name' // channel Name
    );
    const iosNotificationDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificationDetail,
      android: androidNotificationDetail,
    );
    FlutterLocalNotificationsPlugin()
        .show(0, title, message, notificationDetails);
  }
}