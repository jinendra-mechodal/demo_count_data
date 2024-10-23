import 'package:dio/dio.dart';
import 'video_model.dart';

class DioService {
  static Future<List<Video>> fetchVideos() async {
    try {
      final response = await Dio().get('https://liveb2b.in/liveb2b3.0/all-video-api.php');
      if (response.data['status'] == 'success') {
        return (response.data['video'] as List)
            .map((videoData) => Video(videoData['video'], videoData['video_tital']))
            .toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }
}
