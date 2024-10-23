// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'video_model.dart';
//
// class VideoService {
//   static const String apiUrl = 'https://liveb2b.in/liveb2b3.0/all-video-api.php';
//
//   Future<List<Video>> fetchVideos() async {
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       if (data['status'] == 'success') {
//         return (data['video'] as List)
//             .map((video) => Video.fromJson(video))
//             .toList();
//       }
//     }
//     throw Exception('Failed to load videos');
//   }
// }
