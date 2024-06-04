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
            width: 100,  // 幅を指定
            height: 50,  // 高さを指定
            //fit: BoxFit.contain,  // 画像のフィット方法を指定
          )
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

          Text('目的地登録',),

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