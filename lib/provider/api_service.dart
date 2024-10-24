// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'video_model.dart';

class ApiService {
  final String apiUrl = "https://liveb2b.in/liveb2b3.0/all-video-api.php";

  Future<List<VideoModel>> fetchVideos() async {
    print("Fetching videos from $apiUrl");
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      print("Videos fetched successfully: ${response.body}");
      final data = json.decode(response.body);

      if (data['video'] == null) {
        print("No 'video' key found in response");
        return [];
      }

      final List videos = data['video'];
      print("Number of videos fetched: ${videos.length}");

      for (var video in videos) {
        print("Video Title: ${video['title']}, Video URL: ${video['video_url']}");
      }

      return videos.map((video) => VideoModel.fromJson(video)).toList();
    } else {
      print("Failed to fetch videos: ${response.statusCode}");
      throw Exception('Failed to load videos');
    }
  }
}
