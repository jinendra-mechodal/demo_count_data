import 'dart:async';
import 'package:get/get.dart';
import 'video_model.dart';
import 'dio_service.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  var videos = <Video>[].obs;
  var isLoading = true.obs;
  var currentVideoIndex = 0.obs;
  late VideoPlayerController videoPlayerController;
  var dataUsage = 0.0.obs;
  late Timer timer;

  final Map<String, int> videoQualities = {
    'Low': 250,    // 250 kbps
    'Medium': 500, // 500 kbps
    'High': 1000,  // 1000 kbps
  };

  var currentBitrate = 250; // Start with low quality
  var currentQuality = 'Low'.obs;
  var isLowDataMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
    startNetworkSpeedMonitor();
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

  void setCurrentVideo(int index) {
    if (index >= 0 && index < videos.length) {
      videoPlayerController.pause();
      videoPlayerController.dispose();
      currentVideoIndex.value = index;
      playVideo(videos[currentVideoIndex.value]);
    }
  }

  void changeVideoQuality(String quality) {
    if (isLowDataMode.value && quality != 'Low') {
      return; // Restrict to low quality in low data mode
    }

    if (currentQuality.value != quality) {
      currentQuality.value = quality;
      currentBitrate = videoQualities[quality] ?? 250; // Default to low if not found
      playVideo(videos[currentVideoIndex.value]);
    }
  }

  void toggleLowDataMode() {
    isLowDataMode.value = !isLowDataMode.value;
    if (isLowDataMode.value) {
      changeVideoQuality('Low'); // Automatically switch to low quality
      Get.snackbar('Low Data Mode', 'You are now in Low Data Mode', snackPosition: SnackPosition.BOTTOM);
    } else {
      changeVideoQuality(currentQuality.value); // Switch back to previous quality
      Get.snackbar('Low Data Mode', 'You are now in Normal Mode', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void startDataUsageTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (videoPlayerController.value.isPlaying) {
        _calculateDataUsage();
      }
    });
  }

  void _calculateDataUsage() {
    double bitrateInKbps = currentBitrate / 8; // Convert to KBps
    dataUsage.value += bitrateInKbps / 60; // Data usage per second
    print('Current Data Usage: ${dataUsage.value.toStringAsFixed(2)} MB');
  }

  void startNetworkSpeedMonitor() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      double speed = await _checkInternetSpeed();
      print('Current Network Speed: ${speed.toStringAsFixed(2)} Mbps');
      _adjustVideoQualityBasedOnSpeed(speed);
    });
  }

  Future<double> _checkInternetSpeed() async {
    // Simulate network speed checking (replace with actual logic)
    return 0.5; // Placeholder for actual speed test logic
  }

  void _adjustVideoQualityBasedOnSpeed(double speed) {
    if (speed < 0.1) {
      changeVideoQuality('Low');
    } else if (speed < 0.5) {
      changeVideoQuality('Medium');
    } else {
      changeVideoQuality('High');
    }
  }
}
