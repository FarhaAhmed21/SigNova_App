import 'dart:convert';
import 'package:http/http.dart' as http;

class GlossService {
  static const String _apiKey = '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';

  Future<String> textToGlossJson(String sentence) async {
    final prompt = '''
You are an ASL gloss translator.

TASK:
Convert the English sentence into ASL gloss.

STRICT RULES:
1. Output ONLY space-separated gloss words.
2. Use uppercase only.
3. Remove unnecessary English function words like: IS, AM, ARE, TO, THE, A, AN.
4. Keep natural ASL structure when possible.
5. Do NOT explain.
6. Do NOT use markdown.
7. Output ONE single line only.

INPUT:
$sentence

OUTPUT:
''';

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {
            "role": "system",
            "content": "You output ONLY valid ASL gloss."
          },
          {
            "role": "user",
            "content": prompt
          }
        ],
        "temperature": 0.1
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Groq failed: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final glossLine = data['choices'][0]['message']['content']
        .toString()
        .trim();

    final glosses = glossLine
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    return jsonEncode({
      "glosses": glosses,
    });
  }
}