import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageGenerationService {
  static const String _url = 'https://api.edenai.run/v2/image/generation';
  
  Future<Map<String, dynamic>> generateImage(String prompt, String apiKey) async {
    var headers = {
      'Authorization': apiKey,
      'Content-Type': 'application/json',
    }; 

    var payload = {
      'providers': 'replicate',
      'text': prompt,
      'resolution': '512x512',
      'num_images': 1,
      'fallback_providers': ''
    };
    
    var response = await http.post(
      Uri.parse(_url),
      headers:headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['replicate'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};
    }
  }
}
