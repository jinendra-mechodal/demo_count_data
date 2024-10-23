// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'getx/video_player_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Player',
      home: VideoPlayerScreen(),
    );
  }
}
