import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  // Replace with your Claude API key
  static const _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';
  static const _url = 'https://api.anthropic.com/v1/messages';

  static Future<String> chat({
    required List<Map<String, String>> messages,
    required String systemPrompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 500,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return 'Sorry, I could not connect right now. Please check your API key and try again.';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }
}
