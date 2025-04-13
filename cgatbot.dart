import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  final String userQuery;
  ChatBotPage({required this.userQuery});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 初始歡迎訊息
    messages.add({
      'role': 'bot',
      'text': '你好，我是阿吉，是你的種田小幫手，請問我有什麼可以幫助你的嗎？'
    });
    if (widget.userQuery.isNotEmpty) {
      sendMessage(widget.userQuery);
    }
  }

  void sendMessage(String question) async {
    setState(() {
      messages.add({'role': 'user', 'text': question});
      messages.add({'role': 'bot', 'text': '思考中...'});
    });

    String answer = await apiService.getAnswer(question);

    setState(() {
      messages[messages.length - 1]['text'] = answer;
    });

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 設定整個頁面的背景為白色
      appBar: AppBar(
        title: Text('阿吉同學'),
        backgroundColor: Colors.white, // 設定 AppBar 背景為白色
        foregroundColor: Colors.black, // 設定文字顏色為黑色
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200], // 保持訊息框灰色
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? '', style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '請輸入你的問題...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApiService {
  final String baseUrl = "http://192.168.31.169:8000/api/py/query";

  Future<String> getAnswer(String userQuery) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl.trim()),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": userQuery}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData["answer"];
      } else {
        return "伺服器錯誤：${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
