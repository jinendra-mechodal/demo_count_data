import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  @JsonKey(name: 'c_id')
  final String cId;

  @JsonKey(name: 'user_id')
  final String userId;

  final String type;
  final String video;

  @JsonKey(name: 'video_tital')
  final String videoTitle;

  final String location;
  final String city;
  final String pincode;

  @JsonKey(name: 'video_category')
  final String? videoCategory; // Nullable field

  final String date;
  final String viewCount;
  final String image;
  final String language;
  final String state;
  final String country;

  @JsonKey(name: 'main_category')
  final String mainCategory;

  @JsonKey(name: 'sub_category')
  final String subCategory;

  @JsonKey(name: 'hsn_category')
  final String hsnCategory;

  final String latitude;
  final String longitude;

  @JsonKey(name: 'profile_img')
  final String? profileImg; // Nullable field

  @JsonKey(name: 'hsn_category_name')
  final String hsnCategoryName;

  VideoModel({
    required this.cId,
    required this.userId,
    required this.type,
    required this.video,
    required this.videoTitle,
    required this.location,
    required this.city,
    required this.pincode,
    this.videoCategory,
    required this.date,
    required this.viewCount,
    required this.image,
    required this.language,
    required this.state,
    required this.country,
    required this.mainCategory,
    required this.subCategory,
    required this.hsnCategory,
    required this.latitude,
    required this.longitude,
    this.profileImg,
    required this.hsnCategoryName,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      cId: json['c_id'] as String? ?? 'unknown', // Provide default value
      userId: json['user_id'] as String? ?? 'unknown', // Provide default value
      type: json['type'] as String? ?? 'unknown',
      video: json['video'] as String? ?? '', // Provide default value
      videoTitle: json['video_tital'] as String? ?? 'Untitled',
      location: json['location'] as String? ?? 'unknown',
      city: json['city'] as String? ?? 'unknown',
      pincode: json['pincode'] as String? ?? 'unknown',
      videoCategory: json['video_category'] as String?,
      date: json['date'] as String? ?? 'unknown',
      viewCount: json['view_count'] as String? ?? '0',
      image: json['image'] as String? ?? '',
      language: json['language'] as String? ?? 'unknown',
      state: json['state'] as String? ?? 'unknown',
      country: json['country'] as String? ?? 'unknown',
      mainCategory: json['main_category'] as String? ?? 'unknown',
      subCategory: json['sub_category'] as String? ?? 'unknown',
      hsnCategory: json['hsn_category'] as String? ?? 'unknown',
      latitude: json['latitude'] as String? ?? '0',
      longitude: json['longitude'] as String? ?? '0',
      profileImg: json['profile_img'] as String?,
      hsnCategoryName: json['hsn_category_name'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);
}

@JsonSerializable()
class VideoResponse {
  final String status;
  final String message;
  final List<VideoModel> video;

  VideoResponse({
    required this.status,
    required this.message,
    required this.video,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VideoResponseToJson(this);
}
