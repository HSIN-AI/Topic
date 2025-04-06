import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'profile_page.dart';
import 'library_page.dart';
import 'cgatbot.dart'; // 引入 ChatBotPage
import 'dashboard.dart'; // 引入 SensorDashboard

class HomePage extends StatelessWidget {
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
              // 新增的選項
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
        title: const Text('首頁'),
        backgroundColor: Color(0xFF262626),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 172, 0, 21),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Data1()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '土壤溫濕度',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Data3()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '葉面溫度',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Data5()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '碳排放',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Data6()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '酸鹼度',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatBotPage(userQuery: ''),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '阿吉同學',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorDashboard(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 73),
                    child: Text(
                      '儀表板',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
