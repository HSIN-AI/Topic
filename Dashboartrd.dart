import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'profile_page.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';
import 'lux.dart';
import 'chart.dart';
import 'dashboard.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  String currentPage = '儀表板';

  late WebSocketChannel _channel;
  VlcPlayerController? _vlcPlayerController;
  String objectCountText = '等待物件計數...';
  bool _isStreamError = false;
  WebSocketStatus _webSocketStatus = WebSocketStatus.disconnected;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final String _webSocketUrl = 'ws://192.168.31.169:8765';
  bool _isStreamInitialized = false;

  double roomTemp = 0;
  double soilMoisture = 0;
  double ph = 0;
  double light = 0;
  String roomTempStatus = '';
  String soilMoistureStatus = '';
  String lightStatus = '';
  String phStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    if (!_isStreamInitialized) {
      _initializeStream();
      _isStreamInitialized = true;
    }
    _fetchData();
    _monitorNetworkStatus();
  }

  Map<String, dynamic>? _getLatestTodayData(List<dynamic> data, String todayStr) {
    final todayData = data.where((item) {
      final timestamp = item['timestamp']?.toString() ?? '';
      return timestamp.startsWith(todayStr);
    }).toList();

    if (todayData.isEmpty) return null;

    todayData.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    return todayData.first;
  }

  Future<void> _fetchData() async {
    try {
      final now = DateTime.now().toUtc(); // 與資料 timestamp 對齊
      final todayStr = now.toIso8601String().split('T')[0];

      // 室溫
      final tempRes = await http.get(Uri.parse('https://gyyonline.uk/temperature/'));
      if (tempRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(tempRes.body)['data'];
        final latest = _getLatestTodayData(data, todayStr);
        if (latest != null) {
          final double temp = (latest['value'] ?? 0).toDouble();
          roomTempStatus = _getRoomTempStatus(temp);
          setState(() => roomTemp = temp);
        }
      }

      // 土壤濕度
      final soilRes = await http.get(Uri.parse('https://gyyonline.uk/soil_moisture/'));
      if (soilRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(soilRes.body)['data'];
        final latest = _getLatestTodayData(data, todayStr);
        if (latest != null) {
          final double rawValue = (latest['value'] ?? 0).toDouble();
          final double calculatedMoisture = ((462 - rawValue) / (462 - 205)) * 100;
          soilMoistureStatus = _getSoilMoistureStatus(calculatedMoisture);
          setState(() => soilMoisture = calculatedMoisture.clamp(0, 100));
        }
      }

      // 酸鹼值
      final phRes = await http.get(Uri.parse('https://gyyonline.uk/ph_data/'));
      if (phRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(phRes.body)['data'];
        final latest = _getLatestTodayData(data, todayStr);
        if (latest != null) {
          final double phValue = (latest['value'] ?? 0).toDouble();
          phStatus = _getPhStatus(phValue);
          setState(() => ph = phValue);
        }
      }

      // 光照
      final luxRes = await http.get(Uri.parse('https://gyyonline.uk/lux/'));
      if (luxRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(luxRes.body)['data'];
        final latest = _getLatestTodayData(data, todayStr);
        if (latest != null) {
          final double luxValue = (latest['value'] ?? 0).toDouble();
          lightStatus = luxValue > 800 ? '開' : '關';
          setState(() => light = luxValue);
        }
      }
    } catch (e) {
      print('讀取感測器資料失敗: $e');
    }
  }


  void _monitorNetworkStatus() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        setState(() => _isStreamError = true);
      } else {
        if (_isStreamError) _initializeStream();
      }
    });
  }

  void _initializeWebSocket() => reconnectWebSocket();

  void reconnectWebSocket() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      setState(() {
        _webSocketStatus = WebSocketStatus.error;
        objectCountText = '無法連接到 WebSocket 伺服器';
      });
      return;
    }
    setState(() {
      _webSocketStatus = WebSocketStatus.connecting;
      objectCountText = '正在連線到 WebSocket...';
    });
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      _channel.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final counts = data['counts'];
      setState(() {
        _webSocketStatus = WebSocketStatus.connected;
        _reconnectAttempts = 0;
        objectCountText = counts.entries.map((e) => '\${e.key}: \${e.value}').join('\n');
      });
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  void _handleWebSocketError(error) {
    setState(() {
      _webSocketStatus = WebSocketStatus.error;
      objectCountText = '連線錯誤，重試中...';
    });
    _reconnectAttempts++;
    Future.delayed(const Duration(seconds: 5), reconnectWebSocket);
  }

  void _handleWebSocketDone() {
    setState(() {
      _webSocketStatus = WebSocketStatus.disconnected;
      objectCountText = '連線斷開，重試中...';
    });
    _reconnectAttempts++;
    Future.delayed(const Duration(seconds: 5), reconnectWebSocket);
  }

  Future<void> _initializeStream() async {
    if (kIsWeb) {
      setState(() {
        _isStreamError = true;
        objectCountText = 'Web 環境不支援 HLS 串流';
      });
      return;
    }
    _vlcPlayerController?.dispose();
    setState(() {
      _isStreamError = false;
      objectCountText = '正在載入串流...';
    });
    _vlcPlayerController = VlcPlayerController.network(
      'https://9e1f-106-105-83-78.ngrok-free.app/stream/stream.m3u8',
      autoPlay: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(1500)]),
        http: VlcHttpOptions([VlcHttpOptions.httpReconnect(true)]),
      ),
      onInit: () => setState(() => objectCountText = '串流已加載'),
    );
    _vlcPlayerController!.addListener(() {
      if (_vlcPlayerController!.value.hasError) {
        setState(() {
          _isStreamError = true;
          objectCountText = '串流錯誤，正在重試...';
        });
      }
    });
  }

  String _getRoomTempStatus(double temp) =>
      temp > 25 ? '溫度過高' : temp < 20 ? '溫度過低' : '正常';
  String _getSoilMoistureStatus(double m) =>
      m > 385 ? '乾燥' : m < 290 ? '過濕' : '濕潤';
  String _getPhStatus(double p) =>
      (p < 5.6 || p > 6.7) ? '酸鹼值異常' : '正常';

  String _getWebSocketStatusText() {
    switch (_webSocketStatus) {
      case WebSocketStatus.connecting:
        return '正在連線到 WebSocket...';
      case WebSocketStatus.connected:
        return 'WebSocket 已連線';
      case WebSocketStatus.disconnected:
        return 'WebSocket 已斷線';
      case WebSocketStatus.error:
        return 'WebSocket 連線失敗';
    }
  }


  @override
  void dispose() {
    _vlcPlayerController?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // ⬅️ 加這行
        title: const Text(
          '環境監測儀表板',
          style: TextStyle(color: Colors.white), // ⬅️ 確保標題文字也是白色
        ),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: Container(
          color: const Color(0xFFF1F1F1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/images/gkhlogo.png')),
                    const SizedBox(height: 10),
                    Text(
                      'GKH監測小站',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                setState(() => currentPage = '個人資料');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              }, currentPage == '個人資料'),

              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() => currentPage = '儀表板');
                Navigator.pop(context);
              }, currentPage == '儀表板'),

              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() => currentPage = '圖書館');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LibraryPage()));
              }, currentPage == '圖書館'),

              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() => currentPage = '土壤濕度');
                Navigator.push(context, MaterialPageRoute(builder: (_) => Data1()));
              }, currentPage == '土壤濕度'),

              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() => currentPage = '現在溫度');
                Navigator.push(context, MaterialPageRoute(builder: (_) => Data3()));
              }, currentPage == '現在溫度'),

              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() => currentPage = '酸鹼度');
                Navigator.push(context, MaterialPageRoute(builder: (_) => Data6()));
              }, currentPage == '酸鹼度'),

              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() => currentPage = '光照資料');
                Navigator.push(context, MaterialPageRoute(builder: (_) => Lux()));
              }, currentPage == '光照資料'),

              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() => currentPage = '阿吉同學');
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotPage(userQuery: '')));
              }, currentPage == '阿吉同學'),

              _buildDrawerItem(Icons.insert_chart, '圖表分析', () {
                setState(() => currentPage = '圖表分析');
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChartPage()));
              }, currentPage == '圖表分析'),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: kIsWeb
                ? const Center(child: Text('Web 環境不支援 RTSP 串流', style: TextStyle(color: Colors.white, fontSize: 16)))
                : (_vlcPlayerController == null || _isStreamError
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : VlcPlayer(
              controller: _vlcPlayerController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator(color: Colors.white)),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(_getWebSocketStatusText(),
                    style: TextStyle(color: _webSocketStatus == WebSocketStatus.error ? Colors.red : Colors.white)),
                const SizedBox(height: 8),
                Text(objectCountText, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildGaugeCard(title: '室溫 (°C)', value: roomTemp, min: 0, max: 50, normalRange: [20, 25]),
                _buildGaugeCard(title: '土壤濕度 (%)', value: soilMoisture, min: 0, max: 100, normalRange: [30, 60]),
                _buildGaugeCard(title: '酸鹼值 (pH)', value: ph, min: 3, max: 10, normalRange: [5.6, 6.7]),
                _buildGaugeCard(title: '光照 (%)', value: light, min: 0, max: 1000, normalRange: [0, 800]),
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
    final isNormal = value >= normalRange[0] && value <= normalRange[1];
    final bool isLight = title.contains('光照');
    final String statusText = isLight ? '狀態: $lightStatus' : '';
    final Color statusColor = isLight
        ? (lightStatus == '開' ? Colors.white : Colors.grey)
        : (isNormal ? Colors.greenAccent : Colors.redAccent);
    final Color pointerColor = Colors.grey;

    final List<GaugeRange> gaugeRanges = isLight
        ? [
      GaugeRange(startValue: min, endValue: 800, color: Colors.red),
      GaugeRange(startValue: 800, endValue: max, color: Colors.green),
    ]
        : [
      GaugeRange(startValue: min, endValue: normalRange[0], color: Colors.red),
      GaugeRange(startValue: normalRange[0], endValue: normalRange[1], color: Colors.green),
      GaugeRange(startValue: normalRange[1], endValue: max, color: Colors.red),
    ];

    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (isLight)
              Text(
                statusText,
                style: TextStyle(
                  color: lightStatus == '開' ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: min,
                    maximum: max,
                    ranges: gaugeRanges,
                    pointers: [
                      NeedlePointer(
                        value: value,
                        needleColor: pointerColor,
                        knobStyle: KnobStyle(color: pointerColor),
                        needleLength: 0.6,
                        needleStartWidth: 2,
                        needleEndWidth: 4,
                      )
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
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



  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isActive) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: GoogleFonts.inter(fontSize: 18, color: Colors.black)),
        tileColor: isActive ? const Color(0xFF9E9E9E) : Colors.white,
        onTap: onTap,
      ),
    );
  }
}

enum WebSocketStatus { connecting, connected, disconnected, error }
