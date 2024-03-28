import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:lab05_example/services/image_generation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageGeneratorHome(),
    );
  }
}

class ImageGeneratorHome extends StatefulWidget {
  const ImageGeneratorHome({super.key});

  @override
  State<ImageGeneratorHome> createState() {
    return _ImageGeneratorHomeState();
  }
}

class _ImageGeneratorHomeState extends State<ImageGeneratorHome> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController(); 
  bool _isLoading = false;
  String? _imageUrl, _errorMessage;  
  final ImageGenerationService _imageGenerationService = ImageGenerationService();
  bool _isApiKeyHidden = true;

  void _toggleApiKeyVisibility() {
    setState(() {
      _isApiKeyHidden = !_isApiKeyHidden;
    });
  }

  void _generateImage(String prompt, String apiKey) async {
    setState(() {
      _isLoading = true;
      _imageUrl = null;
      _errorMessage = null;
    });

    var result = await _imageGenerationService.generateImage(prompt, apiKey);

    setState(() {
      _isLoading = false;
      if (result.containsKey('items')) {
        _imageUrl = result['items'][0]['image_resource_url'];
      } else {
        _errorMessage = 'Failed to generate image.';
      }
    });
  }

  Widget showResponse() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(_errorMessage!)),
      );
    }

    if (_imageUrl == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text('No image generated yet.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: PhotoView(
        imageProvider: NetworkImage(_imageUrl!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Generator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter prompt'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: 'Enter EdenAI API key, such as "Bearer ey..."',
                suffixIcon: IconButton(
                  icon: Icon(_isApiKeyHidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: _toggleApiKeyVisibility,
                ),
              ),
              obscureText: _isApiKeyHidden, // Use the flag to control the visibility of the API key
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if ( _controller.text.isNotEmpty && _apiKeyController.text.isNotEmpty) {
                _generateImage(_controller.text, _apiKeyController.text); // Pass the API key
              }
            },
            child: const Text('Generate Image'),
          ),
          Expanded(
            child: showResponse(),
          ),
        ],
      ),
    );
  }
}
