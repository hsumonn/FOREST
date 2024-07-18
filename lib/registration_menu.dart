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
      home: const RegistMenu(),
    );
  }
}

class RegistMenu extends StatefulWidget {
  const RegistMenu({super.key});

  @override
  _RegistMenuState createState() => _RegistMenuState();
}

class _RegistMenuState extends State<RegistMenu> {
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
  final Map<String, String> _validLocations = {
    'hokkaido': '北海道',
    'aomori': '青森',
    'iwate': '岩手',
    'miyagi': '宮城',
    'akita': '秋田',
    'yamagata': '山形',
    'fukushima': '福島',
    'ibaraki': '茨城',
    'tochigi': '栃木',
    'gunma': '群馬',
    'saitama': '埼玉',
    'chiba': '千葉',
    'tokyo': '東京',
    'kanagawa': '神奈川',
    'niigata': '新潟',
    'toyama': '富山',
    'ishikawa': '石川',
    'fukui': '福井',
    'yamanashi': '山梨',
    'nagano': '長野',
    'gifu': '岐阜',
    'shizuoka': '静岡',
    'aichi': '愛知',
    'mie': '三重',
    'shiga': '滋賀',
    'kyoto': '京都',
    'osaka': '大阪',
    'hyogo': '兵庫',
    'nara': '奈良',
    'wakayama': '和歌山',
    'tottori': '鳥取',
    'shimane': '島根',
    'okayama': '岡山',
    'hiroshima': '広島',
    'yamaguchi': '山口',
    'tokushima': '徳島',
    'kagawa': '香川',
    'ehime': '愛媛',
    'kochi': '高知',
    'fukuoka': '福岡',
    'saga': '佐賀',
    'nagasaki': '長崎',
    'kumamoto': '熊本',
    'oita': '大分',
    'miyazaki': '宮崎',
    'kagoshima': '鹿児島',
    'okinawa': '沖縄',
  };

  bool _isValidLocation(String location) {
    return location.isEmpty || _validLocations.containsKey(location.toLowerCase());
  }

  Future<void> _savePreferences() async {
    if (!_isValidLocation(_currentLocationController.text) || !_isValidLocation(_destinationController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前間違えました、もう一回入力してください')),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLocation', _currentLocationController.text);
    await prefs.setString('destination', _destinationController.text);
    await prefs.setStringList('selectedDays', _selectedDays.map((day) => day.toString()).toList());
  }

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

  Future<void> _clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentLocation');
    await prefs.remove('destination');
    await prefs.remove('selectedDays');
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('名前間違えました、もう一回入力してください')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  './images/weather_test.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text('取消'),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String currentLocation = _currentLocationController.text;
                                        String destination = _destinationController.text;
                                        if (_isValidLocation(currentLocation) && _isValidLocation(destination)) {
                                          await _clearPreferences();
                                          await _savePreferences();
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('情報が保存されました。')),
                                          );
                                        } else {
                                          _showErrorMessage();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.lightBlueAccent,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text('登録'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
