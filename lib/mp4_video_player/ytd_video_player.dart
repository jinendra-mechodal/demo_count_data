import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(GetMaterialApp(home: VideoPlayerPage()));
}

class VideoService {
  final dio.Dio _dio = dio.Dio();

  Future<List<Video>> fetchVideos() async {
    const String apiUrl = 'https://liveb2b.in/liveb2b3.0/all-video-api.php';

    try {
      final response = await _dio.post(apiUrl, data: dio.FormData.fromMap({}));

      if (response.data['status'] == 'success') {
        List<Video> videos = (response.data['video'] as List)
            .map((video) => Video.fromJson(video))
            .toList();

        // Download all videos after fetching
        await Future.wait(videos.map((video) async {
          String videoPath = await _getLocalVideoPath(video);
          if (!(await File(videoPath).exists())) {
            await _downloadVideo(video.videoUrl, videoPath);
          }
        }));

        return videos;
      } else {
        throw Exception('Failed to load videos: ${response.data['message']}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      throw Exception('Failed to load videos: $e');
    }
  }

  Future<void> _downloadVideo(String url, String path) async {
    try {
      print('Downloading video from: $url');
      await _dio.download(url, path);
      print('Video downloaded to: $path');
    } catch (e) {
      print('Error downloading video: $e');
    }
  }

  Future<String> _getLocalVideoPath(Video video) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${video.title}.mp4';
  }
}

class Video {
  final String videoUrl;
  final String title;

  Video({required this.videoUrl, required this.title});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoUrl: json['video'],
      title: json['video_tital'],
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final VideoService videoService = VideoService();
  late Future<List<Video>> futureVideos;

  @override
  void initState() {
    super.initState();
    futureVideos = videoService.fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: FutureBuilder<List<Video>>(
        future: futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found'));
          }

          final videos = snapshot.data!;
          return VideoPlayerWidget(videos: videos);
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final List<Video> videos;

  const VideoPlayerWidget({Key? key, required this.videos}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  int currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    String videoPath = await _getLocalVideoPath(widget.videos[currentVideoIndex]);
    _controller = VideoPlayerController.file(File(videoPath));

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _playNextVideo();
      }
    });

    try {
      await _controller.initialize();
      setState(() {
        // Refresh the UI to show video is initialized
      });
      _controller.play();
    } catch (error) {
      print('Error initializing video: $error');
      _playNextVideo();
    }
  }

  Future<String> _getLocalVideoPath(Video video) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${video.title}.mp4';
  }

  void _playNextVideo() {
    setState(() {
      _controller.dispose();
      currentVideoIndex = (currentVideoIndex + 1) % widget.videos.length;
      _initializeVideo();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}
