import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
              child: Marquee(
                text: '本日、大阪府、○○県で、雨の予定あり。 傘をお忘れないように！   ', // 流れるテキスト
                style: const TextStyle(color: Colors.white, fontSize: 33,decoration: TextDecoration.none,), // テキストのスタイル
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
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '雨', // "Rain"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
// Change this to your desired color
                      ),
                    ),
                    TextSpan(
                      text: 'の', // "Rain"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        color: Colors.white, // Change this to your desired color
                      ),
                    ),
                    TextSpan(
                      text: '強度', // "Intensity:"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white70, // Change this to your desired color
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
                      ),
                    ),
                    TextSpan(
                      text: '：', // "Intensity:"
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 29,
                        color: Colors.white, // Change this to your desired color
                        fontWeight: FontWeight.bold, // Change this to your desired font weight
                      ),
                    ),
                    TextSpan(
                      text: '強', // "Intensity:"
                      style: TextStyle(
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
                  fontWeight: FontWeight.bold, // Change this to your desired font weight
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
                '-----------------',
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