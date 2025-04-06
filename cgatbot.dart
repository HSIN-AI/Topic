import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ 請確認這是你的本機 IP 並且手機/模擬器跟它在同一個 Wi-Fi
  final String baseUrl = "http://192.168.31.169:8000/api/py/query";

  Future<String> getAnswer(String userQuery) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl.trim()), // 加 .trim() 保險移除意外空白
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
      return "發生錯誤：$e";
    }
  }
}
