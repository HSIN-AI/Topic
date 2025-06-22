import 'package:firebase_core/firebase_core.dart';
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
import 'package:flutter_app/pages/cgatbot.dart';  // 引入 ChatBotPage
import 'package:flutter_app/pages/Dashboard.dart';  // 確保匯入路徑正確
import 'package:flutter_app/pages/lux.dart';//引入lux數值
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/logo_page.dart';  // 根據你的應用頁面調整
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // 引入 kIsWeb 用於判斷平台
import 'package:flutter_app/pages/logo_page.dart';
import 'package:flutter_app/pages/chart.dart'; // Add this import// 根據你的應用頁面調整

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase Web 配置 (從 Firebase 控制台獲得的配置)
    const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyD9Gs8UomCSjiOf2vqO4vOQa9KBJ9OiSCM",  // 使用從 Firebase 控制台中獲得的有效 API 金鑰
      authDomain: "topic-loginout.firebaseapp.com",         // 確保填寫 Firebase 控制台中的 authDomain
      projectId: "topic-loginout",                          // 確保填寫 Firebase 控制台中的 projectId
      storageBucket: "topic-loginout.appspot.com",          // 確保填寫 Firebase 控制台中的 storageBucket
      messagingSenderId: "456847442545",                    // 確保填寫 Firebase 控制台中的 messagingSenderId
      appId: "1:456847442545:web:548c8544fd809c134991d0",  // 確保填寫 Firebase 控制台中的 appId
      measurementId: "G-0MPBM4XPXK",                       // 確保填寫 Firebase 控制台中的 measurementId
    );

    // 初始化 Firebase
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    // 移動端 (Android/iOS) Firebase 初始化，這會自動加載配置
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:SensorDashboard(),//測試時使用這行
      //home: LogoPage(),  // 螢幕一開始顯示 LogoPage
      routes: {
        '/signIn': (context) => SignInScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/welcome': (context) => WelcomeScreen1(),
        '/home': (context) =>SensorDashboard(),  // 主頁

      },
    );
  }
}
