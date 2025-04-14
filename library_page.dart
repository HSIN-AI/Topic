import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';  // 引入 HomePage
import 'profile_page.dart';  // 引入 ProfilePage
import 'dashboard.dart'; // 引入 SensorDashboard
import 'data_1.dart'; // 引入 Data1
import 'data_3.dart'; // 引入 Data3
import 'data_5.dart'; // 引入 Data5
import 'data_6.dart'; // 引入 Data6
import 'cgatbot.dart'; // 引入 ChatBotPage
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
  String currentPage = '圖書館'; // Track the current page for active highlight

  Future<void> fetchData(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final Uri url = Uri.parse('https://gyyonline.uk/data_by_date/?date=$dateString');  // 使用正確的 API URL

    try {
      final response = await http.get(url);
      print("Request URL: $url");  // 輸出請求的 URL

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Response Data: $responseData");  // 輸出 API 回應的資料

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List dataList = responseData['data'];

          if (dataList.isNotEmpty) {
            setState(() {
              data = dataList.map<Map<String, dynamic>>((item) {
                return {
                  'sno': item['sno'] ?? 'No Sno',  // 防止 null 值
                  'type_id': item['type_id'] ?? 0,  // 防止 null 值
                  'timestamp': item['timestamp'] ?? 'No Timestamp',  // 防止 null 值
                  'value': item['value'] ?? 0,  // 防止 null 值
                };
              }).toList();
            });
          } else {
            print("No data available for the selected date.");
            setState(() {
              data = [];
            });
          }
        } else {
          print("Invalid response format");
          setState(() {
            data = [];
          });
        }
      } else {
        print("Failed to load data, status code: ${response.statusCode}");
        setState(() {
          data = [];
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
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

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      // Fetch data based on the selected date
      fetchData(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Background color changed to white
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1),  // Light gray for the drawer background
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1),  // Light gray for the drawer header
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
                        color: Colors.black,  // Text color changed to black
                      ),
                    ),
                  ],
                ),
              ),
              buildListTile(
                icon: Icons.home,
                title: '首頁',
                onTap: () {
                  setState(() {
                    currentPage = '首頁';
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                isActive: currentPage == '首頁',
              ),
              buildListTile(
                icon: Icons.dashboard,
                title: '儀表板',
                onTap: () {
                  setState(() {
                    currentPage = '儀表板';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()),
                  );
                },
                isActive: currentPage == '儀表板',
              ),
              buildListTile(
                icon: Icons.library_books,
                title: '圖書館',
                onTap: () {
                  setState(() {
                    currentPage = '圖書館';
                  });
                  Navigator.pop(context); // Close the side menu
                },
                isActive: currentPage == '圖書館',
              ),
              buildListTile(
                icon: Icons.account_circle,
                title: '個人資料',
                onTap: () {
                  setState(() {
                    currentPage = '個人資料';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                isActive: currentPage == '個人資料',
              ),
              buildListTile(
                icon: Icons.wb_sunny,
                title: '土壤溫濕度',
                onTap: () {
                  setState(() {
                    currentPage = '土壤溫濕度';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data1()),
                  );
                },
                isActive: currentPage == '土壤溫濕度',
              ),
              buildListTile(
                icon: Icons.thermostat,
                title: '葉面溫度',
                onTap: () {
                  setState(() {
                    currentPage = '葉面溫度';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data3()),
                  );
                },
                isActive: currentPage == '葉面溫度',
              ),
              buildListTile(
                icon: Icons.eco,
                title: '碳排放',
                onTap: () {
                  setState(() {
                    currentPage = '碳排放';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data5()),
                  );
                },
                isActive: currentPage == '碳排放',
              ),
              buildListTile(
                icon: Icons.water_drop,
                title: '酸鹼度',
                onTap: () {
                  setState(() {
                    currentPage = '酸鹼度';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Data6()),
                  );
                },
                isActive: currentPage == '酸鹼度',
              ),
              buildListTile(
                icon: Icons.chat_bubble,
                title: '阿吉同學',
                onTap: () {
                  setState(() {
                    currentPage = '阿吉同學';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatBotPage(userQuery: ''),
                    ),
                  );
                },
                isActive: currentPage == '阿吉同學',
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFB0B0B0),  // Gray color for AppBar
        title: const Text('圖書館'),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),  // 增加內邊距讓畫面不顯得擁擠
          child: Column(
            children: [
              // 日期選擇器
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "選擇日期: ${selectedDate.toLocal()}".split(' ')[0],
                  style: GoogleFonts.inter(fontSize: 18, color: Color(0xFF616161)),  // Dark gray text color
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0B0B0), // Gray button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _selectDate(context),
                child: Text('選擇日期', style: GoogleFonts.inter(fontSize: 16)),
              ),
              SizedBox(height: 20),
              // 資料表格顯示
              isLoading
                  ? CircularProgressIndicator()  // 加載中顯示圓形進度條
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
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Timestamp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                    DataColumn(label: Text('Sensor ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                    DataColumn(label: Text('Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                    DataColumn(label: Text('Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                  ],
                  rows: data.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['timestamp'].toString())),  // 將 timestamp 放到最左邊
                      DataCell(Text(item['sno'].toString())),
                      DataCell(Text(item['type_id'].toString())),
                      DataCell(Text(item['value'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build ListTile with hover and click effects
  Widget buildListTile({required IconData icon, required String title, required Function() onTap, required bool isActive}) {
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
          style: GoogleFonts.inter(fontSize: 18, color: Colors.black),  // Text color changed to black
        ),
        tileColor: isActive ? Color(0xFF9E9E9E) : Colors.white,  // Darker gray when active, white otherwise
        onTap: onTap,
      ),
    );
  }
}
