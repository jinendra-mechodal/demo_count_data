import 'package:demo_count_data/HTTP_Clear_Architecture/network/rest_client.dart';
import 'package:flutter/material.dart';

import 'models/video_modal.dart';

class ViewDemo extends StatefulWidget {
  const ViewDemo({super.key});

  @override
  State<ViewDemo> createState() => _ViewDemoState();
}

class _ViewDemoState extends State<ViewDemo> {
  bool loading = true;
  videoDataModal videoList = videoDataModal();

  @override
  void initState() {
    super.initState();
    fetchVideoData();
  }

  void fetchVideoData() {
    RestClient.getVidoFromApi().then((value) {
      setState(() {
        videoList = value;
        loading = false;
      });
    }).catchError((error) {
      print('Error: ${error.toString()}');
      setState(() {
        loading = false; // Stop loading on error
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: videoList.video?.length ?? 0,
        itemBuilder: (context, index) {
          final video = videoList.video![index];
          return ListTile(
            title: Text(video.videoTital ?? 'No Title'),
            subtitle: Text(video.video ?? 'No Views'),
          );
        },
      ),
    );
  }
}