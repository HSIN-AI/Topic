import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart'; // 引入 HomePage
import 'profile_page.dart'; // 引入 ProfilePage
import 'dashboard.dart'; // 引入 SensorDashboard
import 'library_page.dart'; // 引入 LibraryPage
import 'data_1.dart'; // 引入 Data1
import 'data_3.dart'; // 引入 Data3
import 'data_5.dart'; // 引入 Data5
import 'data_6.dart'; // 引入 Data6
import 'cgatbot.dart'; // 引入 ChatBotPage

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 添加 Drawer
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
        backgroundColor: Color(0xFF262626),
        title: const Text('個人資料'),
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
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF262626),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Profile',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                margin: EdgeInsets.fromLTRB(34, 0, 34, 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 17, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23.3),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/images/white.png',
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 5.2),
                            blurRadius: 6.4768748283,
                          ),
                        ],
                      ),
                      width: 64,
                      height: 64,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '邱莘嬡',
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Online',
                          style: GoogleFonts.getFont(
                            'Roboto Condensed',
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(38, 0, 36, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username',
                      style: GoogleFonts.getFont(
                        'Roboto Condensed',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '邱莘嬡',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Color(0xFFDEE1EF),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(37, 0, 37, 137),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: GoogleFonts.getFont(
                        'Roboto Condensed',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2004/05/11',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Color(0xFFDEE1EF),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(35, 0, 32.3, 125),
                decoration: BoxDecoration(
                  color: Color(0xFF6B6B6B),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20.8, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign  Out',
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                        height: 22,
                        child: SvgPicture.asset(
                          'assets/vectors/logout_x2.svg',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
