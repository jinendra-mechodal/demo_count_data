// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'video_controller.dart';
// import 'video_model.dart';
// import 'api_service.dart';
// import 'package:dio/dio.dart';
//
// import 'video_player_widget.dart';
//
// class MainScreen extends StatelessWidget {
//   final VideoController controller = VideoController(ApiService(Dio()));
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video List')),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text(controller.errorMessage.value));
//         }
//         return ListView.builder(
//           itemCount: controller.videos.length,
//           itemBuilder: (context, index) {
//             final video = controller.videos[index];
//             return ListTile(
//               title: Text(video.videoTitle),
//               subtitle: Text(video.location),
//               leading: Image.network(video.image),
//               onTap: () {
//                 Get.to(() => VideoPlayerWidget(videoUrl: video.video, videoTitle: video.videoTitle));
//               },
//             );
//           },
//         );
//       }),
//     );
//   }
// }
