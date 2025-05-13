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
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';
import 'lux.dart';


class Data5 extends StatefulWidget {
  const Data5({Key? key}) : super(key: key);

  @override
  _Data5State createState() => _Data5State();
}

class _Data5State extends State<Data5> {
  List<TableRow> _tableRows = [];
  Timer? _timer;
  String currentPage = '碳排放'; // Track the current page for active highlight

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
      final response = await http.get(Uri.parse('https://gyyonline.uk/carbon/'));

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);

        if (jsonResult is Map<String, dynamic> && jsonResult.containsKey('data')) {
          final data = jsonResult['data'] as List;

          List<TableRow> rows = [];
          rows.add(_buildTableRow(['時間戳記', '碳排放量 (g)'], isHeader: true));

          for (var item in data) {
            final timestamp = item['timestamp'] ?? '無資料';
            final value = item['value']?.toString() ?? '無資料';

            rows.add(_buildTableRow([timestamp, value]));
          }

          setState(() {
            _tableRows = rows;
          });
        } else {
          setState(() {
            _tableRows = [_buildTableRow(['無資料', '錯誤：無 data 欄位'])];
          });
        }
      } else {
        setState(() {
          _tableRows = [_buildTableRow(['無資料', '錯誤：狀態碼 ${response.statusCode}'])];
        });
      }
    } catch (e) {
      setState(() {
        _tableRows = [_buildTableRow(['無資料', '錯誤：例外錯誤 $e'])];
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
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() {
                  currentPage = '個人資料';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),
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
              _buildDrawerItem(Icons.eco, '碳排放', () {
                setState(() {
                  currentPage = '碳排放';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data5()));
              }, currentPage == '碳排放'),
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
                Navigator.pop(context);
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
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFB0B0B0), // Match Lux: mid-gray AppBar
        title: const Text('碳排放'),
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
                      '碳排放',
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
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
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
