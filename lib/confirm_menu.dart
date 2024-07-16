import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      title: 'Flutter Demo',                                                    //ここのコードはアプリのタイトル名の指定をしている
      home: MyHomePage(title: 'Flutter Demo Home Page'),                        //ここのコードはアプリのメイン画面を構築するためのウィジェットです
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
  get styleInformation => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ローカルプッシュ通知 テスト',                                          //ここのコードはアプリのタイトル名
      home: Scaffold(
        appBar: AppBar(
          title: const Text('通知テスト'),                                        //ここのコードは左上に出てくる物です
        ),
        body: Center(
          child: FilledButton(
            onPressed: _onPressed,
            child: const Text('通知ボタン'),                                      //ここのコードは通知を出すボタン
          ),
        ),
      ),
    );
  }

        Future<void> _onPressed() async {
          const String apiKey = 'eed754aeda9ee52d698e40be18de7b9c';
          const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=35.6895&lon=139.6917&appid=$apiKey';

          final response = await http.get(Uri.parse(apiUrl));
          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final String weatherDescription = data['weather'][0]['description'];
            final bool isRainy = weatherDescription.toLowerCase().contains('rain');

            showLocalNotification('今日のXX時に', '雨が降ります');                   //通知の内容を決めれる場所（雨関係なしに出てくる通知）

            if (isRainy) {
              // 通知を表示する処理を実装
              // 例: flutter_local_notificationsパッケージを使って通知を表示
              showLocalNotification('今日のXX時に', '雨が降ります');                 //通知の内容を決めれる場所　（雨の時しか出てこない通知）

            }
          } else {
              if (kDebugMode) {
                print('天気情報の取得に失敗しました。');                              //ここは通知が出ない時に出てくる
              }
            }
        }

  void showLocalNotification(String title, String message) {
    const androidNotificationDetail = AndroidNotificationDetails(
      'channel_id', // チャンネルID
      'channel_name', // チャンネル名

      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/light_rain_noon', // アイコンの設定

      //color: Color.fromARGB(255, 0, 0, 0), // 色を指定
      // icon:  '@images/light_rain_noon'
      // largeIcon: FilePathAndroidBitmap('@images/light_rain_noon'),
      // styleInformation: styleInformation,
    );
//

    const iosNotificationDetail = DarwinNotificationDetails();                  //iOSの通知設定をカスタマイズするために使用されます
    const notificationDetails = NotificationDetails(                            //iOSとAndroidの両方のプラットフォームで共通の通知設定を指定しています
      iOS: iosNotificationDetail,
      android: androidNotificationDetail,
    );
    FlutterLocalNotificationsPlugin().show(0, title, message, notificationDetails);//指定された通知設定で通知を表示するメソッドです
  }

}
