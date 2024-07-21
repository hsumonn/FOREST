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
      home: const CautionMenu(
        title: 'Flutter Demo Home Page',
        payload: 'Hello',
      ),
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
    Timer(
      const Duration(seconds: 10),
          () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainMenu()),
        );
      },
    );
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
    final size = MediaQuery.of(context).size;
    final double textSize = size.width * 0.12;
    final double textHeight = size.height * 0.07;

    if (globalCurrentjudge && globalDestinationjudge) {
      weatherForecast =
      '⚠本日、$_currentLocationと$_destinationで、雨の予定あり。 傘をお忘れないように！　　　　';
    } else if (globalCurrentjudge) {
      weatherForecast =
      '⚠本日、$_currentLocationで、雨の予定あり。 傘をお忘れないように！　　　　';
    } else {
      weatherForecast =
      '⚠本日、$_destinationで、雨の予定あり。 傘をお忘れないように！　　　　';
    }

    if (globalCurrentDiscription.isNotEmpty || globalDestinationDiscription.isNotEmpty) {
      if (globalDestinationDiscription.contains('強') || globalCurrentDiscription.contains('強')) {
        strongrain = '強';
        power = true;
      } else if (!(globalDestinationDiscription.contains('弱') || globalCurrentDiscription.contains('弱'))) {
        strongrain = '中';
      } else {
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
              margin: EdgeInsets.only(top: size.height * 0.09,left: size.width * 0.01,right: size.width * 0.01,bottom: size.height * 0.68),
              //padding: EdgeInsets.all(size.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(size.width * 0.07),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.04),
                child: Marquee(
                  text: weatherForecast,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    decoration: TextDecoration.none,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 20.0,
                  velocity: 125.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 185,
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
            top: size.height * 0.23,
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '雨',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: textHeight * 0.77,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'の',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: textHeight * 0.70,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '強度',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: textHeight * 0.77,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '：',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: textHeight * 0.72,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: strongrain,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: textHeight * 0.77,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            child: Container(
              width: size.width * 0.4,
              height: size.height * 0.2,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/teeutyan.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.07,
            bottom: size.height * 0.25,
            child: Container(
              width: size.width * 0.6,
              height: size.height * 0.3,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/message.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          if (power)
            Positioned(
              left: size.width * 0.40,
              bottom: size.height * 0.35,
              child: Container(
                width: size.width * 0.2,
                height: size.height * 0.12,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/heyher.jpg'),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          if (power)
            Positioned(
              left: size.width * 0.07,
              bottom: size.height * 0.33,
              child: Container(
                width: size.width * 0.4,
                height: size.height * 0.15,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/umbrella_big2.png'),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          if (!power)
            Positioned(
              left: size.width * 0.15,
              bottom: size.height * 0.33,
              child: Container(
                width: size.width * 0.4,
                height: size.height * 0.15,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/umbrella_small.png'),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
            ),
          Positioned(
            bottom: size.height * 0.48,
            left: size.width * 0.18,
            child: Center(
              child: Text(
                'おすすめアイテム',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: textHeight * 0.32,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.46,
            left: size.width * 0.1,
            child: Center(
              child: Text(
                '---------------------',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: textHeight * 0.30,
                  color: Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
