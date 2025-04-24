import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'home_page.dart';
import 'profile_page.dart';
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
  VlcPlayerController? _vlcPlayerController;
  String objectCountText = '等待物件計數...';
  String _streamUrl = '';
  bool _isStreamError = false;
  WebSocketStatus _webSocketStatus = WebSocketStatus.disconnected;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final String _webSocketUrl = 'ws://192.168.31.169:8765';

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _initializeStream();
  }

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

  Future<void> _initializeStream() async {
    if (kIsWeb) {
      setState(() {
        _isStreamError = true;
        objectCountText = 'Web 環境不支援 RTSP 串流';
      });
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    await _updateStreamUrl(connectivityResult);

    _vlcPlayerController = VlcPlayerController.network(
      _streamUrl,
      autoPlay: true,
      onInit: () {
        setState(() {});
      },
    );

    _vlcPlayerController!.addListener(() {
      if (_vlcPlayerController!.value.hasError) {
        setState(() {
          _isStreamError = true;
          objectCountText = '無法載入 RTSP 串流';
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

  Future<void> _updateStreamUrl(List<ConnectivityResult> result) async {
    if (kIsWeb) return;

    setState(() {
      if (result.contains(ConnectivityResult.wifi)) {
        _streamUrl = 'rtsp://3B117161:3B117161@192.168.31.50:554/stream1';
      } else {
        _streamUrl = 'rtsp://3B117161:3B117161@your_public_ip:554/stream1';
      }
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) _vlcPlayerController?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white),
                title: Text(
                  '個人資料',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
              placeholder: Center(
                  child: CircularProgressIndicator(color: Colors.white)),
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

enum WebSocketStatus { connecting, connected, disconnected, error }

void main() {
  runApp(MaterialApp(home: SensorDashboard()));
}
