import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/pages/profile_page.dart';
import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/library_page.dart';

class GuideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF555555), // 底部导航栏的背景颜色
      ),
      padding: EdgeInsets.fromLTRB(20, 9.5, 20, 9.5), // 导航栏内的边距
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 平均分布图标
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryPage()),
              );
            },
            child: SvgPicture.asset(
              'assets/vectors/library_buttom_x2.svg',
              width: 26,
              height: 38,
              semanticsLabel: '图书馆', // 可访问性标签
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: SvgPicture.asset(
              'assets/vectors/home_point_x2.svg',
              width: 28.3,
              height: 24.1,
              semanticsLabel: '首页', // 可访问性标签
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: SvgPicture.asset(
              'assets/vectors/component_7_x2.svg',
              width: 22,
              height: 36,
              semanticsLabel: '个人资料', // 可访问性标签
            ),
          ),
        ],
      ),
    );
  }
}
