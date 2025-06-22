import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_1.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';
import 'lux.dart'; // 確保已經正確導入 Lux 頁面
import 'package:flutter_app/pages/chart.dart';


class Data3 extends StatefulWidget {
  const Data3({Key? key}) : super(key: key);

  @override
  _Data3State createState() => _Data3State();
}

class _Data3State extends State<Data3> {
  List<TableRow> _tableRows = [];
  Timer? _timer;
  String currentPage = '現在溫度'; // Track the current page for active highlight

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
      print('Fetching data from https://gyyonline.uk/temperature/');
      final response = await http.get(Uri.parse('https://gyyonline.uk/temperature/'));

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);

        if (jsonResult is Map<String, dynamic> && jsonResult.containsKey('data')) {
          final data = jsonResult['data'] as List;

          if (data.isEmpty) {
            print('⚠️ 資料為空');
          }

          // Get current date (ignore time)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          print('Filtering data for today: $today');

          List<TableRow> rows = [];
          // Updated header
          rows.add(_buildTableRow(['資料類型', '時間戳', '感測器', '現在溫度 (°C)'], isHeader: true));

          // Filter data for today
          final todayData = data.where((item) {
            final timestampStr = item['timestamp']?.toString();
            if (timestampStr == null) {
              print('Skipping item with null timestamp: $item');
              return false;
            }
            try {
              final timestamp = DateTime.parse(timestampStr);
              final timestampDate =
              DateTime(timestamp.year, timestamp.month, timestamp.day);
              final isToday = timestampDate == today;
              print('Item timestamp: $timestampStr, isToday: $isToday');
              return isToday;
            } catch (e) {
              print('Invalid timestamp in item: $item, error: $e');
              return false; // Skip invalid timestamps
            }
          }).toList();

          print('Filtered todayData: $todayData');

          // Check if there is data for today
          if (todayData.isEmpty) {
            print('No data for today, showing no-data message');
            rows.add(_buildTableRow(['今日無數據', '提示', '無資料', '無資料']));
          } else {
            for (var item in todayData) {
              final sensor = item['sno']?.toString() ?? '無資料';
              final timestamp = item['timestamp']?.toString() ?? '無資料';
              final value = item['value']?.toString() ?? '無資料';

              // Display "環境溫度" for type_id 1
              final type = item['type_id'] == 1 ? '環境溫度' : '無資料';

              // Determine temperature status
              String tempStatus = '異常';
              Color rowColor = Colors.white; // Default color

              double tempValue = double.tryParse(value) ?? 0;
              if (tempValue > 25) {
                tempStatus = '過高';
                rowColor = Colors.red.withOpacity(0.3); // Set color for over-high temperature
              } else if (tempValue < 20) {
                tempStatus = '過低';
                rowColor = Colors.blue.withOpacity(0.3); // Set color for over-low temperature
              } else if (tempValue >= 20 && tempValue <= 25) {
                tempStatus = '正常';
                rowColor = Colors.white; // 改成白色背景，不顯示顏色
              }

              print('Adding row: [$type, $timestamp, $sensor, $value]');
              rows.add(_buildTableRowWithColor([type, timestamp, sensor, value], rowColor));
            }
          }

          setState(() {
            _tableRows = rows;
            print('✅ 資料成功更新，共 ${todayData.length} 筆');
          });
        } else {
          print('⚠️ 資料格式錯誤或無 data 欄位');
          setState(() {
            _tableRows = [_buildTableRow(['無資料', '錯誤', '無 data 欄位', '無資料'])];
          });
        }
      } else {
        print('❌ API 回傳錯誤，狀態碼: ${response.statusCode}');
        setState(() {
          _tableRows = [_buildTableRow(['無資料', '錯誤', '狀態碼 ${response.statusCode}', '無資料'])];
        });
      }
    } catch (e) {
      print('❗ 發生例外錯誤: $e');
      setState(() {
        _tableRows = [_buildTableRow(['無資料', '錯誤', '例外錯誤: $e', '無資料'])];
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match Lux: white background
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1), // Match Lux: light gray drawer background
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1),
                ),
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
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() {
                  currentPage = '個人資料';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() {
                  currentPage = '儀表板';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()));
              }, currentPage == '儀表板'),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() {
                  currentPage = '圖書館';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LibraryPage()));
              }, currentPage == '圖書館'),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() {
                  currentPage = '土壤濕度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data1()));
              }, currentPage == '土壤濕度'),
              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() {
                  currentPage = '現在溫度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '現在溫度'),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() {
                  currentPage = '酸鹼度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data6()));
              }, currentPage == '酸鹼度'),
              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() {
                  currentPage = '光照資料';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Lux())); // 正確跳轉到 Lux 頁面
              }, currentPage == '光照資料'),
              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() {
                  currentPage = '阿吉同學';
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatBotPage(userQuery: '')));
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
        backgroundColor: Color(0xFFB0B0B0), // Match Lux: mid-gray AppBar
        title: const Text('現在溫度'),
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
          decoration: const BoxDecoration(
            color: Colors.white, // Match Lux: white background
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // Match Lux padding
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
                      '現在溫度',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 24, // Match Lux: smaller, bold title
                        color: Color(0xFF616161), // Match Lux: dark gray
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // Match Lux: white table background
                    borderRadius: BorderRadius.circular(10), // Match Lux: rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Match Lux: subtle shadow
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2), // Timestamp
                      1: FlexColumnWidth(1.4), // Sensor
                      2: FlexColumnWidth(1.4), // Type
                      3: FlexColumnWidth(1.0), // Value
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
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isActive) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {});
      },
      onExit: (_) {
        setState(() {});
      },
      child: ListTile(
        leading: Icon(icon, color: Colors.black), // Match Lux: black icons
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, color: Colors.black), // Match Lux: black text
        ),
        tileColor: isActive ? Color(0xFF9E9E9E) : Colors.white, // Match Lux: active/inactive colors
        onTap: onTap,
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFFB0B0B0) : Colors.transparent, // Match Lux: mid-gray header
      ),
      children: cells.map((cell) {
        return _buildTableCell(cell, isHeader: isHeader);
      }).toList(),
    );
  }

  TableRow _buildTableRowWithColor(List<String> cells, Color rowColor) {
    return TableRow(
      decoration: BoxDecoration(
        color: rowColor, // Set background color based on temperature status
      ),
      children: cells.map((cell) {
        return _buildTableCell(cell);
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
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400, // Match Lux: header/content weights
          fontSize: 14,
          color: Colors.black, // Match Lux: black text
        ),
      ),
    );
  }
}
