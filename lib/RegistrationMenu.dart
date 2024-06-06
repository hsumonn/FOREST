//sample cord
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  //右上のデバッグ帯を削除する
      title: 'Registration menu',
      theme: ThemeData(
      primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //ヘッダー
      appBar: AppBar(
        //ここにタイトル
          title: Image.asset(
            './images/logo_test.png',
            width: 100,  // 幅を指定
            height: 50,  // 高さを指定
            //fit: BoxFit.contain,  // 画像のフィット方法を指定
          )
      ),

      //ボディ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

          Text(
            '登録画面',
            style: TextStyle(
              fontSize: 30, // サイズを変更
            ),
          ),

            TextFormField(
              decoration: InputDecoration(
                labelText: '現在位置',
              ),
            ),

            TextFormField(
              decoration: InputDecoration(
                labelText: '目的地',
              ),

            ),
          ],
        ),
      ),

    );
  }
}