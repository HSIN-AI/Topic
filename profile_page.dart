import 'dart:io'; // 確保使用 FileImage 加載本地圖片
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認證
import 'package:image_picker/image_picker.dart'; // 用來選擇圖片
import 'package:flutter_svg/flutter_svg.dart'; // 用於加載SVG圖標
import 'package:flutter_app/pages/welcome_screen_1.dart'; // 用於導向 Welcome Page
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'data_1.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';
import 'lux.dart'; // Added import for Lux

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late User _user;
  String _username = '邱莘嬡'; // 初始顯示名稱
  String _userEmail = '';
  String _profileImage = 'assets/images/profile.jpg'; // 初始頭像
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _userEmail = _user.email!;
    _username = _user.displayName ?? 'User'; // 如果Firebase有用戶名，顯示它

    // 初始化動畫控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // 上傳圖片並更新頭像
  Future<void> _updateProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image.path; // 更新頭像為選擇的圖片
      });
    }
  }

  // 更新用戶名稱
  Future<void> _updateUsername() async {
    try {
      await _user.updateDisplayName(_username); // 更新Firebase中的用戶名
      await _user.reload();
      setState(() {
        _username = _user.displayName!;
      });
    } catch (e) {
      print('Error updating username: $e');
    }
  }

  // 登出並重定向到 WelcomePage
  Future<void> _signOut() async {
    await _animationController.forward(); // 執行登出按鈕的動畫
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 添加 Drawer
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
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SensorDashboard()));
              }),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LibraryPage()));
              }),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data1()));
              }),
              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data6()));
              }),
              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Lux()));
              }),
              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatBotPage(userQuery: '')));
              }),
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
                    GestureDetector(
                      onTap: _updateProfileImage, // 點擊頭像來更新
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 17, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23.3),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _profileImage.contains('assets')
                                ? AssetImage(_profileImage)
                                : FileImage(File(_profileImage)) as ImageProvider, // 根據圖片來源顯示
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
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Edit Username'),
                                  content: TextField(
                                    controller: TextEditingController(text: _username),
                                    onChanged: (value) {
                                      setState(() {
                                        _username = value;
                                      });
                                    },
                                    decoration: InputDecoration(hintText: "Enter your new username"),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _updateUsername();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            _username,
                            style: GoogleFonts.getFont(
                              'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          _userEmail,
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
              // 顯示帳號（修改 Date of Birth 顯示為 User Email）
              Container(
                margin: EdgeInsets.fromLTRB(38, 0, 36, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Email',
                      style: GoogleFonts.getFont(
                        'Roboto Condensed',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _userEmail,
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
              // 登出按鈕
              GestureDetector(
                onTap: _signOut,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
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
                                'Sign Out',
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
