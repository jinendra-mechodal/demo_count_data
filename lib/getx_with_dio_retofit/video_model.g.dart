// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
      cId: json['c_id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      video: json['video'] as String,
      videoTitle: json['video_tital'] as String,
      location: json['location'] as String,
      city: json['city'] as String,
      pincode: json['pincode'] as String,
      videoCategory: json['video_category'] as String?,
      date: json['date'] as String,
      viewCount: json['viewCount'] as String,
      image: json['image'] as String,
      language: json['language'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      mainCategory: json['main_category'] as String,
      subCategory: json['sub_category'] as String,
      hsnCategory: json['hsn_category'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      profileImg: json['profile_img'] as String?,
      hsnCategoryName: json['hsn_category_name'] as String,
    );

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'c_id': instance.cId,
      'user_id': instance.userId,
      'type': instance.type,
      'video': instance.video,
      'video_tital': instance.videoTitle,
      'location': instance.location,
      'city': instance.city,
      'pincode': instance.pincode,
      'video_category': instance.videoCategory,
      'date': instance.date,
      'viewCount': instance.viewCount,
      'image': instance.image,
      'language': instance.language,
      'state': instance.state,
      'country': instance.country,
      'main_category': instance.mainCategory,
      'sub_category': instance.subCategory,
      'hsn_category': instance.hsnCategory,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'profile_img': instance.profileImg,
      'hsn_category_name': instance.hsnCategoryName,
    };

VideoResponse _$VideoResponseFromJson(Map<String, dynamic> json) =>
    VideoResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      video: (json['video'] as List<dynamic>)
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideoResponseToJson(VideoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'video': instance.video,
    };
