import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: VideoPage(),
      ),
    );
  }
}

class VideoProvider with ChangeNotifier {
  bool _dataSavingMode = false;
  double _totalDataUsage = 0; // Track total data usage

  bool get dataSavingMode => _dataSavingMode;
  double get totalDataUsage => _totalDataUsage; // Expose total data usage

  void toggleDataSavingMode() {
    _dataSavingMode = !_dataSavingMode;
    notifyListeners();
    _saveDataSavingMode();
    print("Data saving mode: $_dataSavingMode");
  }

  Future<void> _saveDataSavingMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dataSavingMode', _dataSavingMode);
  }

  Future<void> loadDataSavingMode() async {
    final prefs = await SharedPreferences.getInstance();
    _dataSavingMode = prefs.getBool('dataSavingMode') ?? false;
    notifyListeners();
    print("Loaded data saving mode: $_dataSavingMode");
  }

  void updateTotalDataUsage(double dataUsed) {
    _totalDataUsage += dataUsed; // Update total data usage
    notifyListeners(); // Notify listeners
  }
}

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<List<VideoData>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _fetchVideos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).loadDataSavingMode();
    });
  }

  Future<List<VideoData>> _fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('https://liveb2b.in/liveb2b3.0/all-video-api.php'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          List<VideoData> videos = (jsonResponse['video'] as List)
              .map((video) => VideoData.fromJson(video))
              .toList();
          print("Fetched ${videos.length} videos");
          return videos;
        }
      }
      throw Exception('Failed to load videos');
    } catch (e) {
      print('Error fetching videos: $e');
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<VideoData>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found.'));
          }

          final videos = snapshot.data!;
          return PageView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(videoData: videos[index]);
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final VideoData videoData;

  VideoPlayerWidget({required this.videoData});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _dataUsage = 0; // Data usage in MB
  double _currentBitrate = 0; // Estimated bitrate in Mbps
  int _playDuration = 0; // Total playback duration in seconds

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.videoData.video);
  }

  void _initializeVideoPlayer(String url) {
    String videoUrl = Provider.of<VideoProvider>(context, listen: false).dataSavingMode
        ? _getLowerResolutionUrl(url)
        : url;

    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _controller.play();
        });
      });

    // Listen for video position changes
    _controller.addListener(() {
      if (_controller.value.isPlaying) {
        setState(() {
          _playDuration = _controller.value.position.inSeconds;
        });

        _currentBitrate = _getEstimatedBitrate();
        double newDataUsage = (_currentBitrate / 8) * (1); // Using 1 second for accuracy
        setState(() {
          _dataUsage += newDataUsage;
        });
        print('Data used: ${_dataUsage.toStringAsFixed(2)} MB');

        // Update total data usage in VideoProvider
        Provider.of<VideoProvider>(context, listen: false).updateTotalDataUsage(newDataUsage);
      }

      // Stop playback when the video is completed
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false; // Update the playing state
        });
      }
    });
  }

  String _getLowerResolutionUrl(String url) {
    return url.replaceAll('720p', '360p'); // Example: change from 720p to 360p
  }

  double _getEstimatedBitrate() {
    return Provider.of<VideoProvider>(context, listen: false).dataSavingMode ? 1.0 : 2.5; // Adjust based on data saving mode
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Center(child: CircularProgressIndicator()),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoData.videoTital,
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Data used for this video: ${_dataUsage.toStringAsFixed(2)} MB',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                Text(
                  'Total data used: ${Provider.of<VideoProvider>(context).totalDataUsage.toStringAsFixed(2)} MB',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                Text(
                  'Total play time: $_playDuration seconds',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoData {
  final String cId;
  final String userId;
  final String video; // This should be an M3U8 URL
  final String videoTital;
  final String imageUrl;

  VideoData({
    required this.cId,
    required this.userId,
    required this.video,
    required this.videoTital,
    required this.imageUrl,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      cId: json['c_id'] ?? '',
      userId: json['user_id'] ?? '',
      video: json['video'] ?? '', // Ensure this is an M3U8 URL
      videoTital: json['video_tital'] ?? 'No title',
      imageUrl: json['image'] ?? '',
    );
  }
}
