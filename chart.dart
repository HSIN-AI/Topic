import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'library_page.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'lux.dart';
import 'package:flutter_app/pages/Dashboard.dart';
import 'package:flutter_app/pages/chart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {

  String currentPage = '圖表分析'; // 1️⃣ 新增目前頁面名稱

  List<LineChartBarData> luxChartData = [];
  List<String> luxDates = [];
  List<int> luxCounts = [];

  List<LineChartBarData> tempChartData = [];
  List<String> tempDates = [];
  List<double> avgTemps = [];

  List<LineChartBarData> humidityChartData = [];
  List<String> humidityDates = [];
  List<double> avgHumidities = [];

  List<Map<String, dynamic>> _recommendations = [];

  // ✅ 加在 _ChartPageState class 內任意位置（如 build() 上方）
  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.lightGreenAccent;
      case 'normal':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilization':
        return Icons.spa;
      case 'environment':
        return Icons.wb_sunny;
      case 'disease':
        return Icons.bug_report;
      default:
        return Icons.agriculture;
    }
  }

  String _typeToChinese(String? type) {
    switch (type) {
      case 'irrigation':
        return '灌溉建議';
      case 'fertilization':
        return '施肥建議';
      case 'environment':
        return '環境調整';
      case 'disease':
        return '病蟲害預防';
      default:
        return '其他';
    }
  }



  // 2️⃣ 新增 Data1 風格的 DrawerItem 建構器
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      bool isActive) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
        ),
        tileColor: isActive ? Color(0xFF9E9E9E) : Colors.white,
        onTap: onTap,
      ),
    );
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 啟用通知權限（特別是 iOS 必須）
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("🔔 推播權限已授權");

      // 訂閱 topic（與後端一致）
      await messaging.subscribeToTopic('tomato');
      print("📡 已訂閱 topic: tomato");

      // 前台通知處理
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          final snack = SnackBar(
            content: Text("${notification.title}：${notification.body}"),
            backgroundColor: Colors.green[700],
            duration: Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        }
      });

      // 使用者點通知打開 app 時處理
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("🔔 使用者從通知開啟 App：${message.data}");
        // 可加跳頁邏輯，如：
        // Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationPage()));
      });
    } else {
      print("⚠️ 使用者未授權推播");
    }
  }


  Timer? _refreshTimer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // 讀取感測圖表資料
    _initFCM(); // 初始化 FCM 推播功能
    _refreshTimer = Timer.periodic( // 每 5 分鐘自動刷新
      Duration(minutes: 5),
          (timer) {
        _loadAllData();
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      await _fetchLuxData();
      await _fetchTempData();
      await _fetchHumidityData();
      await _fetchRecommendations();
    } catch (e) {
      print('❌ 某個資料載入失敗：$e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchRecommendations() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.31.169:8000/latest-recommendations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recommendations = data.cast<Map<String, dynamic>>();
        });
      } else {
        print('❌ 無法載入建議資料：${response.statusCode}');
      }
    } catch (e) {
      print('❌ 推薦 API 發生錯誤：$e');
    }
  }


  Future<void> _fetchLuxData() async {
    final response = await http.get(
        Uri.parse('https://gyyonline.uk/lux/daily_duration/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processLuxData(data['data']);
    } else {
      throw Exception('無法載入光照資料');
    }
  }

  Future<void> _fetchTempData() async {
    final response = await http.get(
        Uri.parse('https://gyyonline.uk/temperature/daily_avg/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processTempData(data['data']);
    } else {
      throw Exception('無法載入溫度資料');
    }
  }

  Future<void> _fetchHumidityData() async {
    final response = await http.get(
        Uri.parse('https://gyyonline.uk/humidity/daily_avg/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processHumidityData(data['data']);
    } else {
      throw Exception('無法載入濕度資料');
    }
  }

  void _processLuxData(List<dynamic> data) {
    luxDates.clear();
    luxCounts.clear();
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      String date = data[i]['date'];
      int originalLuxCount = data[i]['high_lux_count'];
      double halfLuxCount = originalLuxCount / 2;

      luxDates.add(date);
      luxCounts.add(originalLuxCount); // 保留原始值給 Y 軸使用
      spots.add(FlSpot(i.toDouble(), halfLuxCount));
    }
    setState(() {
      luxChartData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          isStrokeCapRound: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    });
  }


  void _processTempData(List<dynamic> data) {
    final Map<String, List<double>> grouped = {};

    for (var item in data) {
      final String date = item['date'].substring(0, 10);
      final double value = item['avg_temp'].toDouble();

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(value);
    }

    tempDates.clear();
    avgTemps.clear();
    final List<FlSpot> spots = [];

    final sortedDates = grouped.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final values = grouped[date]!;
      final avg = values.reduce((a, b) => a + b) / values.length;

      tempDates.add(date);
      avgTemps.add(avg);
      spots.add(FlSpot(i.toDouble(), avg));
    }

    setState(() {
      tempChartData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          isStrokeCapRound: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    });
  }

  void _processHumidityData(List<dynamic> data) {
    final Map<String, List<double>> grouped = {};

    for (var item in data) {
      final String date = item['date'].substring(0, 10);
      final double value = item['avg_humidity'].toDouble();

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(value);
    }

    humidityDates.clear();
    avgHumidities.clear();
    final List<FlSpot> spots = [];

    final sortedDates = grouped.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final values = grouped[date]!;
      final avg = values.reduce((a, b) => a + b) / values.length;

      humidityDates.add(date);
      avgHumidities.add(avg);
      spots.add(FlSpot(i.toDouble(), avg));
    }

    setState(() {
      humidityChartData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.green,
          isStrokeCapRound: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    });
  }


  @override
  Widget build(BuildContext context) {
    double minLuxX = 0;
    double maxLuxX = luxDates.length.toDouble() - 1;
    double minLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) =>
    a < b
        ? a
        : b).toDouble() / 2 : 0;
    double maxLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) =>
    a > b
        ? a
        : b).toDouble() / 2 : 0;

    double minTempX = 0;
    double maxTempX = tempDates.length.toDouble() - 1;
    double minTempY = avgTemps.isNotEmpty ? avgTemps.reduce((a, b) =>
    a < b
        ? a
        : b) - 3 : 0;
    double maxTempY = avgTemps.isNotEmpty ? avgTemps.reduce((a, b) =>
    a > b
        ? a
        : b) + 3 : 0;

    double minHumidityX = 0;
    double maxHumidityX = humidityDates.length.toDouble() - 1;
    double minHumidityY = avgHumidities.isNotEmpty ? avgHumidities.reduce((a,
        b) => a < b ? a : b) - 5 : 0;
    double maxHumidityY = avgHumidities.isNotEmpty ? avgHumidities.reduce((a,
        b) => a > b ? a : b) + 5 : 100;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
            '近五日平均圖表與番茄建議', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : Icon(Icons.refresh, color: Colors.white),
            onPressed: isLoading ? null : _loadAllData,
            tooltip: '手動刷新資料',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFF1F1F1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 40,
                        backgroundImage: AssetImage(
                            'assets/images/gkhlogo.png')),
                    SizedBox(height: 10),
                    Text(
                      'GKH監測小站',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() => currentPage = '個人資料');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),

              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() => currentPage = '儀表板');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()));
              }, currentPage == '儀表板'),

              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() => currentPage = '圖書館');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LibraryPage()));
              }, currentPage == '圖書館'),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() => currentPage = '土壤濕度');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data1()));
              }, currentPage == '土壤濕度'),

              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() => currentPage = '現在溫度');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '現在溫度'),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() => currentPage = '酸鹼度');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data6()));
              }, currentPage == '酸鹼度'),

              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() => currentPage = '光照資料');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Lux()));
              }, currentPage == '光照資料'),

              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() => currentPage = '阿吉同學');
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ChatBotPage(userQuery: '')));
              }, currentPage == '阿吉同學'),

              _buildDrawerItem(Icons.insert_chart, '圖表分析', () {
                setState(() => currentPage = '圖表分析');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChartPage()));
              }, currentPage == '圖表分析'),
            ],
          ),
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSection(
                  '近五日光照時數',
                  luxChartData,
                  luxDates,
                  minLuxX,
                  maxLuxX,
                  minLuxY,
                  maxLuxY),
              _buildChartSection(
                  '近五日平均溫度',
                  tempChartData,
                  tempDates,
                  minTempX,
                  maxTempX,
                  minTempY,
                  maxTempY),
              _buildChartSection(
                '近五日平均土壤濕度',
                humidityChartData,
                humidityDates,
                minHumidityX,
                maxHumidityX,
                60,
                // 固定最小值
                100, // 固定最大值
              ),

              SizedBox(height: 30),
              _buildTomatoSuggestionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(
      String title,
      List<LineChartBarData> chartData,
      List<String> xDates,
      double minX,
      double maxX,
      double minY,
      double maxY,
      ) {
    final isHumidityChart = title.contains('土壤濕度');
    final fixedMinY = isHumidityChart ? 60.0 : minY;
    final fixedMaxY = isHumidityChart ? 100.0 : maxY;
    final yInterval = isHumidityChart ? 5.0 : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: chartData.isEmpty
                ? Center(
              child: Text(
                '無資料',
                style: TextStyle(color: Colors.white70),
              ),
            )
                : LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();

                        // ✅ 僅顯示整數位置，並避免 out of range
                        if (value % 1 != 0 || index < 0 || index >= xDates.length) {
                          return const SizedBox.shrink(); // 不顯示
                        }

                        final date = DateFormat('MM/dd').format(DateTime.parse(xDates[index]));
                        return Text(date, style: TextStyle(color: Colors.white, fontSize: 12));
                      },

                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: chartData,
                minX: minX,
                maxX: maxX,
                minY: fixedMinY,
                maxY: fixedMaxY,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTomatoSuggestionSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '番茄種植建議',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _recommendations.isEmpty
              ? Text(
            '目前尚無建議資料',
            style: TextStyle(color: Colors.white70),
          )
              : ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _recommendations.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final suggestion = _recommendations[index];
              return ListTile(
                leading: Icon(
                  _getTypeIcon(suggestion['type']),
                  color: _getPriorityColor(suggestion['priority']),
                ),
                title: Text(
                  suggestion['message'] ?? '無內容',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '類型: ${_typeToChinese(suggestion['type'])}  •  優先級: ${suggestion['priority'] ?? '-'}',
                  style:
                  TextStyle(color: Colors.white70, fontSize: 12),
                ),
                trailing: Text(
                  suggestion['timestamp'] != null
                      ? DateFormat('MM/dd HH:mm').format(
                      DateTime.parse(suggestion['timestamp']))
                      : '',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
