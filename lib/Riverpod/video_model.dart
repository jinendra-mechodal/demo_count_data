class Video {
  final String cId;
  final String userId;
  final String type;
  final String videoUrl;
  final String videoTitle;
  final String location;
  final String city;
  final String pincode;
  final String date;
  final String viewCount;
  final String imageUrl;
  final String language;
  final String state;
  final String country;
  final String mainCategory;
  final String subCategory;

  Video({
    required this.cId,
    required this.userId,
    required this.type,
    required this.videoUrl,
    required this.videoTitle,
    required this.location,
    required this.city,
    required this.pincode,
    required this.date,
    required this.viewCount,
    required this.imageUrl,
    required this.language,
    required this.state,
    required this.country,
    required this.mainCategory,
    required this.subCategory,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      cId: json['c_id'],
      userId: json['user_id'],
      type: json['type'],
      videoUrl: json['video'],
      videoTitle: json['video_tital'],
      location: json['location'],
      city: json['city'],
      pincode: json['pincode'],
      date: json['date'],
      viewCount: json['view_count'],
      imageUrl: json['image'],
      language: json['language'],
      state: json['state'],
      country: json['country'],
      mainCategory: json['main_category'],
      subCategory: json['sub_category'],
    );
  }
}
