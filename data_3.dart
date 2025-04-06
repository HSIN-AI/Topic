import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';  // 引入 HomePage
import 'profile_page.dart';  // 引入 ProfilePage
import 'dashboard.dart'; // 引入 SensorDashboard
import 'data_1.dart'; // 引入 Data1
import 'data_5.dart'; // 引入 Data5
import 'data_6.dart'; // 引入 Data6
import 'cgatbot.dart'; // 引入 ChatBotPage
import 'library_page.dart';  // 引入 LibraryPage

class Data3 extends StatelessWidget {
  const Data3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF262626),
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
                  Navigator.pop(context); // 關閉側邊攔
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
        title: const Text('葉面溫度'),
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
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF262626),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.5, 80.6, 18.5, 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 返回按钮
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
                // 标题
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '葉面溫度',
                      style: GoogleFonts.getFont(
                        'ABeeZee',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        height: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 数据表格
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.3),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildTableRow(
                        ['時間戳記', '環境溫度（°C）', '葉面溫度（°C）', '蟲害檢測'],
                        isHeader: true,
                      ),
                      _buildTableRow(
                          ['2024-05-24 00:00', '25.0', '27.49', '否']),
                      _buildTableRow(
                          ['2024-05-24 01:00', '26.0', '39.01', '否']),
                      _buildTableRow(
                          ['2024-05-24 02:00', '25.5', '34.64', '否']),
                      _buildTableRow(
                          ['2024-05-24 03:00', '24.8', '31.97', '否']),
                      _buildTableRow(
                          ['2024-05-24 04:00', '24.0', '23.12', '是']),
                      _buildTableRow(
                          ['2024-05-24 05:00', '23.5', '23.12', '否']),
                      _buildTableRow(
                          ['2024-05-24 06:00', '23.0', '21.16', '否']),
                      _buildTableRow(
                          ['2024-05-24 07:00', '24.5', '37.32', '否']),
                      _buildTableRow(
                          ['2024-05-24 08:00', '25.5', '32.02', '否']),
                      _buildTableRow(
                          ['2024-05-24 09:00', '26.0', '34.16', '否']),
                      _buildTableRow(
                          ['2024-05-24 10:00', '27.0', '20.41', '否']),
                      _buildTableRow(
                          ['2024-05-24 11:00', '28.0', '39.40', '否']),
                      _buildTableRow(
                          ['2024-05-24 12:00', '29.0', '36.65', '否']),
                      _buildTableRow(
                          ['2024-05-24 13:00', '29.5', '24.25', '否']),
                      _buildTableRow(
                          ['2024-05-24 14:00', '30.0', '23.64', '否']),
                      _buildTableRow(
                          ['2024-05-24 15:00', '30.5', '23.67', '否']),
                      _buildTableRow(
                          ['2024-05-24 16:00', '31.0', '26.08', '是']),
                      _buildTableRow(
                          ['2024-05-24 17:00', '31.5', '30.50', '否']),
                      _buildTableRow(
                          ['2024-05-24 18:00', '32.0', '28.64', '否']),
                      _buildTableRow(
                          ['2024-05-24 19:00', '31.5', '25.82', '否']),
                      _buildTableRow(
                          ['2024-05-24 20:00', '30.0', '32.24', '否']),
                      _buildTableRow(
                          ['2024-05-24 21:00', '29.0', '22.79', '否']),
                      _buildTableRow(
                          ['2024-05-24 22:00', '28.0', '25.84', '否']),
                      _buildTableRow(
                          ['2024-05-24 23:00', '27.0', '27.33', '否']),
                    ],
                  ),
                ),
                // 底部组件（可根据需要添加）
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

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFF444444) : Colors.transparent,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'ABeeZee',
              fontStyle: FontStyle.italic,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w400,
              fontSize: 12,
              height: 1.7,
              color: cell == '是' ? Colors.red : Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}
