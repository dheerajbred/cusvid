import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/models/media_inpput_value.dart';
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
      home: MyCustomPlayerWidget(
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
            skipButtons: [
              SkipButton(
                  duration: 20,
                  activateOn: 30,
                  label: "SKIP",
                  skipTime: 20,
                  enabled: true)
            ],
            nextButtons: [
              NextButton(
                  duration: 20,
                  activateTimeLeft: 30,
                  label: "NEXT EPISODE",
                  enabled: true)
            ],
            
            extraWidgetEnabled: true,
            extraWidget: Container(
              child: Text("HiEXtra"),
            )),
      ),
    );
  }
}
