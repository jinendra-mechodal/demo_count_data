import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'video_controller.dart';
import 'video_model.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoController controller = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            PageView.builder(
              itemCount: controller.videos.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                controller.setCurrentVideo(index);
              },
              itemBuilder: (context, index) {
                return VideoPlayerItem(video: controller.videos[index]);
              },
            ),
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black54,
                    child: Obx(() {
                      return Text(
                        "Data Used: ${controller.dataUsage.value.toStringAsFixed(2)} MB | "
                            "Quality: ${controller.currentQuality.value}",
                        style: TextStyle(color: Colors.white),
                      );
                    }),
                  ),
                  Text(
                    "Current Video URL: ${controller.videos[controller.currentVideoIndex.value].videoUrl}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () => controller.changeVideoQuality('Low'),
                  //       child: Text('Low Quality'),
                  //     ),
                  //     SizedBox(width: 10),
                  //     ElevatedButton(
                  //       onPressed: () => controller.changeVideoQuality('Medium'),
                  //       child: Text('Medium Quality'),
                  //     ),
                  //     SizedBox(width: 10),
                  //     ElevatedButton(
                  //       onPressed: () => controller.changeVideoQuality('High'),
                  //       child: Text('High Quality'),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class VideoPlayerItem extends StatelessWidget {
  final Video video;

  VideoPlayerItem({required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoController>();

    return GestureDetector(
      onTap: () {
        if (controller.videoPlayerController.value.isInitialized) {
          if (controller.videoPlayerController.value.isPlaying) {
            controller.videoPlayerController.pause();
          } else {
            controller.videoPlayerController.play();
          }
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(controller.videoPlayerController),
      ),
    );
  }
}
