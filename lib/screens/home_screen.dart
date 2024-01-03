import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/Animation/animated.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:video_cast/chrome_cast_media_type.dart';
import 'package:video_cast/video_cast.dart';

import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {

   HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
   var a = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => SafeArea(
        child: PiPSwitcher(
          childWhenDisabled: Scaffold(
            key: _scaffoldKey,
            // appBar: AppBar(
            //   title: const Text("Video Player"),
            // ),
            body: MaterialVideoControlsTheme(
              normal: MaterialVideoControlsThemeData(
                automaticallyImplySkipNextButton: false,
                automaticallyImplySkipPreviousButton: false,
                shiftSubtitlesOnControlsVisibilityChange: false,
                volumeGesture: true,
                seekOnDoubleTap: true,
                controlsHoverDuration: const Duration(seconds: 5,milliseconds: 400),
                buttonBarButtonSize: 24.0,
                buttonBarButtonColor: Colors.white,
                topButtonBar: [
                  MaterialCustomButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 24.0,
                  ),
                  const SizedBox(height: 8),
                  const Text("Full"),
                  const Spacer(),

                  MaterialCustomButton(
                    onPressed: controller.speedSelector,
                    icon:  const ImageIcon(AssetImage("assets/speedometer.png")),
                    iconSize: 24.0,
                  ),
                  MaterialCustomButton(
                    onPressed: controller.toggleSubtitles,
                    icon: const ImageIcon(AssetImage("assets/caption.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                  ChromeCastButton(
                    onButtonCreated: controller.createChromeCast,
                    onSessionStarted: () {
                      controller.chromeCast?.loadMedia(
                        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                        position: 30000,
                        autoplay: true,
                        title: 'Spider-Man: No Way Home',
                        description:
                            'Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.',
                        image: 'https://terrigen-cdn-dev.marvel.com/content/prod/1x/marvsmposterbk_intdesign.jpg',
                        type: ChromeCastMediaType.movie,
                      );
                    },
                  ),
                  MaterialCustomButton(
                    onPressed: () {
                        controller.chapterselect();
                    },
                    icon: const ImageIcon(AssetImage("assets/episodes.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                  MaterialCustomButton(
                    onPressed: controller.qualitySelector,
                    icon: const ImageIcon(AssetImage("assets/setting.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                ],
                bottomButtonBar: [
                  StreamBuilder<Duration>(
                    stream: controller.player.stream.position,

                    builder: (context, position) {

                      if(position.hasData&&position.data!=null){
                        a = position.data!.inSeconds;
                      }
                      // log("${controller.player.state.duration.inSeconds} ", name: "Duration");
                      return Row(
                        children: [
                          MaterialCustomButton(
                            onPressed: (){
                              debugPrint("position is ${position.data?.inSeconds}");
                              if(position.hasData&&position.data!=null){
                                controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(position.data!.inSeconds - 10)).abs()) ));
                              }
                              else{
                                controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(a - 10)).abs()) ));
                                a = min(a-10,0);
                              }


                            },
                            icon: const Icon(Icons.replay_10_outlined),
                            iconSize: 24.0,
                          ),
                          MaterialCustomButton(
                            onPressed: () {
                              if(position.hasData&&position.data!=null){
                                controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(position.data!.inSeconds + 10)).abs()) ));
                              }
                              else{
                                controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(a + 10)).abs()) ));
                                a+=10;
                              }

                            },
                            icon: const Icon(Icons.forward_10_outlined),
                            iconSize: 24.0,
                          ),
                        ],
                      );

                    },
                  ),
                  MaterialDesktopVolumeButton(
                    volumeHighIcon: Icon(Icons.volume_up_rounded),
                    volumeLowIcon: Icon(Icons.volume_down_rounded),

                  ),
                  const Spacer(),
                  StreamBuilder<Duration>(
                    stream: controller.player.stream.position,
                    builder: (context, position) {
                      //  log("${controller.player.state.duration.inSeconds} ", name: "Duration");

                      if (a<=30) {

                        return GestureDetector(
                          onTap: (){
                            debugPrint("Hello world i am here");
                            controller.onSkip();
                          },
                          child:  Stack(
                            children: [
                              AnimationContainer(text: 'SKIP', onPressedController: () {  },),
                              Container(
                                width: 120,
                                height: 60,
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          //
                        );
                        ElevatedButton.icon(
                          onPressed: controller.onSkip,
                          icon: const Icon(Icons.skip_next_sharp),
                          label: const Text("Skip"),
                        );
                      } else
                      if (
                      (controller.player.state.duration.inSeconds - a).abs()<= 50)
                      {
                        return  GestureDetector(
                          onTap: (){
                            debugPrint("Hello world i am here");
                            controller.onNext;
                          },
                          child:  Stack(
                            children: [

                              AnimationContainer(text: 'NEXT EPISODE', onPressedController: () {  },),
                              Container(
                                width: 120,
                                height: 60,
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          //
                        );
                        ElevatedButton.icon(
                          onPressed: controller.onNext,
                          icon: const Icon(Icons.navigate_next),
                          label: const Text("Next Episode"),
                        );
                      }
                      else {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: MaterialPositionIndicator(
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 5),
                  const MaterialFullscreenButton(iconSize: 24),
                ],
              ),
              fullscreen:  MaterialVideoControlsThemeData(
                seekBarMargin: const EdgeInsets.only(bottom: 50,right: 180),
                seekBarThumbSize: 20,
                bottomButtonBarMargin: EdgeInsets.only(bottom: 20),
                automaticallyImplySkipNextButton: false,
                controlsHoverDuration: const Duration(seconds: 5,milliseconds: 400),
                automaticallyImplySkipPreviousButton: false,
                shiftSubtitlesOnControlsVisibilityChange: true,
                volumeGesture: true,
                displaySeekBar: true,
                seekOnDoubleTap: true,
                buttonBarButtonSize: 24.0,
                buttonBarButtonColor: Colors.white,

                topButtonBar: [
                  MaterialFullscreenButton(
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 24.0,
                  ),
                  const SizedBox(height: 8),
                  //TODO: Change to Video Title
                  const Text("Full"),
                  const Spacer(),

                  //TODO: Do Necessary Changes
                  MaterialCustomButton(
                    onPressed: (){
                      controller.speedSelector2();
                    },
                    icon:  const ImageIcon(AssetImage("assets/speedometer.png")),
                    iconSize: 24.0,
                  ),
                  //TODO: Do Necessary Changes
                  MaterialCustomButton(
                    onPressed: controller.toggleSubtitles2,
                    icon: const ImageIcon(AssetImage("assets/caption.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                  ChromeCastButton(
                    onButtonCreated: controller.createChromeCast,
                    onSessionStarted: () {
                      controller.chromeCast?.loadMedia(
                        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                        position: 30000,
                        autoplay: true,
                        title: 'Spider-Man: No Way Home',
                        description:
                        'Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.',
                        image: 'https://terrigen-cdn-dev.marvel.com/content/prod/1x/marvsmposterbk_intdesign.jpg',
                        type: ChromeCastMediaType.movie,
                      );
                    },
                  ),
                  //TODO: Episodes
                  MaterialFullscreenButton(
                    icon: const ImageIcon(AssetImage("assets/episodes.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                  MaterialCustomButton(
                    onPressed: controller.qualitySelector2,
                    icon: const ImageIcon(AssetImage("assets/setting.png")),
                    iconSize: 24.0,
                    iconColor: Colors.white,
                  ),
                ],
                bottomButtonBar: [
               Padding(
                 padding: const EdgeInsets.only(top: 30.0),
                 child: const MaterialPlayOrPauseButton(

                  ),
               ),


                  StreamBuilder<Duration>(
                    stream: controller.player.stream.position,

                    builder: (context, position) {

                      if(position.hasData&&position.data!=null){
                        a = position.data!.inSeconds;
                      }
                     // log("${controller.player.state.duration.inSeconds} ", name: "Duration");
                     return Padding(
                       padding: const EdgeInsets.only(top:37.0),
                       child: Row(
                         children: [
                           MaterialCustomButton(
                             onPressed: (){
                                debugPrint("position is ${position.data?.inSeconds}");
                                if(position.hasData&&position.data!=null){
                                  controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(position.data!.inSeconds - 10)).abs()) ));
                                }
                                else{
                                  controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(a - 10)).abs()) ));
                                  a = min(a-10,0);
                                }


                             },
                             icon: const Icon(Icons.replay_10_outlined),
                             iconSize: 24.0,
                           ),
                           MaterialCustomButton(
                             onPressed: () {
                               if(position.hasData&&position.data!=null){
                                 controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(position.data!.inSeconds + 10)).abs()) ));
                               }
                               else{
                                 controller.player.seek(Duration(seconds: -((controller.player.state.duration.inSeconds-(a + 10)).abs()) ));
                                 a+=10;
                               }

                             },
                             icon: const Icon(Icons.forward_10_outlined),
                             iconSize: 24.0,
                           ),
                         ],
                       ),
                     );

                    },
                  ),

               Padding(
                 padding: const EdgeInsets.only(top: 17.0),
                 child: MaterialDesktopVolumeButton(
                   volumeHighIcon: Icon(Icons.volume_up_rounded),
                   volumeLowIcon: Icon(Icons.volume_down_rounded),

                 ),
               ),
                  const Spacer(),
                  StreamBuilder<Duration>(
                    stream: controller.player.stream.position,
                    builder: (context, position) {
                    //  log("${controller.player.state.duration.inSeconds} ", name: "Duration");

                      if (a<=30) {

                        return GestureDetector(
                            onTap: (){
                              debugPrint("Hello world i am here");
                              controller.onSkip();
                            },
                            child:  Stack(
                              children: [
                                AnimationContainer(text: 'SKIP', onPressedController: () {  },),
                                 Container(
                                  width: 120,
                                   height: 60,
                                   color: Colors.transparent,
                                   ),
                              ],
                            ),
                          //
                      );
                          ElevatedButton.icon(
                          onPressed: controller.onSkip,
                          icon: const Icon(Icons.skip_next_sharp),
                          label: const Text("Skip"),
                        );
                      } else
                        if (
                          (controller.player.state.duration.inSeconds - a).abs()<= 50)
                        {
                        return  GestureDetector(
                          onTap: (){
                            debugPrint("Hello world i am here");
                            controller.onNext;
                          },
                          child:  Stack(
                            children: [

                              AnimationContainer(text: 'NEXT EPISODE', onPressedController: () {  },),
                              Container(
                                width: 120,
                                height: 60,
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          //
                        );
                          ElevatedButton.icon(
                          onPressed: controller.onNext,
                          icon: const Icon(Icons.navigate_next),
                          label: const Text("Next Episode"),
                        );
                      }
                      else {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: MaterialPositionIndicator(
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(width: 5),
                  const MaterialFullscreenButton(iconSize: 24),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ///Video Player
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                        width: MediaQuery.of(context).size.width,
                        child: Video(
                          controller: controller.videoPlayerController,
                          subtitleViewConfiguration: const SubtitleViewConfiguration(
                            style: TextStyle(
                              height: 1.4,
                              fontSize: 24.0,
                              letterSpacing: 0.0,
                              wordSpacing: 0.0,
                              color: Color(0xffffffff),
                              fontWeight: FontWeight.normal,
                              backgroundColor: Color(0xaa000000),
                            ),
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.all(24.0),
                          ),


                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ///Video File From Device
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Obx(
                              () => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: controller.pickVideo,
                                    child: const Text("Choose Video"),
                                  ),
                                  if (controller.videoSource.isNotEmpty) Text("Video Source: ${controller.videoSource.value}"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    ///Video File From Network
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ///Video From Manual Link
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: controller.videoLink,
                              decoration: const InputDecoration(
                                labelText: "Enter Video Link",
                                hintText: "e.g. https://www.example.com/video.mp4",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 242, 227, 227),
                                    width: 0.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(16.0),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            //gjoeaghpaeheeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
                            onPressed: controller.playVideoFromLink,
                            child: const Text("Play From Link"),
                          ),

                          ///MP4 Video From Direct Link
                          ElevatedButton(
                            onPressed: controller.playVideoFromDirectLink,
                            child: const Text("Play MP4"),
                          ),

                          ///MP4 Video From Direct Link(With Qualities)
                          ElevatedButton(
                            onPressed: controller.playVideoFromDirectLinkWithQualities,
                            child: const Text("Play MP4 With Qualities"),
                          ),

                          ///M3U8 Video From Link
                          ElevatedButton(
                            onPressed: controller.playM3U8Video,
                            child: const Text("Play M3U8"),
                          ),

                          ///M3U8 Video From Link(Get Auto Qualities)
                          ElevatedButton(
                            onPressed: controller.playM3U8VideoWithQualities,
                            child: const Text("Play M3U8 Get Auto Qualities"),
                          ),
                        ],
                      ),
                    ),

                    ///Play Video Playlist
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 2,
                          child: Obx(
                            () => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: controller.pickMultipleVideos,
                                  child: const Text("Choose Playlist(Select Multiples Videos)"),
                                ),
                                if (controller.selectVideos.isNotEmpty)
                                  ...controller.selectVideos.map(
                                    (video) => Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(video.name),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          childWhenEnabled: Scaffold(
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                child: Video(
                  controller: controller.videoPlayerController,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 24.0,
                      letterSpacing: 0.0,
                      wordSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                      backgroundColor: Color.fromARGB(170, 45, 46, 98),
                    ),
                    textAlign: TextAlign.center,
                    padding: EdgeInsets.all(24.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}


