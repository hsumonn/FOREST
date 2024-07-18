import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:umbrella/confirm_menu.dart';
import 'main_menu.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const Caution());
}

class Caution extends StatelessWidget {
  const Caution({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CautionMenu(title: 'Flutter Demo Home Page', payload: 'Hello',),
    );
  }
}

class CautionMenu extends StatefulWidget {

  final String title;
  final String payload;

  const CautionMenu({super.key, required this.title, required this.payload});

  @override
  State<CautionMenu> createState() => _CautionMenuState();
}

class _CautionMenuState extends State<CautionMenu> {
  String _currentLocation = '';
  String _destination = '';
  String strongrain = '';
  String weatherForecast = '';

  bool power = false;

  @override
  void initState() {
    super.initState();
    _initializePreferencesAndCheckWeather();
    //5秒後に遷移
    Timer(const Duration(seconds: 10,),() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainMenu()),
      );
    });
  }

  Future<void> _initializePreferencesAndCheckWeather() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('currentLocation') ?? '';
      _destination = prefs.getString('destination') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {

    /*confirmで雨が降る場合降らない場合のジャッジをグローバル変数に入れている。
    そのtrueかfalseで、どこどこで降るかの表示を変える
     */
    if(globalCurrentjudge && globalDestinationjudge) {
      weatherForecast = '⚠本日、$_currentLocationと$_destinationで、雨の予定あり。 傘をお忘れないように！　　　　';
    }else if (globalCurrentjudge) {
      weatherForecast = '⚠本日、$_currentLocationで、雨の予定あり。 傘をお忘れないように！　　　　';
    }else {
      weatherForecast = '⚠本日、$_destinationで、雨の予定あり。 傘をお忘れないように！　　　　';

    }
    //descriptionのどちらかが強と入ってたら、強度強いにし、弱いが含まれない場合中、それ以外弱いが一個も含まれないの逆の時弱
    if(globalCurrentDiscription.isNotEmpty || globalDestinationDiscription.isNotEmpty) {
      if(globalDestinationDiscription.contains('強') || globalCurrentDiscription.contains('強')) {
        strongrain = '強';
        power = true;
      }else if(!(globalDestinationDiscription.contains('弱') || globalCurrentDiscription.contains('弱'))) {
        //これは弱がどちらに含まれていると、弱になってしまうので、中、弱でも弱になってしまうから、強いも弱いも含まれない場合、中にして、弱いが含まれないのelseで弱いを設定する。
        strongrain = '中';
      }else {
        strongrain = '弱';
      }
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/rain-21.gif.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              margin: const EdgeInsets.only(
                left: 5,
                top: 80,
                right: 5,
                bottom: 611,
              ),
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Marquee(
                  text: weatherForecast, // 流れるテキスト
                  style: const TextStyle(color: Colors.white, fontSize: 39,decoration: TextDecoration.none,), // テキストのスタイル
                  scrollAxis: Axis.horizontal, // テキストの流れる方向
                  crossAxisAlignment: CrossAxisAlignment.start, // テキストの縦方向の配置
                  blankSpace: 20.0, // テキストがループするときの余白
                  velocity: 125.0, // テキストの速度
                  pauseAfterRound: const Duration(seconds: 1), // ループ後の一時停止時間
                  startPadding: 10.0, // テキストの開始位置の余白
                  accelerationDuration: const Duration(seconds: 1), // 加速時間
                  accelerationCurve: Curves.linear, // 加速カーブ
                  decelerationDuration: const Duration(milliseconds: 500), // 減速時間
                  decelerationCurve: Curves.easeOut, // 減速カーブ
                ),
              ),
              /*child: DefaultTextStyle(
                style: const TextStyle(decoration: TextDecoration.none, fontSize: 32),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText('\n本日、大阪と○○県で、雨の予定あり。'),
                  ],
                ),
              ),*/
            ),
          ),
          /*const Positioned(
            top: 95, // アニメーションテキストの位置より上に固定テキストを表示
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '⚠',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 35,
                ),
              ),
            ),
          ),*/
          const Positioned(
            top: 185, // アニメーションテキストの位置より上に固定テキストを表示
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '---------------------------',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Positioned(
            top: 200, // アニメーションテキストの位置より上に固定テキストを表示
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '雨', // "Rain"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
// Change this to your desired color
                      ),
                    ),
                    const TextSpan(
                      text: 'の', // "Rain"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        color: Colors.white, // Change this to your desired color
                      ),
                    ),
                    const TextSpan(
                      text: '強度', // "Intensity:"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white70, // Change this to your desired color
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
                      ),
                    ),
                    const TextSpan(
                      text: '：', // "Intensity:"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white, // Change this to your desired color
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
                      ),
                    ),
                    TextSpan(
                      text: strongrain, // "Intensity:"
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30,
                        color: Colors.redAccent, // Change this to your desired color
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),



          Positioned(
            //left: 5,
            bottom: 45,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/teeutyan.png'), // 画像のパスを指定
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 205,
            child: Container(
              width: 245,
              height: 295, // 幅と高さの比率を指
              decoration: BoxDecoration(
                image: const DecorationImage(
                    image: AssetImage('images/message.png'), // 画像のパスを指定
                    fit: BoxFit.contain
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          if(power)
            Positioned(
              left: 170,
              bottom: 298,
              child: Container(
                width: 80,
                height: 100, // 幅と高さの比率を指
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('images/heyher.jpg'), // 画像のパスを指定
                      fit: BoxFit.contain
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          if(power)
            Positioned(
              left: 40,
              bottom: 285,
              child: Container(
                width: 160,
                height: 120, // 幅と高さの比率を指
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('images/umbrella_big2.png'), // 画像のパスを指定
                      fit: BoxFit.contain
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          if(!power)
            Positioned(
              left: 70,
              bottom: 285,
              child: Container(
                width: 160,
                height: 120, // 幅と高さの比率を指
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('images/umbrella_small.png'), // 画像のパスを指定
                      fit: BoxFit.contain
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          const Positioned(
            bottom: 420, // アニメーションテキストの位置より上に固定テキストを表示
            left: 82,
            //right: 0,
            child: Center(
              child: Text(
                'おすすめアイテム',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 400, // アニメーションテキストの位置より上に固定テキストを表示
            left: 58,
            //right: 0,
            child: Center(
              child: Text(
                '------------------',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 18,
                  color: Colors.black26,
                  //fontWeight: FontWeight.bold, // Change this to your desired font weight
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}