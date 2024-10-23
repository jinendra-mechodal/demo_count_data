import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'video_model.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  final ApiService apiService;
  var videoList = <VideoModel>[].obs;
  var isLoading = true.obs;
  var currentVideoIndex = 0;
  Rx<VideoPlayerController?> videoPlayerController = Rx<VideoPlayerController?>(null);

  VideoController(this.apiService);

  @override
  void onInit() {
    fetchVideos();
    super.onInit();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await apiService.getVideos();
      if (response.video.isNotEmpty) {
        videoList.assignAll(response.video);
        playVideo(0);
      }
    } catch (e) {
      print("Error fetching videos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void playVideo(int index) {
    if (index < 0 || index >= videoList.length) return;

    currentVideoIndex = index;
    videoPlayerController.value?.dispose();

    videoPlayerController.value = VideoPlayerController.network(videoList[index].video)
      ..initialize().then((_) {
        videoPlayerController.value!.setLooping(false);
        videoPlayerController.value!.play();
      }).catchError((error) {
        print("Error initializing video player: $error");
      });
  }

  void nextVideo() {
    if (currentVideoIndex < videoList.length - 1) {
      playVideo(currentVideoIndex + 1);
    } else {
      playVideo(0); // Loop back to the first video
    }
  }

  void previousVideo() {
    if (currentVideoIndex > 0) {
      playVideo(currentVideoIndex - 1);
    } else {
      playVideo(videoList.length - 1); // Loop to the last video
    }
  }

  void togglePlayPause() {
    final controller = videoPlayerController.value;
    if (controller != null) {
      controller.value.isPlaying ? controller.pause() : controller.play();
    }
  }

  @override
  void onClose() {
    videoPlayerController.value?.dispose();
    super.onClose();
  }
}
