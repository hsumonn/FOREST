//sample cord
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Text Display',
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
      appBar: AppBar(

        //ここにタイトル
        title: Image.asset(
          'images/logo_test.png',
          width: 300,  // 幅を指定
          height: 50,  // 高さを指定
          fit: BoxFit.contain,  // 画像のフィット方法を指定
          SizedBox(width: 8), // 画像とテキストの間にスペースを追加
        )
      ),

      body: Center(
        child: Text(

          //ここに中央表示のテキスト
          'test text',                      //テキスト内容
          style: TextStyle(fontSize: 24),   //フォントの詳細（サイズとか）
        ),

      ),
    );
  }
}