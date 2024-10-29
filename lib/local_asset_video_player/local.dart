import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MaterialApp(
    home: VideoSwipePageView(),
  ));
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

Future<List<Video>> fetchVideos() async {
  print("Fetching videos from API...");
  final response = await http.get(Uri.parse('https://liveb2b.in/liveb2b3.0/all-video-api.php'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      print("Videos fetched successfully.");
      return (data['video'] as List).map((videoData) => Video.fromJson(videoData)).toList();
    } else {
      print("Failed to find video data.");
      throw Exception('Failed to load videos');
    }
  } else {
    print("API request failed with status: ${response.statusCode}");
    throw Exception('Failed to load videos');
  }
}

Future<String> downloadVideo(String url, String title) async {
  try {
    print("Downloading video: $title...");
    var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    var dir = await getTemporaryDirectory();
    File file = File('${dir.path}/${title.replaceAll(' ', '_')}.m3u8');
    await file.writeAsBytes(response.data);
    print("Downloaded video: $title to ${file.path}");
    return file.path;
  } catch (e) {
    print("Error downloading video: $e");
    throw e; // Rethrow the error after logging it
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen({required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
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
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

class VideoSwipePageView extends StatefulWidget {
  @override
  _VideoSwipePageViewState createState() => _VideoSwipePageViewState();
}

class _VideoSwipePageViewState extends State<VideoSwipePageView> {
  late Future<List<Video>> _videosFuture;
  List<String> videoPaths = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _videosFuture = fetchVideos();
  }

  Future<void> _downloadVideos(List<Video> videos) async {
    setState(() {
      isLoading = true;
    });

    for (var video in videos) {
      try {
        String path = await downloadVideo(video.videoUrl, video.title);
        videoPaths.add(path);
      } catch (e) {
        print("Failed to download video: ${video.title}. Error: $e");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Video>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("Error loading videos: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (videoPaths.isEmpty && !isLoading) {
            _downloadVideos(snapshot.data!);
          }

          return Stack(
            children: [
              if (videoPaths.isNotEmpty)
                PageView.builder(
                  itemCount: videoPaths.length,
                  itemBuilder: (context, index) {
                    return VideoPlayerScreen(videoPath: videoPaths[index]);
                  },
                ),
              if (isLoading)
                Center(child: CircularProgressIndicator()),
            ],
          );
        }
      },
    );
  }
}
