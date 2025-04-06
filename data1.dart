import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import this package
import 'home_page.dart';  // 引入 HomePage
import 'profile_page.dart';  // 引入 ProfilePage
import 'dashboard.dart'; // 引入 SensorDashboard
import 'data_3.dart'; // 引入 Data3
import 'data_5.dart'; // 引入 Data5
import 'data_6.dart'; // 引入 Data6
import 'cgatbot.dart'; // 引入 ChatBotPage
import 'library_page.dart';  // 引入 LibraryPage

class Data1 extends StatefulWidget {
  const Data1({super.key});

  @override
  _Data1State createState() => _Data1State();
}

class _Data1State extends State<Data1> {
  List<TableRow> _tableRows = [];
  Timer? _timer; // Timer object

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Set up the timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final response =
      await http.get(Uri.parse('https://gyyonline.uk/soil_conditions/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        List<TableRow> rows = [];

        // 添加表头
        rows.add(_buildTableRow('時間戳記', '環境溫度（°C）', '濕度（%）', '是否需要澆水',
            isHeader: true));

        // 通过循环添加数据行
        for (var item in data) {
          rows.add(
            _buildTableRow(
              item['timestamp'],
              item['temperature'].toString(),
              item['humidity'].toString(),
              item['is_watered'] == 1 ? '是' : '否',
            ),
          );
        }

        setState(() {
          _tableRows = rows;
        });
      } else {
        // Handle error response
        setState(() {
          _tableRows = [];
        });
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching data: $e');
      setState(() {
        _tableRows = [];
      });
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 添加Drawer
      drawer: Drawer(
        child: Container(
          color: Color(0xFF262626),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF555555),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '阿吉同學',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text(
                  '首頁',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.white),
                title: Text(
                  '儀表板',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.library_books, color: Colors.white),
                title: Text(
                  '圖書館',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LibraryPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white),
                title: Text(
                  '個人資料',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny, color: Colors.white),
                title: Text(
                  '土壤溫濕度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data1()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.thermostat, color: Colors.white),
                title: Text(
                  '葉面溫度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data3()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.eco, color: Colors.white),
                title: Text(
                  '碳排放',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data5()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.water_drop, color: Colors.white),
                title: Text(
                  '酸鹼度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data6()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble, color: Colors.white),
                title: Text(
                  '阿吉同學',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatBotPage(userQuery: ''),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF262626),
        title: const Text('土壤溫濕度'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // 打開側邊攔
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF262626),
          ),
          padding: EdgeInsets.fromLTRB(18.5, 80.6, 18.5, 21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 26,
                  height: 21,
                  child: SvgPicture.asset(
                    'assets/vectors/vector_x2.svg',
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(29.4, 0, 29.4, 42),
                  child: Text(
                    '土壤溫濕度',
                    style: GoogleFonts.getFont(
                      'ABeeZee',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      fontSize: 40,
                      height: 0.5,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15.3, 0, 15.3, 66),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(0.8),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: _tableRows,
                ),
              ),
              SizedBox(
                width: 269.9,
                height: 42,
                child: SvgPicture.asset(
                  'assets/vectors/component_41_x2.svg',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
      String time, String temperature, String humidity, String waterNeeded,
      {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFF444444) : Colors.transparent,
      ),
      children: [
        _buildTableCell(time, isHeader: isHeader),
        _buildTableCell(temperature, isHeader: isHeader),
        _buildTableCell(humidity, isHeader: isHeader),
        _buildTableCell(waterNeeded,
            isHeader: isHeader, isWarning: waterNeeded == '是'),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          'ABeeZee',
          fontStyle: FontStyle.italic,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w400,
          fontSize: 12,
          height: 1.7,
          color: isWarning ? const Color(0xFFFF0000) : const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}
