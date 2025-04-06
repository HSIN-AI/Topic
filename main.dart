import 'package:flutter/material.dart';
import 'package:flutter_app/pages/data_1.dart';
import 'package:flutter_app/pages/data_3.dart';
import 'package:flutter_app/pages/data_4.dart';
import 'package:flutter_app/pages/data_5.dart';
import 'package:flutter_app/pages/data_6.dart';
import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/logo_page.dart';
import 'package:flutter_app/pages/profile_page.dart';
import 'package:flutter_app/pages/sign_in_screen.dart';
import 'package:flutter_app/pages/sign_up_screen.dart';
import 'package:flutter_app/pages/welcome_screen_1.dart';
import 'package:flutter_app/pages/library_page.dart';
import 'package:flutter_app/pages/GuideBar.dart';
import 'package:flutter_app/pages/cgatbot.dart';  // 引入 ChatBotPage
import 'package:flutter_app/pages/Dashboard.dart';  // 引入 Dashboard
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter App'),
        ),
        body: LogoPage(),  // 保持原本的 LogoPage 作為預設頁面
      ),
    );
  }
}
