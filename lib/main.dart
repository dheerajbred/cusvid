import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/screens/home_screen.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
      home: MyCustomPlayerWidget(MediaInputValue(type: MediaType.playFromLink,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",subtitleUrl: ["https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt"], showSkipNext: false, extraWidgetEnabled: false),),
    );
  }
}
