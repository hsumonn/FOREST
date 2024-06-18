//sample cord
import 'package:flutter/material.dart';


void main() {
  runApp(const RegistrationMenu());
  runApp(MyApp());
}

class RegistrationMenu extends StatelessWidget {
  const RegistrationMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      //home: const MyHomePage(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  //右上のデバッグ帯を削除する
      title: 'touroku gamen', // アプリ全体のタイトル
      theme: ThemeData(), // アプリ全体のテーマ
      home: MyHomePage(), // 最初に表示するウィジェット
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownExample(),
      ),
    );
  }
}

class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  //_DropdownExampleState({super.key});
  //const MyHomePage({super.key});

  // 選択されたラジオボタンの値を保持する変数
  int _selectedValue = 1;

  //ラジオボタンの文字色を変更する
  final Color BC = Colors.white;                   //背景色(background color)
  //final TextStyle TC = TextStyle(color: Colors.blueAccent);  //文字色(text color)


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

          //一番上に表示するタイトルテキスト
          //Title text to be displayed at the top
          const Text(
            '登録画面',
            style: TextStyle(
              fontSize: 30, // サイズを変更
              color: Colors.white
              //backgroundColor: Colors.blueAccent,  //背景色
            ),
          ),

          //必要情報入力部分
          //Required information input section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                TextFormField(
                    decoration: const InputDecoration(
                      hintText: "現在位置",   //テキスト内容
                      hintStyle: TextStyle(color: Colors.blueAccent),   //テキストカラー
                      // labelText: '現在位置', //上部にテキストを表示するならこっち
                      fillColor: Colors.white,  //背景色
                      filled: true,

                    ),
                  ),

                SizedBox(height: 16.0), // 2つのテキストフィールド間にスペースを追加

                TextFormField(
                    decoration: const InputDecoration(
                      hintText: "目的地",
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),

                SizedBox(height: 16.0), // スペース

                //曜日選択(ラジオボタン)
                //Day of the week selection (radio button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[

                    Container(
                      color: BC, // 背景色を設定
                      //color: Colors.blueAccent, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 1,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('日',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 2,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('月',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 3,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('火',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 4,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('水',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 5,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('木',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 6,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('金',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                    Container(
                      color: BC, // 背景色を設定
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 7,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          const Text('土',style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 16.0), // スペース

                //送信ボタン
                ElevatedButton(
                  //ボタンを押した時の処理
                  onPressed: () {},
                  child: Text('確認'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                  ),
                )

                ],
              ),
          ),

          ],
        ),
      ),

    );
  }
}