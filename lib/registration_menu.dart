import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int globalHour = 0;
String globalminute = '';
int globalminuteTmp = 0;

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
  TimeOfDay? selectedTime;

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

  Future<void> _pickTime(BuildContext context) async {
    const initialTime = TimeOfDay(hour: 10, minute: 0);

    final newTime = await showTimePicker(context: context, initialTime: initialTime);

    if (newTime != null) {
      setState(() => selectedTime = newTime);
    }
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
            const SizedBox(height: 20),
            Text(selectedTime != null ? "${selectedTime!.hour}:${selectedTime!.minute}" : "Time"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickTime(context),
              child: const Text("Pick Time"),
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
  TimeOfDay? selectedTime;
  final Color BC = Colors.white;
  bool CurrentEmpty = false;
  bool DestinationEmpty = false;
  final Map<String, String> _validLocations = {
    // (location map content)
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
    if (location.isEmpty) {
      CurrentEmpty = true;
    } else {
      CurrentEmpty = false;
    }
    return _validLocations.containsKey(location.toLowerCase());
  }

  bool _isDestinationLocation(String location) {
    if (location.isEmpty) {
      DestinationEmpty = true;
    } else {
      DestinationEmpty = false;
    }
    return _validLocations.containsKey(location.toLowerCase());
  }

  Future<void> _savePreferences() async {
    if (!_isValidLocation(_currentLocationController.text) || !_isDestinationLocation(_destinationController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前間違えました、もう一回入力してください')),
      );
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLocation', _currentLocationController.text);
    await prefs.setString('destination', _destinationController.text);
    await prefs.setStringList('selectedDays', _selectedDays.map((day) => day.toString()).toList());
    if (selectedTime != null) {
      await prefs.setString('selectedTime', '${selectedTime!.hour}:${selectedTime!.minute}');
    }
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
      final timeString = prefs.getString('selectedTime');
      if (timeString != null) {
        final timeParts = timeString.split(':');
        selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      }
    });
  }

  Future<void> _clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentLocation');
    await prefs.remove('destination');
    await prefs.remove('selectedDays');
    await prefs.remove('selectedTime');
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✗ 登録に失敗しました。もう一度入力してください', style: TextStyle(fontSize: 14)), backgroundColor: Colors.redAccent,),
    );
  }

  void _showErrorMessageSecond() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✗ 自宅地と勤務地、どちらも入力して下さい', style: TextStyle(fontSize: 14)), backgroundColor: Colors.redAccent,),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    const initialTime = TimeOfDay(hour: 10, minute: 0);

    final newTime = await showTimePicker(context: context, initialTime: initialTime);

    if (newTime != null) {
      setState(() => selectedTime = newTime);
      globalminuteTmp = selectedTime!.minute;
      globalHour = selectedTime!.hour;
      print(globalminute);
    }
    if(globalminuteTmp == 0) {
      globalminute = '00';
      print(globalminuteTmp);
    }else{
      globalminute = globalminuteTmp.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 170.0),
                              TextFormField(
                                controller: _currentLocationController,
                                decoration: const InputDecoration(
                                  hintText: "自宅地",
                                  hintStyle: TextStyle(color: Colors.black),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _destinationController,
                                decoration: const InputDecoration(
                                  hintText: "勤務地",
                                  hintStyle: TextStyle(color: Colors.black),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: EdgeInsets.only(top: size.height * 0.26),
                                child: Row(
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
                              ),
                              // 背景など、他のウィジェットをここに追加できます
                              Padding(
                                padding: EdgeInsets.only(top: size.height * 0.03, left: size.width * 0.09),
                                child: Align(
                                  alignment: Alignment.topLeft, // 位置の調整
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5), // 背景色を設定 (任意)
                                    padding: const EdgeInsets.all(16.0),
                                    width: size.width * 0.75, // 固定幅を設定 (例: 画面幅の75%)
                                    height: size.height * 0.17, // 固定高さを設定 (例: 150.0)
                                    child: Column(
                                      children: [
                                        // 時刻選択ボタンを追加
                                        ElevatedButton(
                                          onPressed: () => _pickTime(context),
                                          child: const Text("⏰ 通知時刻を設定"),
                                        ),
                                        const SizedBox(height: 20),
                                        // 選択された時刻の表示
                                        Text(
                                          globalminute != null
                                              ? "通知時刻：${globalHour}:${globalminute}"
                                              : "通知時刻が設定されていません！",
                                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                                        ),
                                        const SizedBox(height: 16.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Buttons
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      // 取消ボタン (Cancel button)
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(left: size.width * 0.08,bottom: size.height * 0.02, top: size.height * 0.02),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // 入力情報を破棄して画面遷移 (Discard input information and move to screen)
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, // 文字色 (Text color)
                                              backgroundColor: Colors.redAccent, // 背景色 (Background color)
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: const Text('取消'), // ボタンに書かれているテキスト (Button text)
                                          ),
                                        ),
                                      ),
                                      // 登録ボタン (Register button)
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(bottom: size.height * 0.02, right: size.width * 0.09, top: size.height * 0.02),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              String currentLocation = _currentLocationController.text;
                                              String destination = _destinationController.text;
                                              if (_isValidLocation(currentLocation) && _isDestinationLocation(destination) || DestinationEmpty && CurrentEmpty) {
                                                await _clearPreferences(); // Clear previous data
                                                await _savePreferences(); // Save new data
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(' ✓    情報の保存に成功しました！', style: TextStyle(fontSize: 19)),
                                                    backgroundColor: Colors.greenAccent,
                                                  ),
                                                );
                                              } else {
                                                if (CurrentEmpty || DestinationEmpty) {
                                                  _showErrorMessageSecond();
                                                } else {
                                                  _showErrorMessage();
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, // 文字色 (Text color)
                                              backgroundColor: Colors.lightBlueAccent, // 背景色 (Background color)
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: const Text('登録'), // ボタンに書かれているテキスト (Button text)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],),
                        ),
                      ],),
                  ),
                ),),
              Positioned(
                top: size.height * 0.46,
                left: size.width * 0.20,  // Adjust as necessary
                child: Container(
                  width: size.width * 0.6,  // Adjust as necessary
                  height: size.height * 0.2,  // Adjust as necessary
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/cloudy_memo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.535,
                left: size.width * 0.28,  // Adjust as necessary
                child: const Text(
                  '休みの日を選択！',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black54,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.10,
                left: size.width * 0.32,  // Adjust as necessary
                child: const Text(
                  '登録画面',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),],
          );
        },),
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
