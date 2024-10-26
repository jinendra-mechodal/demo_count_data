// // lib/main.dart
// import 'package:demo_count_data/provider/main_screen.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(VideoPlayerApp());
// }
//
// class VideoPlayerApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Player App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MainScreen(),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chewie_and_video_player/chewie_VideoPlayerScreen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoPlayerScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
//
// import 'HTTP_Clear_Architecture/view.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Material App',
//       home: ViewDemo(),
//     );
//   }
// }
