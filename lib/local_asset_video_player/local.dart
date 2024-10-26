import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:async'; // Import for Timer
import 'video_data.dart'; // Import the video data

void main() {
  Get.put(DataUsageController());
  runApp(MyApp());
}

// Data Usage Controller
class DataUsageController extends GetxController {
  var currentUsage = 0.0.obs;

  void updateUsage(double amount) {
    currentUsage.value += amount;
    print("Updated data usage: ${currentUsage.value}");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Player',
      home: VideoPlayerScreen(),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoPlayerItem(video: videos[index]);
              },
              scrollDirection: Axis.vertical,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final dataUsage = Get.find<DataUsageController>().currentUsage.value;
              return Text(
                'Data Used: ${dataUsage.toStringAsFixed(2)} MB',
                style: TextStyle(fontSize: 18),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Video Player Item
class VideoPlayerItem extends StatefulWidget {
  final Map<String, dynamic> video;

  VideoPlayerItem({required this.video});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  Timer? _dataUsageTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(widget.video["sources"][0])
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          Get.find<DataUsageController>().updateUsage(1.0); // Lower initial data usage
          _startDataUsageTimer();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: ${error.toString()}')),
        );
      });
  }

  void _startDataUsageTimer() {
    _dataUsageTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_controller.value.isPlaying) {
        Get.find<DataUsageController>().updateUsage(0.2); // Lower data usage every second
      }
    });
  }

  @override
  void dispose() {
    _dataUsageTimer?.cancel(); // Cancel the timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller.value.isInitialized
            ? VideoPlayer(_controller)
            : Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.video["title"],
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
      ],
    );
  }
}
