import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class VideoPlayerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoProvider);

    return Scaffold(
      body: videoState.isLoading
          ? Center(child: CircularProgressIndicator())
          : videoState.videos.isEmpty
          ? Center(child: Text('No videos found'))
          : PageView.builder(
        controller: videoState.pageController,
        itemCount: videoState.videos.length,
        itemBuilder: (context, index) {
          return VideoPlayerItem(
            video: videoState.videos[index],
            onVideoFinished: () {
              if (index < videoState.videos.length - 1) {
                videoState.pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          );
        },
        scrollDirection: Axis.vertical,
      ),
    );
  }
}

class VideoPlayerItem extends ConsumerStatefulWidget {
  final VideoData video;
  final VoidCallback onVideoFinished;

  VideoPlayerItem({required this.video, required this.onVideoFinished});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends ConsumerState<VideoPlayerItem> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      showControls: false,
    );

    // Listen for video playback updates
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.onVideoFinished();
      } else {
        // Update playback time and data usage
        ref.read(videoProvider.notifier).updatePlaybackData(_controller.value.position.inSeconds);
      }
    });
  }

  void togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);

    return GestureDetector(
      onTap: togglePlayPause,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Chewie(controller: _chewieController),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Playback Time: ${videoState.playbackTime.inMinutes}:${(videoState.playbackTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Total Data Usage: ${videoState.totalDataUsage.toStringAsFixed(2)} MB',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoData {
  final String title;
  final String videoUrl;
  final String? imageUrl;

  VideoData({
    required this.title,
    required this.videoUrl,
    this.imageUrl,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      title: json['video_tital'] ?? 'Unknown Title',
      videoUrl: json['video'] ?? '',
      imageUrl: json['image'],
    );
  }

  @override
  String toString() {
    return 'VideoData(title: $title, videoUrl: $videoUrl, imageUrl: $imageUrl)';
  }
}

// Video Provider to manage video data and playback information
// class VideoProvider extends StateNotifier<VideoState> {
//   VideoProvider() : super(VideoState.initial());
//
//   void updatePlaybackData(int seconds) {
//     const double bitrate = 1.5; // Example: 1.5 Mbps (adjust based on your video)
//     double bytesUsed = (bitrate * 1000 / 8) * seconds; // Convert to bytes
//     double dataUsage = bytesUsed / (1024 * 1024); // Convert to MB
//
//     state = state.copyWith(
//       playbackTime: Duration(seconds: seconds),
//       totalDataUsage: state.totalDataUsage + dataUsage,
//       totalPlaybackTime: state.totalPlaybackTime + Duration(seconds: seconds),
//     );
//   }
//
//   void loadVideos() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       final response = await http.get(Uri.parse('https://liveb2b.in/liveb2b3.0/all-video-api.php'));
//       if (response.statusCode == 200) {
//         var jsonData = json.decode(response.body);
//         if (jsonData['status'] == 'success') {
//           List<VideoData> videos = List<VideoData>.from(
//             jsonData['video'].map((videoJson) => VideoData.fromJson(videoJson)),
//           );
//           state = state.copyWith(videos: videos, isLoading: false);
//         } else {
//           print('Error: ${jsonData['message']}');
//         }
//       } else {
//         throw Exception('Failed to load videos. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching videos: $e');
//       state = state.copyWith(isLoading: false);
//     }
//   }
// }

class VideoProvider extends StateNotifier<VideoState> {
  VideoProvider() : super(VideoState.initial());

  void updatePlaybackData(int seconds) {
    // Adjust this bitrate according to your video properties
    const double bitrateMbps = 1.5; // Bitrate in Mbps
    double bitrateBps = bitrateMbps * 1000000; // Convert to bits per second
    double bytesUsed = (bitrateBps / 8) * seconds; // Convert to bytes

    double dataUsageMB = bytesUsed / (1024 * 1024); // Convert to MB

    state = state.copyWith(
      playbackTime: Duration(seconds: seconds),
      totalDataUsage: state.totalDataUsage + dataUsageMB,
      totalPlaybackTime: state.totalPlaybackTime + Duration(seconds: seconds),
    );
  }

  void loadVideos() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.get(Uri.parse('https://liveb2b.in/liveb2b3.0/all-video-api.php'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          List<VideoData> videos = List<VideoData>.from(
            jsonData['video'].map((videoJson) => VideoData.fromJson(videoJson)),
          );
          state = state.copyWith(videos: videos, isLoading: false);
        } else {
          print('Error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load videos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

class VideoState {
  final List<VideoData> videos;
  final Duration playbackTime;
  final double totalDataUsage;
  final bool isLoading;
  final Duration totalPlaybackTime;
  final PageController pageController;

  VideoState({
    required this.videos,
    required this.playbackTime,
    required this.totalDataUsage,
    required this.isLoading,
    required this.totalPlaybackTime,
    required this.pageController,
  });

  factory VideoState.initial() {
    return VideoState(
      videos: [],
      playbackTime: Duration.zero,
      totalDataUsage: 0.0,
      isLoading: true,
      totalPlaybackTime: Duration.zero,
      pageController: PageController(),
    );
  }

  VideoState copyWith({
    List<VideoData>? videos,
    Duration? playbackTime,
    double? totalDataUsage,
    bool? isLoading,
    Duration? totalPlaybackTime,
    PageController? pageController,
  }) {
    return VideoState(
      videos: videos ?? this.videos,
      playbackTime: playbackTime ?? this.playbackTime,
      totalDataUsage: totalDataUsage ?? this.totalDataUsage,
      isLoading: isLoading ?? this.isLoading,
      totalPlaybackTime: totalPlaybackTime ?? this.totalPlaybackTime,
      pageController: pageController ?? this.pageController,
    );
  }
}

// Riverpod provider instance
final videoProvider = StateNotifierProvider<VideoProvider, VideoState>((ref) {
  return VideoProvider()..loadVideos(); // Load videos on creation
});
