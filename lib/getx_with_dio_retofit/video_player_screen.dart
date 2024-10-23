import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import 'video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoController controller = Get.put(VideoController(ApiService(Dio())));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.videoList.isEmpty) {
          return Center(child: Text("No videos available."));
        }

        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dy > 0) {
              controller.nextVideo(); // Swipe down to go to next video
            } else if (details.velocity.pixelsPerSecond.dy < 0) {
              controller.previousVideo(); // Swipe up to go to previous video
            }
          },
          child: PageView.builder(
            itemCount: controller.videoList.length,
            scrollDirection: Axis.vertical,
            controller: PageController(initialPage: 0),
            onPageChanged: (index) {
              controller.playVideo(index);
            },
            itemBuilder: (context, index) {
              return VideoPlayerWidget(controller: controller, index: index);
            },
          ),
        );
      }),
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final VideoController controller;
  final int index;

  const VideoPlayerWidget({Key? key, required this.controller, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(controller.videoPlayerController.value!),
    );
  }
}
