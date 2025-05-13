import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'library_page.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  late WebSocketChannel _channel;
  VlcPlayerController? _vlcPlayerController;
  String objectCountText = '等待物件計數...';
  String _streamUrl = '';
  bool _isStreamError = false;
  WebSocketStatus _webSocketStatus = WebSocketStatus.disconnected;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final String _webSocketUrl = 'ws://192.168.31.169:8765';

  // 初始化資料變數
  double roomTemp = 0;
  double soilMoisture = 0;
  double co2 = 0;
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
    _initializeStream();
    _fetchData();  // Fetch data from the API
  }

  // WebSocket初始化
  void _initializeWebSocket() {
    reconnectWebSocket();
  }

  void reconnectWebSocket() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      setState(() {
        _webSocketStatus = WebSocketStatus.error;
        objectCountText = '無法連接到 WebSocket 伺服器';
      });
      print('達到最大重試次數，停止重連');
      return;
    }

    print('嘗試連接到 WebSocket: $_webSocketUrl (第 ${_reconnectAttempts + 1} 次)');
    setState(() {
      _webSocketStatus = WebSocketStatus.connecting;
      objectCountText = '正在連線到 WebSocket...';
    });

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      print('WebSocket 連線初始化成功');
      _channel.stream.listen(
            (message) {
          print('收到 WebSocket 訊息: $message');
          try {
            final data = jsonDecode(message);
            final counts = data['counts'];
            setState(() {
              _webSocketStatus = WebSocketStatus.connected;
              _reconnectAttempts = 0;
              objectCountText = counts.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join('\n');
            });
            print('成功解析並更新物件計數');
          } catch (e) {
            print('JSON 解析錯誤: $e');
            setState(() {
              objectCountText = '資料格式錯誤';
              _webSocketStatus = WebSocketStatus.error;
            });
          }
        },
        onError: (error) {
          print('WebSocket 錯誤: $error');
          setState(() {
            _webSocketStatus = WebSocketStatus.error;
            objectCountText = '連線錯誤，重試中...';
          });
          _reconnectAttempts++;
          Future.delayed(Duration(seconds: 5), reconnectWebSocket);
        },
        onDone: () {
          print('WebSocket 連線關閉');
          setState(() {
            _webSocketStatus = WebSocketStatus.disconnected;
            objectCountText = '連線斷開，重試中...';
          });
          _reconnectAttempts++;
          Future.delayed(Duration(seconds: 5), reconnectWebSocket);
        },
      );
    } catch (e) {
      print('WebSocket 初始化錯誤: $e');
      setState(() {
        _webSocketStatus = WebSocketStatus.error;
        objectCountText = '連線初始化失敗';
      });
      _reconnectAttempts++;
      Future.delayed(Duration(seconds: 5), reconnectWebSocket);
    }
  }

  // 初始化串流
  Future<void> _initializeStream() async {
    if (kIsWeb) {
      setState(() {
        _isStreamError = true;
        objectCountText = 'Web 環境不支援 HLS 串流'; // 修改為 HLS
      });
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    await _updateStreamUrl(connectivityResult);

    _vlcPlayerController = VlcPlayerController.network(
      _streamUrl,  // 使用 HLS URL
      autoPlay: true,
      onInit: () {
        setState(() {});
      },
    );

    _vlcPlayerController!.addListener(() {
      if (_vlcPlayerController!.value.hasError) {
        setState(() {
          _isStreamError = true;
          objectCountText = '無法載入 HLS 串流'; // 修改為 HLS
        });
        print('VLC 串流錯誤: ${_vlcPlayerController!.value.errorDescription}');
      } else if (_vlcPlayerController!.value.isPlaying) {
        if (_isStreamError) {
          setState(() {
            _isStreamError = false;
          });
        }
      }
    });
  }

  // 更新串流 URL
  Future<void> _updateStreamUrl(List<ConnectivityResult> result) async {
    if (kIsWeb) return;

    setState(() {
      if (result.contains(ConnectivityResult.wifi)) {
        _streamUrl = 'https://9a94-106-105-83-78.ngrok-free.app/stream/stream.m3u8'; // HLS URL
      } else {
        _streamUrl = 'https://9a94-106-105-83-78.ngrok-free.app/stream/stream.m3u8'; // HLS URL
      }
    });
  }

  // 取得即時資料
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://gyyonline.uk/avg_all/?date=2025-05-07'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _processData(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 處理 API 資料
  void _processData(List<dynamic> data) {
    double temp = 0;
    double moisture = 0;
    double co2Value = 0;
    double phValue = 0;
    double lightValue = 0;

    for (var item in data) {
      switch (item['type_id']) {
        case 1: // 室溫
          temp = item['avg_value'];
          roomTempStatus = _getRoomTempStatus(temp);
          break;
        case 2: // 土壤濕度
          moisture = item['avg_value'];
          soilMoistureStatus = _getSoilMoistureStatus(moisture);
          break;
        case 5: // 碳排放
          co2Value = item['avg_value'];
          break;
        case 4: // 酸鹼值
          phValue = item['avg_value'];
          phStatus = _getPhStatus(phValue);
          break;
        case 3: // 光照
          lightValue = item['avg_value'];
          lightStatus = lightValue > 800 ? "開" : "關";
          break;
      }
    }

    setState(() {
      roomTemp = temp;
      soilMoisture = moisture;
      co2 = co2Value;
      ph = phValue;
      light = lightValue;
    });
  }

  // 室溫狀態判斷
  String _getRoomTempStatus(double temp) {
    if (temp > 25) return '溫度過高';
    if (temp < 20) return '溫度過低';
    return '正常';
  }

  // 土壤濕度狀態判斷
  String _getSoilMoistureStatus(double moisture) {
    if (moisture > 385) return '乾燥';
    if (moisture < 290) return '過濕';
    return '濕潤';
  }

  // 酸鹼值狀態判斷
  String _getPhStatus(double phValue) {
    if (phValue < 5.6 || phValue > 6.7) return '酸鹼值異常';
    return '正常';
  }

  // 顯示 WebSocket 連線狀態
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

  // 儀表盤顯示
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

  @override
  void dispose() {
    if (!kIsWeb) _vlcPlayerController?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('環境監測儀表板'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1), // Modify the drawer background color here
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/gkhlogo.png'), // 這裡是新的 logo 圖片
                    ),
                    SizedBox(height: 10),
                    Text(
                      'GJH監測小站', // 顯示新的標題
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              _buildDrawerItem(Icons.account_circle, '個人資料', () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                Navigator.pop(context);
              }),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LibraryPage()),
                );
              }),
              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data1()));
              }),
              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }),
              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data6()));
              }),
              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                Navigator.pop(context);
              }),
              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatBotPage(userQuery: '')));
              }),
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
                ? Center(
              child: Text(
                'Web 環境不支援 RTSP 串流',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : (_vlcPlayerController == null || _isStreamError
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : VlcPlayer(
              controller: _vlcPlayerController!,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator(color: Colors.white)),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  _getWebSocketStatusText(),
                  style: TextStyle(
                    color: _webSocketStatus == WebSocketStatus.error
                        ? Colors.red
                        : Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  objectCountText,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
                _buildGaugeCard(
                  title: '室溫 (°C)',
                  value: roomTemp,
                  min: 0,
                  max: 50,
                  normalRange: [20, 25],
                ),
                _buildGaugeCard(
                  title: '土壤濕度 (%)',
                  value: soilMoisture,
                  min: 0,
                  max: 100,
                  normalRange: [30, 60],
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
                  normalRange: [5.6, 6.7],
                ),
                _buildGaugeCard(
                  title: '光照 (%)',
                  value: light,
                  min: 0,
                  max: 1000,
                  normalRange: [0, 800],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}

enum WebSocketStatus { connecting, connected, disconnected, error }

void main() {
  runApp(MaterialApp(home: SensorDashboard()));
}
