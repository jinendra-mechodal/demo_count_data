class videoDataModal {
  String? status;
  String? message;
  List<Video>? video;

  videoDataModal({this.status, this.message, this.video});

  videoDataModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['video'] != null) {
      video = <Video>[];
      json['video'].forEach((v) {
        video!.add(new Video.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.video != null) {
      data['video'] = this.video!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Video {
  String? cId;
  String? userId;
  String? type;
  String? video;
  String? videoTital;
  String? location;
  String? city;
  String? pincode;
  Null? videoCategory;
  String? date;
  String? userViewId;
  String? viewCount;
  String? image;
  String? language;
  String? state;
  String? country;
  String? mainCategory;
  String? subCategory;
  String? hsnCategory;
  String? latitude;
  String? longitude;
  String? profileImg;
  String? hsnCategoryName;

  Video(
      {this.cId,
        this.userId,
        this.type,
        this.video,
        this.videoTital,
        this.location,
        this.city,
        this.pincode,
        this.videoCategory,
        this.date,
        this.userViewId,
        this.viewCount,
        this.image,
        this.language,
        this.state,
        this.country,
        this.mainCategory,
        this.subCategory,
        this.hsnCategory,
        this.latitude,
        this.longitude,
        this.profileImg,
        this.hsnCategoryName});

  Video.fromJson(Map<String, dynamic> json) {
    cId = json['c_id'];
    userId = json['user_id'];
    type = json['type'];
    video = json['video'];
    videoTital = json['video_tital'];
    location = json['location'];
    city = json['city'];
    pincode = json['pincode'];
    videoCategory = json['video_category'];
    date = json['date'];
    userViewId = json['user_view_id'];
    viewCount = json['view_count'];
    image = json['image'];
    language = json['language'];
    state = json['state'];
    country = json['country'];
    mainCategory = json['main_category'];
    subCategory = json['sub_category'];
    hsnCategory = json['hsn_category'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    profileImg = json['profile_img'];
    hsnCategoryName = json['hsn_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_id'] = this.cId;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['video'] = this.video;
    data['video_tital'] = this.videoTital;
    data['location'] = this.location;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['video_category'] = this.videoCategory;
    data['date'] = this.date;
    data['user_view_id'] = this.userViewId;
    data['view_count'] = this.viewCount;
    data['image'] = this.image;
    data['language'] = this.language;
    data['state'] = this.state;
    data['country'] = this.country;
    data['main_category'] = this.mainCategory;
    data['sub_category'] = this.subCategory;
    data['hsn_category'] = this.hsnCategory;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['profile_img'] = this.profileImg;
    data['hsn_category_name'] = this.hsnCategoryName;
    return data;
  }
}
