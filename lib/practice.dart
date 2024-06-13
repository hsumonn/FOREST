import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:marquee/marquee.dart';

void main() {
  runApp(const Caution());
}

class Caution extends StatelessWidget {
  const Caution({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/rain_house.gif'),
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
              child: Marquee(

                text: '本日、大阪と○○県で、雨の予定あり。', // 流れるテキスト
                style: const TextStyle(color: Colors.white, fontSize: 32,decoration: TextDecoration.none,), // テキストのスタイル
                scrollAxis: Axis.horizontal, // テキストの流れる方向
                crossAxisAlignment: CrossAxisAlignment.center, // テキストの縦方向の配置
                blankSpace: 20.0, // テキストがループするときの余白
                velocity: 100.0, // テキストの速度
                pauseAfterRound: const Duration(seconds: 1), // ループ後の一時停止時間
                startPadding: 10.0, // テキストの開始位置の余白
                accelerationDuration: const Duration(seconds: 1), // 加速時間
                accelerationCurve: Curves.linear, // 加速カーブ
                decelerationDuration: const Duration(milliseconds: 500), // 減速時間
                decelerationCurve: Curves.easeOut, // 減速カーブ
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
          const Positioned(
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
          ),

          Positioned(
            //left: 5,
            bottom: 15,
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
            left: 33,
            bottom: 175,
            child: Container(
              width: 222,
              height: 222, // 幅と高さの比率を指
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('images/message.png'), // 画像のパスを指定
                  fit: BoxFit.contain
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
