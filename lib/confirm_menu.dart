import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();                                    //Flutterエンジンがウィジェットライブラリをバインドするのを確実にするためのもの
  FlutterLocalNotificationsPlugin()                                             //ローカル通知を管理するためのプラグインを作成します
    ..resolvePlatformSpecificImplementation()                               //Androidプラットフォームで通知の許可を要求します
        ?.requestNotificationsPermission()
    ..initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));                                                                         //通知の初期設定を行います。AndroidとiOSの設定をそれぞれ指定します。Androidでは、通知アイコンとして使用するリソースを指定します

  runApp(const MyApp());
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings();
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String s);
}

class InitializationSettings {
  const InitializationSettings({required android, required iOS});
}

class FlutterLocalNotificationsPlugin {
  resolvePlatformSpecificImplementation() {}

  initialize(InitializationSettings initializationSettings) {}

  void show(int i, String title, String message, NotificationDetails notificationDetails) {}
}

class AndroidFlutterLocalNotificationsPlugin {
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {                                          //デバッグバナーを非表示にするためのもの
    return const MaterialApp(
      debugShowCheckedModeBanner: false,                                        //右上のデバッグ帯を削除する
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {                                       //アプリ内で状態を持つウィジェットを作成するため
  const MyHomePage({super.key, required this.title});                           //コンストラクタ

  final String title;

  @override
  State<MyHomePage> createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,                                        //右上のデバッグ帯を削除する
      title: 'ローカルプッシュ通知 テスト',                                          //パラメータはアプリのタイトルを指定します
      home: Scaffold(                                                           //ウィジェットはアプリの基本的なレイアウトを提供します
        appBar: AppBar(                                                         //ウィジェットはアプリの上部に表示されるアプリバーを作成します
          title: const Text('Flutter Test'),
        ),
        body: Center(                                                           //中央に配置されたボタンが表示されます
          child: FilledButton(
            onPressed: _onPressed,
            child: const Text('通知ボタン'),                                      //押すボタン
          ),
        ),
      ),
    );
  }

  void _onPressed() {                                                           //通知の内容を決めるところ
    showLocalNotification('通知アラート',
        '本日XX時ごろに雨が降ります');
  }

  void showLocalNotification(String title, String message) {                    //指定されたタイトルとメッセージでローカルプッシュ通知を表示します
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

class NotificationDetails {
  const NotificationDetails({required DarwinNotificationDetails iOS, required AndroidNotificationDetails android});
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(String s, String i
      );
}