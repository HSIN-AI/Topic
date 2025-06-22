import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'dashboard.dart';
import 'data_1.dart';
import 'data_3.dart';
import 'data_5.dart';
import 'data_6.dart';
import 'cgatbot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chart.dart';


class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  String currentPage = '圖書館';

  int selectedTypeId = 3;

  final Map<int, String> typeNames = {
    1: '環境溫度',
    3: '土壤溼度',
    4: '酸鹼度',
    6: '光照資料',
  };

  String formatValue(int typeId, dynamic value) {
    if (value == null) return '-';
    switch (typeId) {
      case 1:
        return '$value 攝氏溫度(℃)';
      case 3:
        return '$value 單位(%)';
      case 4:
        return '$value 酸鹼度(pH)';
      case 6:
        return '$value 光照資料';
      default:
        return value.toString();
    }
  }

  Color getRowColor(Map<String, dynamic> item) {
    int typeId = item['type_id'] ?? 0;
    dynamic val = item['value'];
    Color rowColor = Colors.white;

    if (val == null) return rowColor;

    num rawValue;
    try {
      if (val is num) {
        rawValue = val;
      } else if (val is String) {
        rawValue = num.parse(val);
      } else {
        return rowColor;
      }
    } catch (e) {
      return rowColor;
    }

    switch (typeId) {
      case 3:
        if (rawValue > 385) {
          rowColor = Colors.red.withOpacity(0.2);
        } else if (rawValue >= 290 && rawValue <= 380) {
          rowColor = Colors.white;
        } else if (rawValue >= 0 && rawValue < 290) {
          rowColor = Colors.blue.withOpacity(0.3);
        } else {
          rowColor = Colors.red.withOpacity(0.3);
        }
        break;
      case 1:
        if (rawValue > 25) {
          rowColor = Colors.red.withOpacity(0.3);
        } else if (rawValue < 20) {
          rowColor = Colors.blue.withOpacity(0.3);
        } else {
          rowColor = Colors.white;
        }
        break;
      case 4:
        if (rawValue < 5.6 || rawValue > 6.7) {
          rowColor = Colors.red.withOpacity(0.3);
        } else {
          rowColor = Colors.white;
        }
        break;
      case 6:
        if (rawValue > 800) {
          rowColor = Colors.grey.withOpacity(0.3);
        } else {
          rowColor = Colors.white;
        }
        break;
      default:
        rowColor = Colors.white;
        break;
    }

    return rowColor;
  }

  Future<void> fetchData(DateTime date, int typeId) async {
    setState(() {
      isLoading = true;
    });

    final String dateString =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final Uri url = Uri.parse('https://gyyonline.uk/data_by_date/?date=$dateString');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List dataList = responseData['data'];

          List filtered = dataList.where((item) {
            final int tid = item['type_id'] ?? 0;
            return tid == typeId && tid != 2;
          }).toList();

          setState(() {
            data = filtered.map<Map<String, dynamic>>((item) {
              return {
                'sno': item['sno'] ?? 'No Sno',
                'type_id': item['type_id'] ?? 0,
                'timestamp': item['timestamp'] ?? 'No Timestamp',
                'value': item['value'] ?? '-',
              };
            }).toList();
          });
        } else {
          setState(() {
            data = [];
          });
        }
      } else {
        setState(() {
          data = [];
        });
      }
    } catch (error) {
      setState(() {
        data = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await fetchData(selectedDate, selectedTypeId);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(selectedDate, selectedTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF1F1F1),
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
                      backgroundImage: AssetImage('assets/images/gkhlogo.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'GKH監測小站',
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
                setState(() {
                  currentPage = '個人資料';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              }, currentPage == '個人資料'),
              _buildDrawerItem(Icons.dashboard, '儀表板', () {
                setState(() {
                  currentPage = '儀表板';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SensorDashboard()));
              }, currentPage == '儀表板'),
              _buildDrawerItem(Icons.library_books, '圖書館', () {
                setState(() {
                  currentPage = '圖書館';
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LibraryPage()));
              }, currentPage == '圖書館'),
              _buildDrawerItem(Icons.wb_sunny, '土壤濕度', () {
                setState(() {
                  currentPage = '土壤濕度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data1()));
              }, currentPage == '土壤濕度'),
              _buildDrawerItem(Icons.thermostat, '現在溫度', () {
                setState(() {
                  currentPage = '現在溫度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data3()));
              }, currentPage == '現在溫度'),
              _buildDrawerItem(Icons.water_drop, '酸鹼度', () {
                setState(() {
                  currentPage = '酸鹼度';
                });
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Data6()));
              }, currentPage == '酸鹼度'),
              _buildDrawerItem(Icons.lightbulb, '光照資料', () {
                setState(() {
                  currentPage = '光照資料';
                });
                Navigator.pop(context);
              }, currentPage == '光照資料'),
              _buildDrawerItem(Icons.chat_bubble, '阿吉同學', () {
                setState(() {
                  currentPage = '阿吉同學';
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatBotPage(userQuery: '')));
              }, currentPage == '阿吉同學'),
              _buildDrawerItem(Icons.insert_chart, '圖表分析', () {
                setState(() {
                  currentPage = '圖表分析';
                });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartPage()));
              }, currentPage == '圖表分析'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFB0B0B0),
        title: Text(currentPage),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "選擇日期: ${selectedDate.toLocal()}".split(' ')[0],
                        style:
                        GoogleFonts.inter(fontSize: 18, color: Color(0xFF616161)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB0B0B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _selectDate(context),
                        child: Text('選擇日期', style: GoogleFonts.inter(fontSize: 16)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('資料類型: ', style: GoogleFonts.inter(fontSize: 16)),
                          SizedBox(width: 12),
                          DropdownButton<int>(
                            value: selectedTypeId,
                            items: typeNames.entries
                                .map((entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                                .toList(),
                            onChanged: (int? newVal) async {
                              if (newVal != null && newVal != selectedTypeId) {
                                setState(() {
                                  selectedTypeId = newVal;
                                });
                                await fetchData(selectedDate, selectedTypeId);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : data.isEmpty
                      ? Center(
                      child: Text('沒有資料',
                          style: TextStyle(fontSize: 18, color: Colors.red)))
                      : isMobile
                      ? _buildMobileList()
                      : _buildWebTable(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final typeId = item['type_id'];
        final rowColor = getRowColor(item);

        final backgroundColor = (rowColor == Colors.white || rowColor == Colors.transparent)
            ? Colors.white
            : rowColor;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${typeNames[typeId] ?? typeId.toString()}',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text('時間戳: ${item['timestamp']}', style: GoogleFonts.inter(fontSize: 14)),
              Text('感測器: ${item['sno']}', style: GoogleFonts.inter(fontSize: 14)),
              Text('數值: ${formatValue(typeId, item['value'])}', style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(
            label: Text('資料類型',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          DataColumn(
            label: Text('時間戳',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          DataColumn(
            label: Text('感測器',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          DataColumn(
            label: Text('數值',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
        rows: data.map((item) {
          final int typeId = item['type_id'];
          return DataRow(
            color: MaterialStateProperty.all(getRowColor(item)),
            cells: [
              DataCell(Text(typeNames[typeId] ?? typeId.toString())),
              DataCell(Text(item['timestamp'].toString())),
              DataCell(Text(item['sno'].toString())),
              DataCell(Text(formatValue(typeId, item['value']))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon, String title, VoidCallback onTap, bool isActive) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {});
      },
      onExit: (_) {
        setState(() {});
      },
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
}
