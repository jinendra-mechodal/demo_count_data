import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'video_model.dart';

part 'api_service.g.dart'; // This is necessary for code generation

@RestApi(baseUrl: "https://liveb2b.in/liveb2b3.0/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("all-video-api.php")
  Future<VideoResponse> getVideos();
}
