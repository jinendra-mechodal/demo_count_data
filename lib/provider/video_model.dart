// lib/video_model.dart
class VideoModel {
  final String title;
  final String videoUrl;
  final String imageUrl;

  VideoModel({
    required this.title,
    required this.videoUrl,
    required this.imageUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['video_tital'] ?? 'No Title',
      videoUrl: json['video'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }
}
