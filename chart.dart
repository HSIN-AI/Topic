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

  final List<Map<String, dynamic>> _dummySuggestions = [
    {
      "suggestion_type": "灌溉",
      "message": "土壤濕度過低，建議今晚灌溉 10 分鐘",
      "priority": "高",
      "timestamp": "2025-06-19T08:00:00"
    },
    {
      "suggestion_type": "施肥",
      "message": "土壤偏酸，建議施用 100g/m² 石灰",
      "priority": "中",
      "timestamp": "2025-06-18T12:00:00"
    },
    {
      "suggestion_type": "環境調整",
      "message": "溫度過高，建議開啟通風設備",
      "priority": "高",
      "timestamp": "2025-06-19T07:30:00"
    },
  ];

  // 2️⃣ 新增 Data1 風格的 DrawerItem 建構器
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isActive) {
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



  Timer? _refreshTimer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _fetchLuxData(),
        _fetchTempData(),
        _fetchHumidityData(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('資料載入失敗，請稍後再試')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchLuxData() async {
    final response = await http.get(Uri.parse('https://gyyonline.uk/lux/daily_duration/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processLuxData(data['data']);
    } else {
      throw Exception('無法載入光照資料');
    }
  }

  Future<void> _fetchTempData() async {
    final response = await http.get(Uri.parse('https://gyyonline.uk/temperature/daily_avg/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processTempData(data['data']);
    } else {
      throw Exception('無法載入溫度資料');
    }
  }

  Future<void> _fetchHumidityData() async {
    final response = await http.get(Uri.parse('https://gyyonline.uk/humidity/daily_avg/'));
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
          colors: [Colors.blue],
          isStrokeCapRound: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    });
  }


  void _processTempData(List<dynamic> data) {
    tempDates.clear();
    avgTemps.clear();
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      String date = data[i]['date'];
      double avgTemp = data[i]['avg_temp'];
      tempDates.add(date);
      avgTemps.add(avgTemp);
      spots.add(FlSpot(i.toDouble(), avgTemp));
    }
    setState(() {
      tempChartData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: [Colors.orange],
          isStrokeCapRound: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    });
  }

  void _processHumidityData(List<dynamic> data) {
    humidityDates.clear();
    avgHumidities.clear();
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      String date = data[i]['date'];
      double avgHumidity = data[i]['avg_humidity'].toDouble();
      humidityDates.add(date);
      avgHumidities.add(avgHumidity);
      spots.add(FlSpot(i.toDouble(), avgHumidity));
    }
    setState(() {
      humidityChartData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: [Colors.green],
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
    double minLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) => a < b ? a : b).toDouble() / 2 : 0;
    double maxLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) => a > b ? a : b).toDouble() / 2 : 0;

    double minTempX = 0;
    double maxTempX = tempDates.length.toDouble() - 1;
    double minTempY = avgTemps.isNotEmpty ? avgTemps.reduce((a, b) => a < b ? a : b) - 3 : 0;
    double maxTempY = avgTemps.isNotEmpty ? avgTemps.reduce((a, b) => a > b ? a : b) + 3 : 0;

    double minHumidityX = 0;
    double maxHumidityX = humidityDates.length.toDouble() - 1;
    double minHumidityY = avgHumidities.isNotEmpty ? avgHumidities.reduce((a, b) => a < b ? a : b) - 5 : 0;
    double maxHumidityY = avgHumidities.isNotEmpty ? avgHumidities.reduce((a, b) => a > b ? a : b) + 5 : 100;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('近五日平均圖表與番茄建議', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
                    CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/images/gkhlogo.png')),
                    SizedBox(height: 10),
                    Text(
                      'GKH監測小站',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() => currentPage = '個人資料');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),

              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() => currentPage = '儀表板');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SensorDashboard()));
              }, currentPage == '儀表板'),

              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() => currentPage = '圖書館');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LibraryPage()));
              }, currentPage == '圖書館'),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() => currentPage = '土壤濕度');
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data1()));
              }, currentPage == '土壤濕度'),

              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() => currentPage = '現在溫度');
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '現在溫度'),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() => currentPage = '酸鹼度');
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data6()));
              }, currentPage == '酸鹼度'),

              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() => currentPage = '光照資料');
                Navigator.push(context, MaterialPageRoute(builder: (context) => Lux()));
              }, currentPage == '光照資料'),

              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() => currentPage = '阿吉同學');
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotPage(userQuery: '')));
              }, currentPage == '阿吉同學'),

              _buildDrawerItem(Icons.insert_chart, '圖表分析', () {
                setState(() => currentPage = '圖表分析');
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChartPage()));
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
              _buildChartSection('近五日光照時數', luxChartData, luxDates, minLuxX, maxLuxX, minLuxY, maxLuxY),
              _buildChartSection('近五日平均溫度', tempChartData, tempDates, minTempX, maxTempX, minTempY, maxTempY),
              _buildChartSection(
                '近五日平均土壤濕度',
                humidityChartData,
                humidityDates,
                minHumidityX,
                maxHumidityX,
                60,  // 固定最小值
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
    // 濕度圖表強制設定 Y 軸 60~100 每 5 單位
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTextStyles: (value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    getTitles: (value) {
                      int index = value.toInt();
                      if (index >= 0 && index < xDates.length) {
                        return DateFormat('MM/dd').format(DateTime.parse(xDates[index]));
                      }
                      return '';
                    },
                    margin: 12,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    interval: yInterval,
                    getTextStyles: (value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    margin: 12,
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
            style: TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _dummySuggestions.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final suggestion = _dummySuggestions[index];
              return ListTile(
                leading: Icon(
                  Icons.agriculture,
                  color: suggestion['priority'] == '高' ? Colors.redAccent : Colors.amber,
                ),
                title: Text(
                  suggestion['message'] ?? '無內容',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '類型: ${suggestion['suggestion_type'] ?? '未知'}  •  優先級: ${suggestion['priority'] ?? '-'}',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                trailing: Text(
                  suggestion['timestamp'] != null
                      ? DateFormat('MM/dd HH:mm').format(DateTime.parse(suggestion['timestamp']))
                      : '',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
