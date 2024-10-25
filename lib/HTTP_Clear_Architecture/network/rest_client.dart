import 'dart:io';
import 'package:demo_count_data/HTTP_Clear_Architecture/network/http_helper.dart';
import '../models/postApiModalLogin.dart';
import '../models/video_modal.dart';

class RestClient {
  static final HttpHelper _httpHelper = HttpHelper();

  // static Future<PostApiModel> postApi(Map<String, dynamic> params) async {
  //   // Define your API endpoint URL here
  //   final String url = 'https://yourapi.com/endpoint'; // Replace with your actual URL
  //
  //   try {
  //     // Call the post method from HttpHelper
  //     final response = await _httpHelper.post(
  //       url: url,
  //       body: params,
  //     );
  //
  //     // Convert the response to PostApiModel
  //     return PostApiModel.fromJson(response);
  //   } on SocketException {
  //     throw Exception('No Internet connection. Please try again later.');
  //   } on FormatException {
  //     throw Exception('Bad response format. Please check the server.');
  //   } catch (e) {
  //     throw Exception('Failed to post data: $e');
  //   }
  // }

  // static Future<PostApiModel> postApi(Map<String, dynamic> params) async {
  //   Map<String, dynamic> response = await _httpHelper.post(url: 'https://reqres.in/api/login', body: params);
  //   return response;
  // }

  static Future<videoDataModal> getVidoFromApi() async {
    Map<String, dynamic> response = await _httpHelper.get(
        url: 'https://liveb2b.in/liveb2b3.0/all-video-api.php');
    return videoDataModal.fromJson(response);
  }
}

