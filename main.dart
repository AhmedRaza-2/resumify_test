import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AIResumePage(),
    );
  }
}

class AIResumePage extends StatefulWidget {
  const AIResumePage({Key? key}) : super(key: key);

  @override
  _AIResumePageState createState() => _AIResumePageState();
}

class _AIResumePageState extends State<AIResumePage> {
  final TextEditingController _messageController = TextEditingController();
  String _response = ''; // To hold AI's response
  bool _isLoading = false;

  // Directly set your Gemini API key here
  final apiKey = 'AIzaSyBmQV8k8qppWK6IwoOGBSqtlL-DsayHNzY';

  // Function to generate resume using the API
  Future<void> _generateResume() async {
    setState(() {
      _isLoading = true;
      _response = ''; // Clear previous response
    });

    // Initialize the Generative Model with the API key and configuration
    final model = GenerativeModel(
      model: 'gemini-1.5-flash', // Specify the model you are using
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.5,          // Lower temperature for faster, more deterministic responses
        topK: 10,                 // Reduce the number of possible options to speed up response
        topP: 0.85,               // Narrow the possibilities, keeping it slightly lower
        maxOutputTokens: 500,     // Reduce token output to get a smaller response quickly
        responseMimeType: 'text/plain', // Optional, remove if unnecessary for testing
      ),
    );

    // Start a chat session with history (can be left empty or filled)
    final chat = model.startChat(history: []);

    // Define the input message for the AI to generate a response
    final message = _messageController.text.isEmpty
        ? 'Can you generate a resume for a software developer?'
        : _messageController.text;

    final content = Content.text(message);

    // Send the message and await a response
    try {
      final response = await chat.sendMessage(content);

      setState(() {
        // Check if the response has text, otherwise set an error message
        if (response is GenerateContentResponse) {
          _response = response.text ?? 'No text found in response';
        } else {
          _response = 'Invalid response format';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Resume Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input text box
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Enter your request:',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Button to generate resume
            ElevatedButton(
              onPressed: _generateResume,
              child: const Text('Generate Resume'),
            ),
            const SizedBox(height: 20),

            // Display loading indicator if generating
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
            // Result text box for the AI response
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response.isEmpty ? 'Waiting for AI response...' : _response,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}