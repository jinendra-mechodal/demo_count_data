// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'video_model.dart';
import 'video_player_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<VideoModel>> futureVideos;

  @override
  void initState() {
    super.initState();
    futureVideos = ApiService().fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video List"),
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Loading videos...");
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error fetching videos: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No videos found");
            return Center(child: Text("No videos found"));
          }

          final videos = snapshot.data!;
          print("Loaded ${videos.length} videos");

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              print("Rendering video: ${videos[index].title}");
              return ListTile(
                leading: Image.network(videos[index].imageUrl),
                title: Text(videos[index].title),
                onTap: () {
                  print("Video tapped: ${videos[index].title}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoUrl: videos[index].videoUrl),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
