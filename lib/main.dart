// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(MaterialApp(
    home: HateDetectPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HateDetectPage extends StatefulWidget {
  @override
  _HateDetectPageState createState() => _HateDetectPageState();
}

class _HateDetectPageState extends State<HateDetectPage> {
  TextEditingController _textController = TextEditingController();
  String _output = '';
  String _emojiData = ''; // Store emoji data here

  Future<void> detectHateSpeech(String text) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/detect_hate_speech'), // Replace with your Flask API URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        String result = json.decode(response.body);
        _output = result;
        _emojiData = result == 'Hate Speech' ? '😡' : '😊'; // Emoji data based on hate speech detection result
      });
    } else {
      setState(() {
        _output = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hate-Detect'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hate-Detect',
              style: TextStyle(fontFamily: 'Oswald',fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.red[900]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  labelText: 'Enter Text',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.purple), // Change the color of the input label
                  hintStyle: TextStyle(color: Colors.blue)
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String inputText = _textController.text.trim();
                if (inputText.isNotEmpty) {
                  detectHateSpeech(inputText);
                }
              },
              child: Text('Detect'),
            ),
            SizedBox(height: 20.0),
            Text(
              style: TextStyle(fontSize: 20.0, color: Colors.orange),
              _output+_emojiData,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),



          ],
        ),
      ),
    );
  }
}
