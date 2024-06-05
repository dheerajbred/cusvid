import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/screens/home_screen.dart';
import 'package:manual_video_player/screens/video_player.screen.page.dart';
import 'package:media_kit/media_kit.dart';

import 'package:manual_video_player/models/quality_class.dart';
import 'package:manual_video_player/models/video_class.dart';
import 'package:manual_video_player/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: MyCustomFullscreenPlayerWidget(
          MediaInputValue(
              type: MediaType.playFromLink,
              videoUrl:
                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              qualityUrl: [
                QualityClass(
                    name: "480x270",
                    link:
                        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                QualityClass(
                    name: "1280x720",
                    link:
                        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
              ],
              subtitleUrl: [
                "https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt",
                "https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt",
                "https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt",
                "https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt"
              ],
              skipButtonEnabled: true,
              skipButtonShowOn: 20,
              skipButtonDuration: 5,
              skipButtonSkipTo: 10,
              nextButtonEnabled: true,
              nextButtonDuration: 7,
              nextButtonShowOn: 40,
              extraWidgetEnabled: true,
              extraWidget: Container(
                child: Text("HiEXtra"),
              )),
          ),
    );
  }
}
