import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_app/pages/chart.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';
import 'lux.dart'; // 確保導入了 Lux 頁面

class Data1 extends StatefulWidget {
  const Data1({Key? key}) : super(key: key);

  @override
  _Data1State createState() => _Data1State();
}

class _Data1State extends State<Data1> {
  List<TableRow> _tableRows = [];
  Timer? _timer;
  String currentPage = '土壤濕度';


  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://gyyonline.uk/soil_moisture/'));

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);

        if (jsonResult is Map<String, dynamic> && jsonResult.containsKey('data')) {
          final data = jsonResult['data'] as List;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          List<TableRow> rows = [];
          rows.add(_buildTableRow(['資料類型', '時間戳', '感測器', '土壤濕度(%)'], isHeader: true));

          final todayData = data.where((item) {
            final timestampStr = item['timestamp']?.toString();
            if (timestampStr == null) return false;
            try {
              final timestamp = DateTime.parse(timestampStr);
              final timestampDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
              return timestampDate == today;
            } catch (e) {
              return false;
            }
          }).toList();

          if (todayData.isEmpty) {
            rows.add(_buildTableRow(['今日無數據', '提示', '無資料', '無資料']));
          } else {
            for (var item in todayData) {
              final typeId = item['type_id']?.toString() ?? '無資料';
              final timestamp = item['timestamp']?.toString() ?? '無資料';
              final sensor = item['sno']?.toString() ?? '無資料';
              final valueStr = item['value']?.toString() ?? '無資料';

              String type = (typeId == '3') ? '土壤濕度' : '未知類型';

              double rawValue = double.tryParse(valueStr) ?? -1;
              double percentage = ((462 - rawValue) / (462 - 205)) * 100;
              String percentageStr = percentage.toStringAsFixed(2);

              Color rowColor = Colors.transparent; // 預設為透明
              if (rawValue > 385) {
                rowColor = Colors.red.withOpacity(0.2); // 乾燥
              } else if (rawValue >= 290 && rawValue <= 380) {
                rowColor = Colors.transparent; // 濕潤 - 正常，保持白色
              } else if (rawValue >= 0 && rawValue < 290) {
                rowColor = Colors.blue.withOpacity(0.2); // 過濕
              } else {
                rowColor = Colors.red.withOpacity(0.1); // 異常
              }

              rows.add(_buildTableRow([type, timestamp, sensor, percentageStr], rowColor: rowColor));
            }
          }

          setState(() {
            _tableRows = rows;
          });
        } else {
          setState(() {
            _tableRows = [_buildTableRow(['無資料', '錯誤', '無 data 欄位', '無資料'])];
          });
        }
      } else {
        setState(() {
          _tableRows = [_buildTableRow(['無資料', '錯誤', '狀態碼 ${response.statusCode}', '無資料'])];
        });
      }
    } catch (e) {
      setState(() {
        _tableRows = [_buildTableRow(['無資料', '錯誤', '例外錯誤: $e', '無資料'])];
      });
    }
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, Color rowColor = Colors.transparent}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFFB0B0B0) : rowColor,
      ),
      children: cells.map((cell) {
        return _buildTableCell(cell, isHeader: isHeader);
      }).toList(),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFF1F1F1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/gkhlogo.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'GKH監測小站',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() {
                  currentPage = '個人資料';
                });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),

              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() {
                  currentPage = '儀表板';
                });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SensorDashboard()));
              }, currentPage == '儀表板'),

              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() {
                  currentPage = '圖書館';
                });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LibraryPage()));
              }, currentPage == '圖書館'),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() {
                  currentPage = '土壤濕度';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data1()));
              }, currentPage == '土壤濕度'),

              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() {
                  currentPage = '現在溫度';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '現在溫度'),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() {
                  currentPage = '酸鹼度';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data6()));
              }, currentPage == '酸鹼度'),

              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() {
                  currentPage = '光照資料';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => Lux()));
              }, currentPage == '光照資料'),

              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() {
                  currentPage = '阿吉同學';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotPage(userQuery: '')));
              }, currentPage == '阿吉同學'),

              _buildDrawerItem(Icons.insert_chart, '圖表分析', () {
                setState(() {
                  currentPage = '圖表分析';
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChartPage()));
              }, currentPage == '圖表分析'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFB0B0B0),
        title: const Text('土壤濕度'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/vectors/vector_12_x2.svg',
                    width: 26,
                    height: 21,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '土壤濕度',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF616161),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.4),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(1.0),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: _tableRows,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: SvgPicture.asset(
                  'assets/vectors/component_41_x2.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isActive) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
        ),
        tileColor: isActive ? Color(0xFF9E9E9E) : Colors.white,
        onTap: onTap,
      ),
    );
  }
}
