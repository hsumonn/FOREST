import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String _currentLocation = '';
  String _destination = '';
  List<int> _selectedDays = [];
  final List<String> _days = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('currentLocation') ?? '';
      _destination = prefs.getString('destination') ?? '';
      _selectedDays = prefs.getStringList('selectedDays')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('現在位置: $_currentLocation'),
            Text('目的地: $_destination'),
            Text('選択した曜日: ${_selectedDays.map((day) => _days[day - 1]).join(', ')}'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationMenu()),
                ).then((_) => _loadPreferences());
              },
              child: const Text('情報を登録'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationMenu extends StatefulWidget {
  const RegistrationMenu({super.key});

  @override
  _RegistrationMenuState createState() => _RegistrationMenuState();
}

class _RegistrationMenuState extends State<RegistrationMenu> {
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<int> _selectedDays = [];
  final Color BC = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocationController.text = prefs.getString('currentLocation') ?? '';
      _destinationController.text = prefs.getString('destination') ?? '';
      _selectedDays = prefs.getStringList('selectedDays')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  Future<void> _savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLocation', _currentLocationController.text);
    await prefs.setString('destination', _destinationController.text);
    await prefs.setStringList('selectedDays', _selectedDays.map((day) => day.toString()).toList());
  }

  Future<void> _clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentLocation');
    await prefs.remove('destination');
    await prefs.remove('selectedDays');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // title: Image.asset(
      //   './images/logo_test.png',
      //   width: 100,
      //   height: 50,
      // ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./images/weather_test.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 50.0),
            const Text(
              '登録画面',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 170.0),
                  TextFormField(
                    controller: _currentLocationController,
                    decoration: const InputDecoration(
                      hintText: "現在位置",
                      hintStyle: TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      hintText: "目的地",
                      hintStyle: TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildCheckbox(1, '日'),
                      _buildCheckbox(2, '月'),
                      _buildCheckbox(3, '火'),
                      _buildCheckbox(4, '水'),
                      _buildCheckbox(5, '木'),
                      _buildCheckbox(6, '金'),
                      _buildCheckbox(7, '土'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _clearPreferences();  // Clear previous data
                      await _savePreferences();   // Save new data
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('情報が保存されました。')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('確認'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(int value, String label) {
    return Container(
      color: BC,
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                if (_selectedDays.contains(value)) {
                  _selectedDays.remove(value);
                } else {
                  _selectedDays.add(value);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent),
                color: _selectedDays.contains(value) ? Colors.blueAccent : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _selectedDays.contains(value) ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}