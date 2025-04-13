import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import this package
import 'home_page.dart';  // 引入 HomePage
import 'profile_page.dart';  // 引入 ProfilePage
import 'dashboard.dart'; // 引入 SensorDashboard
import 'data_1.dart'; // 引入 Data1
import 'data_5.dart'; // 引入 Data5
import 'data_6.dart'; // 引入 Data6
import 'cgatbot.dart'; // 引入 ChatBotPage
import 'library_page.dart';  // 引入 LibraryPage

class Data3 extends StatefulWidget {
  const Data3({Key? key}) : super(key: key);

  @override
  _Data3State createState() => _Data3State();
}

class _Data3State extends State<Data3> {
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
      final response = await http.get(Uri.parse('https://gyyonline.uk/temperature/'));

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);

        if (jsonResult is Map<String, dynamic> && jsonResult.containsKey('data')) {
          final data = jsonResult['data'] as List;

          if (data.isEmpty) {
            print('⚠️ 資料為空');
          }

          List<TableRow> rows = [];
          rows.add(_buildTableRow(['感測器', '數據序號', '計數號', '時間戳', '溫度'], isHeader: true));

          for (var item in data) {
            final sensor = item['sno'] ?? '無資料';
            final cntNo = item['cnt_no']?.toString() ?? '無資料';
            final typeId = item['type_id']?.toString() ?? '無資料';
            final timestamp = item['timestamp'] ?? '無資料';
            final value = item['value']?.toString() ?? '無資料';

            rows.add(_buildTableRow([sensor, cntNo, typeId, timestamp, value]));
          }

          setState(() {
            _tableRows = rows;
          });

          print('✅ 資料成功更新，共 ${data.length} 筆');
        } else {
          print('⚠️ 資料格式錯誤或無 data 欄位');
          setState(() {
            _tableRows = [_buildTableRow(['錯誤', '無 data 欄位', '無資料', '無資料', '無資料'])];
          });
        }
      } else {
        print('❌ API 回傳錯誤，狀態碼: ${response.statusCode}');
        setState(() {
          _tableRows = [_buildTableRow(['錯誤', '狀態碼 ${response.statusCode}', '無資料', '無資料', '無資料'])];
        });
      }
    } catch (e) {
      print('❗ 發生例外錯誤: $e');
      setState(() {
        _tableRows = [_buildTableRow(['錯誤', '例外錯誤', '無資料', '無資料', '無資料'])];
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
      backgroundColor: Color(0xFFF1F8E9),  // 背景色設為淺綠色
      // 添加Drawer
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F8E9),  // 側邊欄背景色為淺綠色
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFB9F6CA),  // 背景顏色設為淺綠色
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
                leading: Icon(Icons.home, color: Colors.black),
                title: Text(
                  '首頁',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.black),
                title: Text(
                  '儀表板',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.library_books, color: Colors.black),
                title: Text(
                  '圖書館',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LibraryPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text(
                  '個人資料',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny, color: Colors.black),
                title: Text(
                  '土壤溫濕度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data1()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.thermostat, color: Colors.black),
                title: Text(
                  '土壤溫度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data3()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.eco, color: Colors.black),
                title: Text(
                  '碳排放',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data5()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.water_drop, color: Colors.black),
                title: Text(
                  '酸鹼度',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data6()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble, color: Colors.black),
                title: Text(
                  '阿吉同學',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
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
        backgroundColor: Color(0xFF81C784),  // 淺綠色的AppBar
        title: const Text('土壤溫度'),
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
          decoration: const BoxDecoration(
            color: Color(0xFFF1F8E9),  // 背景色為淺綠色
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.5, 80.6, 18.5, 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 返回按钮
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
                // 标题
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '土壤溫度',
                      style: GoogleFonts.getFont(
                        'ABeeZee',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        height: 1.2,
                        color: Colors.black,  // 字體顏色為黑色
                      ),
                    ),
                  ),
                ),
                // 数据表格
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.3),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.4),
                      4: FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: _tableRows,
                  ),
                ),
                // 底部组件（可根据需要添加）
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

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFF81C784) : Colors.transparent,  // 標題行顏色設定為淺綠色
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
        style: GoogleFonts.getFont(
          'ABeeZee',
          fontStyle: FontStyle.italic,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w400,
          fontSize: 14,
          height: 1.7,
          color: Colors.black,  // 設為深黑色
        ),
      ),
    );
  }
}
