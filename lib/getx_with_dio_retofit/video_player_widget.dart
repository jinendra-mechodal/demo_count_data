import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerWidget({Key? key, required this.videoUrl, required this.videoTitle}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  final Rx<int> _playbackTime = 0.obs; // Playback time in seconds
  final Rx<double> _dataUsage = 0.0.obs; // Data usage in MB
  final Rx<double> _dataSpeed = 0.0.obs; // Data speed in KB/s
  int _bitrate = 0; // Bitrate in kbps
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _controller.play();
          _isPlaying = true;
          _startTimer();
        });
      });
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_controller.value.isPlaying) {
        _playbackTime.value++;
        _calculateDataUsage();
        _calculateDataSpeed();
      }
      _startTimer();
    });
  }

  void _calculateDataUsage() {
    if (_bitrate > 0) {
      _dataUsage.value = (_playbackTime.value * _bitrate / 8) / 1024; // Convert to MB
    }
  }

  void _calculateDataSpeed() {
    // Placeholder for actual download speed calculation
    _dataSpeed.value = _bitrate / 8; // KBps
  }

  void _selectQuality(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Video Quality'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Low (256 kbps)'),
                onTap: () {
                  _bitrate = 256;
                  _updateVideoQuality();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Medium (768 kbps)'),
                onTap: () {
                  _bitrate = 768;
                  _updateVideoQuality();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('High (1500 kbps)'),
                onTap: () {
                  _bitrate = 1500;
                  _updateVideoQuality();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateVideoQuality() {
    _controller.pause();
    // Replace with actual URLs for different qualities
    String newUrl = widget.videoUrl; // Modify this based on selected quality
    _controller = VideoPlayerController.network(newUrl)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _isPlaying = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () => _selectQuality(context),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_controller),
            ),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Obx(() => Text('Playback Time: ${_playbackTime.value} seconds')),
                  Obx(() => Text('Data Usage: ${_dataUsage.value.toStringAsFixed(2)} MB')),
                  Obx(() => Text('Data Speed: ${_dataSpeed.value.toStringAsFixed(2)} KB/s')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
