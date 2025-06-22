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
    messages.add({
      'role': 'bot',
      'text': '你好，我是阿吉，是你的種田小幫手，請問我有什麼可以幫助你的嗎？',
      'confidence': ''
    });
    if (widget.userQuery.isNotEmpty) {
      sendMessage(widget.userQuery);
    }
  }

  void sendMessage(String question) async {
    setState(() {
      messages.add({'role': 'user', 'text': question, 'confidence': ''});
      messages.add({'role': 'bot', 'text': '思考中...', 'confidence': ''});
    });

    final response = await apiService.getAnswer(question);

    setState(() {
      messages[messages.length - 1] = {
        'role': 'bot',
        'text': response['answer'],
        'confidence': response['confidence']
      };
    });

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) {
      return Colors.green;
    } else if (confidence >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('阿吉同學'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (!isUser &&
                            msg.containsKey('confidence') &&
                            msg['confidence']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '💡 回答信心指數：${msg['confidence']}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getConfidenceColor(double.tryParse(msg['confidence']!) ?? 0.0),
                              ),
                            ),
                          ),
                      ],
                    ),
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

  Future<Map<String, dynamic>> getAnswer(String userQuery) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl.trim()),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": userQuery}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          "answer": data["answer"],
          "confidence": data["confidence"].toStringAsFixed(1)
        };
      } else {
        return {
          "answer": "伺服器錯誤：${response.statusCode}",
          "confidence": "0.0"
        };
      }
    } catch (e) {
      return {
        "answer": "Error: $e",
        "confidence": "0.0"
      };
    }
  }
}
