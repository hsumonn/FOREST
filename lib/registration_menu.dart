//sample cord
import 'package:flutter/material.dart';


void main() {
  runApp(const RegistrationMenu());
}

class RegistrationMenu extends StatelessWidget {
  const RegistrationMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  //右上のデバッグ帯を削除する
      title: 'Registration menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //ヘッダー
      appBar: AppBar(
        //ここにタイトル
          title: Image.asset(
            './images/logo_test.png', //ロゴ（仮置き）
            width: 100,  // 幅を指定
            height: 50,  // 高さを指定
            //fit: BoxFit.contain,  // 画像のフィット方法を指定
          )
      ),

      //ボディ
      body: Container(

        //背景画像を設定
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./images/weather_test.jpg'), //ここが画像
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            const Text(
              '登録画面',
              style: TextStyle(
                  fontSize: 30, // サイズを変更
                  color: Colors.white
                //backgroundColor: Colors.white,  //背景色
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "現在位置",
                      // labelText: '現在位置', //上部にテキストを表示するならこっち
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 16.0), // 2つのテキストフィールド間にスペースを追加

                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "目的地",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),

    );
  }
}