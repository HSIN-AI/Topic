import 'package:flutter/material.dart';
import 'home_page.dart'; // 引入 home_page.dart

class LogoPage extends StatefulWidget {
  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    // 开始淡出动画，并在动画结束后跳转到 home_page
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2), // 设置淡出动画的持续时间
          child: Container(
            width: 304.3,
            height: 348.1,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/gkhlogo.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
