import 'dart:async';
import 'package:get/get.dart';
import 'video_model.dart';
import 'dio_service.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VideoController extends GetxController {
  var videos = <Video>[].obs;
  var isLoading = true.obs;
  var currentVideoIndex = 0.obs;
  late VideoPlayerController videoPlayerController;
  var dataUsage = 0.0.obs;
  var dataSpeed = 0.0.obs;
  late Timer timer;

  final Map<String, int> videoQualities = {
    'Low': 500,    // 500 kbps
    'Medium': 1000, // 1000 kbps
    'High': 2500,   // 2500 kbps
  };

  var currentBitrate = 100;
  var currentQuality = 'Low'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
    startBandwidthMonitor();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    timer.cancel();
    super.onClose();
  }

  Future<void> fetchVideos() async {
    isLoading.value = true;
    try {
      videos.value = await DioService.fetchVideos();
      if (videos.isNotEmpty) {
        playVideo(videos[currentVideoIndex.value]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load videos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void playVideo(Video video) {
    isLoading.value = true;
    videoPlayerController = VideoPlayerController.network(video.videoUrl)
      ..initialize().then((_) {
        if (videoPlayerController.value.isInitialized) {
          videoPlayerController.play();
          startDataUsageTimer();
          isLoading.value = false;

          videoPlayerController.addListener(() {
            if (videoPlayerController.value.hasError) {
              Get.snackbar('Error', 'Video playback error: ${videoPlayerController.value.errorDescription}');
            }
            // Auto play next video when current ends
            if (videoPlayerController.value.position == videoPlayerController.value.duration) {
              playNextVideo();
            }
          });
        } else {
          isLoading.value = false;
          Get.snackbar('Error', 'Video player not initialized properly.');
        }
      }).catchError((error) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to initialize video: ${error.toString()}');
      });
  }

  void playNextVideo() {
    if (currentVideoIndex.value < videos.length - 1) {
      setCurrentVideo(currentVideoIndex.value + 1);
    }
  }

  void playPreviousVideo() {
    if (currentVideoIndex.value > 0) {
      setCurrentVideo(currentVideoIndex.value - 1);
    }
  }

  void preloadVideo(Video video) {
    VideoPlayerController.network(video.videoUrl)..initialize();
  }

  void setCurrentVideo(int index) {
    if (index >= 0 && index < videos.length) {
      videoPlayerController.pause();
      videoPlayerController.dispose();
      currentVideoIndex.value = index;

      // Adjust video quality based on current bandwidth
      _adjustVideoQuality().then((_) {
        playVideo(videos[currentVideoIndex.value]);
      });
    }
  }

  void changeVideoQuality(String quality) {
    if (currentQuality.value != quality) {
      currentQuality.value = quality;
      currentBitrate = videoQualities[quality] ?? 1000;
      playVideo(videos[currentVideoIndex.value]);
    }
  }

  void startDataUsageTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (videoPlayerController.value.isPlaying) {
        _calculateDataUsage();
        _calculateDataSpeed();
      }
    });
  }

  void _calculateDataUsage() {
    double bitrateInMbps = currentBitrate / 8;
    dataUsage.value += bitrateInMbps / 60; // Data usage per second
  }

  void _calculateDataSpeed() {
    dataSpeed.value = currentBitrate / 1000.0; // Mbps
  }

  void startBandwidthMonitor() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      double speed = await _checkInternetSpeed();
      if (speed < 0.5) {
        changeVideoQuality('Low');
      } else if (speed < 1.0) {
        changeVideoQuality('Medium');
      } else {
        changeVideoQuality('High');
      }
    });
  }

  Future<double> _checkInternetSpeed() async {
    // Implement a simple speed test logic here
    // For example, you can download a small file and measure the time taken.
    return 1.0; // Placeholder for actual speed in Mbps
  }

  Future<void> _adjustVideoQuality() async {
    double speed = await _checkInternetSpeed();

    if (speed < 0.5) {
      changeVideoQuality('Low');
    } else if (speed < 1.0) {
      changeVideoQuality('Medium');
    } else {
      changeVideoQuality('High');
    }
  }
}
