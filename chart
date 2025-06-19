// 加入必要 import
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
import 'package:flutter_app/pages/Dashboard.dart';  // 確保匯入路徑正確


class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<LineChartBarData> luxChartData = [];
  List<String> luxDates = [];
  List<int> luxCounts = [];

  List<LineChartBarData> tempChartData = [];
  List<String> tempDates = [];
  List<double> avgTemps = [];

  List<LineChartBarData> humidityChartData = [];
  List<String> humidityDates = [];
  List<double> avgHumidities = [];

  @override
  void initState() {
    super.initState();
    _fetchLuxData();
    _fetchTempData();
    _fetchHumidityData();
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
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      String date = data[i]['date'];
      int luxCount = data[i]['high_lux_count'];
      luxDates.add(date);
      luxCounts.add(luxCount);
      spots.add(FlSpot(i.toDouble(), luxCount.toDouble()));
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

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    double minLuxX = 0;
    double maxLuxX = luxDates.length.toDouble() - 1;
    double minLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) => a < b ? a : b).toDouble() : 0;
    double maxLuxY = luxCounts.isNotEmpty ? luxCounts.reduce((a, b) => a > b ? a : b).toDouble() : 0;

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
        title: const Text('近五日平均圖表', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
                    Text('GJH監測小站', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black)),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                Navigator.pop(context);
              }),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LibraryPage()));
              }),
              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data1()));
              }),
              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data3()));
              }),
              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Data6()));
              }),
              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Lux()));
              }),

              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotPage(userQuery: '')));
              }),

              _buildDrawerItem(Icons.show_chart, '圖表', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChartPage()));
              }),
            ],
          ),
        ),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSection('近五日光照時數', luxChartData, luxDates, minLuxX, maxLuxX, minLuxY, maxLuxY),
              _buildChartSection('近五日平均溫度', tempChartData, tempDates, minTempX, maxTempX, minTempY, maxTempY),
              _buildChartSection('近五日平均土壤濕度', humidityChartData, humidityDates, minHumidityX, maxHumidityX, minHumidityY, maxHumidityY),
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
                    getTextStyles: (value) => TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                    getTextStyles: (value) => TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    margin: 12,
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: chartData,
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
