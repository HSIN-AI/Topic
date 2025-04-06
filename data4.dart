import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Data4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Fetch Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataPage(),
    );
  }
}

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  String data = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://gyyonline.uk/soil_conditions/'));
    if (response.statusCode == 200) {
      setState(() {
        data = response.body; // 獲取原始 HTML 內容
      });
    } else {
      setState(() {
        data = "Failed to load data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetched Data'),
      ),
      body: SingleChildScrollView(
        child: Text(data),
      ),
    );
  }
}
