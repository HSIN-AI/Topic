import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';

class Data1 extends StatefulWidget {
  const Data1({Key? key}) : super(key: key);

  @override
  _Data1State createState() => _Data1State();
}

class _Data1State extends State<Data1> {
  List<TableRow> _tableRows = [];
  Timer? _timer;

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

          List<TableRow> rows = [];
          rows.add(_buildTableRow(['感測器', '數據序號', '類型', '時間戳', '濕度(%)'], isHeader: true));

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
        } else {
          setState(() {
            _tableRows = [_buildTableRow(['錯誤', '無 data 欄位', '無資料', '無資料', '無資料'])];
          });
        }
      } else {
        setState(() {
          _tableRows = [_buildTableRow(['錯誤', '狀態碼 ${response.statusCode}', '無資料', '無資料', '無資料'])];
        });
      }
    } catch (e) {
      setState(() {
        _tableRows = [_buildTableRow(['錯誤', '例外錯誤', '無資料', '無資料', '無資料'])];
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
      backgroundColor: Color(0xFFF1F8E9),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F8E9),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFB9F6CA),
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
              _buildDrawerItem(Icons.home, '首頁', () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              }),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SensorDashboard()));
              }),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LibraryPage()));
              }),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }),
              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data1()));
              }),
              _buildDrawerItem(Icons.thermostat, '葉面溫度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data3()));
              }),
              _buildDrawerItem(Icons.eco, '碳排放', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data5()));
              }),
              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data6()));
              }),
              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotPage(userQuery: '')));
              }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF81C784),
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
          decoration: const BoxDecoration(
            color: Color(0xFFF1F8E9),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.5, 80.6, 18.5, 21),
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
                      style: GoogleFonts.getFont(
                        'ABeeZee',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
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

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
      ),
      onTap: onTap,
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFF81C784) : Colors.transparent,
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
          color: Colors.black,
        ),
      ),
    );
  }
}
