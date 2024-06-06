import 'package:flutter/material.dart';

void main(){
  runApp(const Caution());
}

class Caution extends StatelessWidget {
  const Caution({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //int _counter = 0;

  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/

  /*Widget _myImg(){
    return SizedBox(
      width: double.infinity,
      child: Image.asset('images/rain_house.gif',),
    );
  }*/

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'images/rain_house.gif'),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(
        child: Container(
          //margin: const EdgeInsets.all(48),
          margin: const EdgeInsets.only(
            left: 20,
            top: 400,
            right: 20,
            bottom: 300,
          ),
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: const Center(child: Text(
            '\t\t\t\t\t\t\t\t\t\t\t\t\t☔\n⚠ 本日、大阪府～○○県との間で大雨振る予定あり。\n大きい傘を持っていきましょう.',
            style: TextStyle(
                decoration: TextDecoration.none,fontSize: 18,color: Colors.white70,
            ),
            ),
          ),
        ),
      ),
    );
        /*child: const SizedBox(
          height: double.infinity,
          width: 180,
          child: Text(
              'ホラーゲームとかに使えそう',
            style: TextStyle(
                backgroundColor:Colors.black,
                color: Colors.white,
                fontSize: 25,
            ),
          ),
        ),*/
  }
}
