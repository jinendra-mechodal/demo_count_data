// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'video_provider.dart'; // Ensure you have this defined
// import 'video_model.dart'; // Ensure you have this defined
// import 'package:video_player/video_player.dart';
// import 'dart:async';
//
// void main() {
//   runApp(
//     ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Video Player',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VideoListScreen(),
//     );
//   }
// }
//
// class VideoListScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final videoAsyncValue = ref.watch(videoProvider);
//
//     return Scaffold(
//       body: videoAsyncValue.when(
//         data: (videos) => PageView.builder(
//           itemCount: videos.length,
//           scrollDirection: Axis.vertical,
//           itemBuilder: (context, index) {
//             final video = videos[index];
//             return VideoPlayerItem(video: video);
//           },
//         ),
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }
//
// class VideoPlayerItem extends StatefulWidget {
//   final Video video;
//
//   const VideoPlayerItem({Key? key, required this.video}) : super(key: key);
//
//   @override
//   _VideoPlayerItemState createState() => _VideoPlayerItemState();
// }
//
// class _VideoPlayerItemState extends State<VideoPlayerItem> {
//   late VideoPlayerController _controller;
//   late Timer _timer;
//   double _dataUsedMB = 0.0;
//   static double _totalDataUsedMB = 0.0;
//   double _dataSpeedMbps = 0.0;
//   double _previousDataBytes = 0.0;
//   bool _isInitialized = false;
//   String _selectedQuality = 'Medium'; // Default quality
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }
//
//   Future<void> _initializeVideoPlayer() async {
//     _controller = VideoPlayerController.network(widget.video.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//           _controller.play();
//         });
//
//         _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//           if (_controller.value.isPlaying) {
//             setState(() {
//               _dataUsedMB = _calculateDataUsage();
//               _dataSpeedMbps = _calculateDataSpeed();
//             });
//           }
//         });
//       }).catchError((error) {
//         setState(() {
//           _isInitialized = false;
//         });
//         print("Error initializing video: $error");
//       });
//
//     _controller.addListener(() {
//       if (_controller.value.position == _controller.value.duration) {
//         _totalDataUsedMB += _dataUsedMB;
//         _dataUsedMB = 0.0;
//
//         _controller.seekTo(Duration.zero);
//         _controller.play();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     _totalDataUsedMB += _dataUsedMB;
//     _controller.dispose();
//     super.dispose();
//   }
//
//   double _calculateDataUsage() {
//     final double averageBitrateMbps = _getBitrateForQuality();
//     const double bytesPerMegabit = 125000;
//
//     final secondsPlayed = _controller.value.position.inSeconds.toDouble();
//     return (secondsPlayed * averageBitrateMbps * bytesPerMegabit) / (1024 * 1024);
//   }
//
//   double _calculateDataSpeed() {
//     const double bytesPerMegabit = 125000;
//     final currentDataBytes = _dataUsedMB * (1024 * 1024);
//
//     final bytesDownloadedInLastSecond = currentDataBytes - _previousDataBytes;
//     _previousDataBytes = currentDataBytes;
//
//     return (bytesDownloadedInLastSecond / bytesPerMegabit);
//   }
//
//   double _getBitrateForQuality() {
//     switch (_selectedQuality) {
//       case 'Low':
//         return 0.2; // Set lower bitrate for low quality (e.g., 0.2 Mbps)
//       case 'Medium':
//         return 1.5; // Medium quality bitrate
//       case 'High':
//         return 3.0; // High quality bitrate
//       default:
//         return 1.5; // Default to medium
//     }
//   }
//
//   static String getTotalDataUsed() {
//     return _totalDataUsedMB.toStringAsFixed(2);
//   }
//
//   void _showQualitySelection() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Select Video Quality"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: ['Low', 'Medium', 'High'].map((quality) {
//               return RadioListTile<String>(
//                 title: Text(quality),
//                 value: quality,
//                 groupValue: _selectedQuality,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedQuality = value!;
//                   });
//                   Navigator.of(context).pop();
//                 },
//               );
//             }).toList(),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isInitialized) {
//           if (_controller.value.isPlaying) {
//             _controller.pause();
//           } else {
//             _controller.play();
//           }
//           setState(() {});
//         }
//       },
//       child: Container(
//         child: Column(
//           children: [
//             Expanded(
//               child: AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: _isInitialized
//                     ? VideoPlayer(_controller)
//                     : Container(color: Colors.black),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Data Used: ${_dataUsedMB.toStringAsFixed(2)} MB",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Total Data Used: ${getTotalDataUsed()} MB",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Current Speed: ${_dataSpeedMbps.toStringAsFixed(2)} Mbps",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: _showQualitySelection,
//                 child: Text("Change Quality"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
