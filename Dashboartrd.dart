import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img; // 用於處理接收到的影像
import 'home_page.dart';  // 引入 HomePage
import 'profile_page.dart';  // 引入 ProfilePage
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  late WebSocketChannel _channel;
  img.Image? _image; // 用於顯示接收到的影像
  String objectCountText = ''; // 用來顯示物件計數

  @override
  void initState() {
    super.initState();

    // 連接 WebSocket 伺服器，請根據你的伺服器地址進行修改
    _channel = WebSocketChannel.connect(Uri.parse('ws://your-server-ip:8765'));

    // 接收 WebSocket 消息
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      final frameData = data['image']; // 獲取影像數據
      final counts = data['counts']; // 獲取物件計數

      setState(() {
        objectCountText = counts.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join('\n');

        // 解碼影像
        final bytes = base64Decode(frameData);
        _image = img.decodeImage(Uint8List.fromList(bytes)); // 解碼並顯示影像
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _channel.sink.close(); // 關閉 WebSocket 連接
  }

  @override
  Widget build(BuildContext context) {
    // 模擬數據
    final double soilTemp = 26.5;
    final double soilMoisture = 45.0;
    final double leafTemp = 41.2;
    final double co2 = 980.0;
    final double ph = 5.8;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('環境監測儀表板'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[850],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
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
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text(
                  '首頁',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white),
                title: Text(
                  '個人資料',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // 關閉側邊攔
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
      body: Column(
        children: [
          // 顯示 WebSocket 傳來的即時監控影像
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: _image != null
                ? Image.memory(Uint8List.fromList(img.encodeJpg(_image!))) // 顯示影像
                : Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          // 其他儀表板內容
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildGaugeCard(
                  title: '土壤溫度 (°C)',
                  value: soilTemp,
                  min: 0,
                  max: 50,
                  normalRange: [18, 28],
                ),
                _buildGaugeCard(
                  title: '土壤濕度 (%)',
                  value: soilMoisture,
                  min: 0,
                  max: 100,
                  normalRange: [30, 60],
                ),
                _buildGaugeCard(
                  title: '葉面溫度 (°C)',
                  value: leafTemp,
                  min: 0,
                  max: 50,
                  normalRange: [0, 40],
                ),
                _buildGaugeCard(
                  title: '碳排放 (ppm)',
                  value: co2,
                  min: 0,
                  max: 2000,
                  normalRange: [0, 1000],
                ),
                _buildGaugeCard(
                  title: '酸鹼值 (pH)',
                  value: ph,
                  min: 3,
                  max: 10,
                  normalRange: [6, 7.5],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required List<double> normalRange,
  }) {
    final bool isNormal = value >= normalRange[0] && value <= normalRange[1];
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: min,
                    maximum: max,
                    ranges: [
                      GaugeRange(
                        startValue: min,
                        endValue: normalRange[0],
                        color: Colors.red,
                      ),
                      GaugeRange(
                        startValue: normalRange[0],
                        endValue: normalRange[1],
                        color: Colors.green,
                      ),
                      GaugeRange(
                        startValue: normalRange[1],
                        endValue: max,
                        color: Colors.red,
                      ),
                    ],
                    pointers: [
                      NeedlePointer(value: value),
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isNormal ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.7,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
