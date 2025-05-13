import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  String currentPage = '圖書館'; // 設定當前頁面為 "圖書館"

  Future<void> fetchData(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    final String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final Uri url = Uri.parse('https://gyyonline.uk/data_by_date/?date=$dateString');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List dataList = responseData['data'];

          if (dataList.isNotEmpty) {
            setState(() {
              data = dataList.map<Map<String, dynamic>>((item) {
                return {
                  'sno': item['sno'] ?? 'No Sno',
                  'type_id': item['type_id'] ?? 0,
                  'timestamp': item['timestamp'] ?? 'No Timestamp',
                  'value': item['value'] ?? 0,
                };
              }).toList();
            });
          } else {
            setState(() {
              data = [];
            });
          }
        } else {
          setState(() {
            data = [];
          });
        }
      } else {
        setState(() {
          data = [];
        });
      }
    } catch (error) {
      setState(() {
        data = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    ) ?? selectedDate;

    if (picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      fetchData(selectedDate);
    }
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
              _buildDrawerItem(Icons.thermostat, '土壤溫度', () {
                setState(() {
                  currentPage = '土壤溫度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '土壤溫度'),
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
        backgroundColor: Color(0xFFB0B0B0),
        title: Text(currentPage), // 顯示當前頁面的名稱
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "選擇日期: ${selectedDate.toLocal()}".split(' ')[0],
                  style: GoogleFonts.inter(fontSize: 18, color: Color(0xFF616161)),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0B0B0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _selectDate(context),
                child: Text('選擇日期', style: GoogleFonts.inter(fontSize: 16)),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : data.isEmpty
                  ? Text('沒有資料', style: TextStyle(fontSize: 18, color: Colors.red))
                  : Container(
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text('Timestamp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      DataColumn(
                        label: Text('Sensor ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      DataColumn(
                        label: Text('Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      DataColumn(
                        label: Text('Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ],
                    rows: data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['timestamp'].toString())),
                        DataCell(Text(item['sno'].toString())),
                        DataCell(Text(item['type_id'].toString())),
                        DataCell(Text(item['value'].toString())),
                      ]);
                    }).toList(),
                  ),
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
      onEnter: (_) {
        setState(() {});
      },
      onExit: (_) {
        setState(() {});
      },
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
        ),
        tileColor: isActive ? Color(0xFF9E9E9E) : Colors.white, // 根據是否為當前頁面來設置背景顏色
        onTap: onTap,
      ),
    );
  }
}
