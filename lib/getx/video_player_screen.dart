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
                // Preload the next video if possible
                if (index + 1 < controller.videos.length) {
                  controller.preloadVideo(controller.videos[index + 1]);
                }
              },
              itemBuilder: (context, index) {
                return VideoPlayerItem(video: controller.videos[index]);
              },
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.black54,
                child: Obx(() {
                  return Text(
                    "Data Used: ${controller.dataUsage.value.toStringAsFixed(2)} MB | "
                        "Speed: ${controller.dataSpeed.value.toStringAsFixed(2)} Mbps | "
                        "Quality: ${controller.currentQuality.value}",
                    style: TextStyle(color: Colors.white),
                  );
                }),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showQualityDialog(context),
              ),
            ),
            // Positioned(
            //   bottom: 80,
            //   left: 20,
            //   child: Row(
            //     children: [
            //       IconButton(
            //         icon: Icon(Icons.skip_previous, color: Colors.white),
            //         onPressed: controller.playPreviousVideo,
            //       ),
            //       IconButton(
            //         icon: Icon(Icons.skip_next, color: Colors.white),
            //         onPressed: controller.playNextVideo,
            //       ),
            //     ],
            //   ),
            // ),
            // Loading indicator for when video is switching
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return SizedBox.shrink();
            }),
          ],
        );
      }),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final controller = Get.find<VideoController>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Video Quality"),
          content: SingleChildScrollView(
            child: ListBody(
              children: controller.videoQualities.keys.map((quality) {
                return ListTile(
                  title: Text(quality),
                  trailing: Obx(() {
                    return controller.currentQuality.value == quality
                        ? Icon(Icons.check, color: Colors.green)
                        : SizedBox.shrink();
                  }),
                  onTap: () {
                    controller.changeVideoQuality(quality);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
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
