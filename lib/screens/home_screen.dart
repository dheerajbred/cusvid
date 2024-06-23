// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/models/media_inpput_value.dart';
import 'package:manual_video_player/screens/video_player.screen.page.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/models/skip_next_button.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:video_cast/chrome_cast_media_type.dart';
import 'package:video_cast/video_cast.dart';

import 'package:manual_video_player/Animation/animated.dart';
import 'package:manual_video_player/models/quality_class.dart';

import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    super.key,
    this.mediaInput,
  });
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var a = 0;
  final MediaInputValue? mediaInput;

  @override
  Widget build(BuildContext context) {
    if (mediaInput != null) {
      debugPrint("value is of ${mediaInput!.videoUrl}");
    }

    return GetBuilder<HomeController>(
      init: HomeController(mediaInput),
      builder: (controller) => SafeArea(
        child: Scaffold(
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
              controlsHoverDuration:
                  const Duration(seconds: 5, milliseconds: 400),
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
                  icon: const ImageIcon(AssetImage("assets/speedometer.png")),
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
                      url:
                          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                      position: 30000,
                      autoplay: true,
                      title: 'Spider-Man: No Way Home',
                      description:
                          'Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.',
                      image:
                          'https://terrigen-cdn-dev.marvel.com/content/prod/1x/marvsmposterbk_intdesign.jpg',
                      type: ChromeCastMediaType.movie,
                    );
                  },
                ),
                MaterialCustomButton(
                  onPressed: () {
                    controller.chapterselect(mediaInput?.sidebarWidget);
                  },
                  icon: const ImageIcon(AssetImage("assets/episodes.png")),
                  iconSize: 24.0,
                  iconColor: Colors.white,
                ),
                mediaInput != null && mediaInput!.extraWidget != null
                    ? mediaInput!.extraWidget!
                    : MaterialCustomButton(
                        onPressed: controller.qualitySelector,
                        icon: const ImageIcon(AssetImage("assets/setting.png")),
                        iconSize: 24.0,
                        iconColor: Colors.white,
                      ),
              ],
              bottomButtonBar: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: StreamBuilder<Duration>(
                    stream: controller.player.stream.position,
                    builder: (context, position) {
                      if (position.hasData && position.data != null) {
                        a = position.data!.inSeconds;
                      }
                      // log("${controller.player.state.duration.inSeconds} ", name: "Duration");
                      return Row(
                        children: [
                          MaterialCustomButton(
                            onPressed: () {
                              debugPrint(
                                  "position is ${position.data?.inSeconds}");
                              if (position.hasData && position.data != null) {
                                controller.player.seek(Duration(
                                    seconds: -((controller.player.state.duration
                                                .inSeconds -
                                            (position.data!.inSeconds - 10))
                                        .abs())));
                              } else {
                                controller.player.seek(Duration(
                                    seconds: -((controller.player.state.duration
                                                .inSeconds -
                                            (a - 10))
                                        .abs())));
                                a = min(a - 10, 0);
                              }
                            },
                            icon: const Icon(Icons.replay_10_outlined),
                            iconSize: 24.0,
                          ),
                          MaterialCustomButton(
                            onPressed: () {
                              if (position.hasData && position.data != null) {
                                controller.player.seek(Duration(
                                    seconds: -((controller.player.state.duration
                                                .inSeconds -
                                            (position.data!.inSeconds + 10))
                                        .abs())));
                              } else {
                                controller.player.seek(Duration(
                                    seconds: -((controller.player.state.duration
                                                .inSeconds -
                                            (a + 10))
                                        .abs())));
                                a += 10;
                              }
                            },
                            icon: const Icon(Icons.forward_10_outlined),
                            iconSize: 24.0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: MaterialDesktopVolumeButton(
                    volumeHighIcon: Icon(Icons.volume_up_rounded),
                    volumeLowIcon: Icon(Icons.volume_down_rounded),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 5),
                MaterialFullscreenButton(
                  iconSize: 24,
                  skipButton: mediaInput?.skipButtons
                          .map((e) => MediaKitSkipButton(
                              duration: e.duration,
                              activateOn: e.activateOn,
                              label: e.label,
                              skipTime: e.skipTime,
                              enabled: e.enabled))
                          .toList() ??
                      [],
                  nextButton: mediaInput?.nextButtons
                          .map((e) => MediaKitNextButton(
                              duration: e.duration,
                              callback: e.callback,
                              activateTimeLeft: e.activateTimeLeft,
                              label: e.label,
                              enabled: e.enabled))
                          .toList() ??
                      [],
                )
              ],
            ),
            fullscreen: MaterialVideoControlsThemeData(
              seekBarMargin: const EdgeInsets.only(bottom: 50),
              seekBarThumbSize: 20,
              bottomButtonBarMargin: EdgeInsets.zero,
              automaticallyImplySkipNextButton: false,
              controlsHoverDuration:
                  const Duration(seconds: 5, milliseconds: 400),
              automaticallyImplySkipPreviousButton: false,
              shiftSubtitlesOnControlsVisibilityChange: true,
              volumeGesture: true,
              displaySeekBar: true,
              brightnessGesture: true,
              seekGesture: true,
              seekOnDoubleTap: true,
              buttonBarButtonSize: 30.0,
              speedUpOnLongPress: true,
              buttonBarButtonColor: Colors.white,
              topButtonBar: [
                const Text(
                  "Happy Bunny - Episode 2 @2kbps",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                MaterialCustomButton(
                  onPressed: () {
                    controller.speedSelector2();
                  },
                  icon: const ImageIcon(AssetImage("assets/speedometer.png")),
                  iconSize: 30.0,
                ),
                MaterialCustomButton(
                  onPressed: controller.toggleSubtitles2,
                  icon: const ImageIcon(AssetImage("assets/caption.png")),
                  iconSize: 30.0,
                  iconColor: Colors.white,
                ),
                ChromeCastButton(
                  onButtonCreated: controller.createChromeCast,
                  onSessionStarted: () {
                    controller.chromeCast?.loadMedia(
                      url:
                          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                      position: 30000,
                      autoplay: true,
                      title: 'Spider-Man: No Way Home',
                      description:
                          'Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.',
                      image:
                          'https://terrigen-cdn-dev.marvel.com/content/prod/1x/marvsmposterbk_intdesign.jpg',
                      type: ChromeCastMediaType.movie,
                    );
                  },
                ),
                MaterialFullscreenSidebarButton(
                  icon: const ImageIcon(AssetImage("assets/episodes.png")),
                  slidebar: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black12,
                      child: Wrap(
                        children: [
                          SingleChildScrollView(
                            child: Container(
                                width: Get.width,
                                height: Get.height,
                                color: Colors.black45,
                                child: mediaInput?.sidebarWidget ??
                                    SidebarWidget()),
                          )
                        ],
                      )),
                ),
                MaterialCustomButton(
                  onPressed: controller.qualitySelector2,
                  icon: const Icon(Icons.more_vert),
                  iconSize: 30.0,
                  iconColor: Colors.white,
                ),
              ],
              bottomButtonBar: [
                Spacer(),
                const MaterialFullscreenButton()
                // Padding(
                //   padding: const EdgeInsets.only(top: 35.0),
                //   child: StreamBuilder<Duration>(
                //     stream: controller.player.stream.position,
                //     builder: (context, position) {
                //       if (position.hasData && position.data != null) {
                //         a = position.data!.inSeconds;
                //       }
                //       // log("${controller.player.state.duration.inSeconds} ", name: "Duration");
                //       return Row(
                //         children: [
                //           MaterialCustomButton(
                //             onPressed: () {
                //               debugPrint(
                //                   "position is ${position.data?.inSeconds}");
                //               if (position.hasData && position.data != null) {
                //                 controller.player.seek(Duration(
                //                     seconds: -((controller.player.state.duration
                //                                 .inSeconds -
                //                             (position.data!.inSeconds - 10))
                //                         .abs())));
                //               } else {
                //                 controller.player.seek(Duration(
                //                     seconds: -((controller.player.state.duration
                //                                 .inSeconds -
                //                             (a - 10))
                //                         .abs())));
                //                 a = min(a - 10, 0);
                //               }
                //             },
                //             icon: const Icon(Icons.replay_10_outlined),
                //             iconSize: 30.0,
                //           ),
                //           MaterialCustomButton(
                //             onPressed: () {
                //               if (position.hasData && position.data != null) {
                //                 controller.player.seek(Duration(
                //                     seconds: -((controller.player.state.duration
                //                                 .inSeconds -
                //                             (position.data!.inSeconds + 10))
                //                         .abs())));
                //               } else {
                //                 controller.player.seek(Duration(
                //                     seconds: -((controller.player.state.duration
                //                                 .inSeconds -
                //                             (a + 10))
                //                         .abs())));
                //                 a += 10;
                //               }
                //             },
                //             icon: const Icon(Icons.forward_10_outlined),
                //             iconSize: 30.0,
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                // ),
                // const Spacer(),
                // const Padding(
                //   padding: EdgeInsets.only(bottom: 4),
                //   child: MaterialPositionIndicator(
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
                // const SizedBox(width: 5),
                // const MaterialFullscreenButton(iconSize: 24),
              ],
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Video(
                            controller: controller.videoPlayerController,
                            subtitleViewConfiguration:
                                const SubtitleViewConfiguration(
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
                          Positioned(
                            bottom: -10,
                            right: 20,
                            child: StreamBuilder<Duration>(
                              stream: controller.player.stream.position,
                              builder: (context, position) {
                                if (position.data == null) {
                                  return const SizedBox.shrink();
                                }

                                // Check if any skip button should be shown
                                List<Widget> skipWidgets = [];
                                if (mediaInput != null) {
                                  skipWidgets = mediaInput!.skipButtons
                                      .where((skip) =>
                                          skip.enabled &&
                                          position.data!.inSeconds >=
                                              skip.activateOn &&
                                          position.data!.inSeconds <=
                                              (skip.activateOn + skip.duration))
                                      .map((skip) {
                                    return GestureDetector(
                                      onTap: () {
                                        controller.onSkip(
                                            seconds: skip.activateOn +
                                                skip.skipTime);
                                      },
                                      child: Stack(
                                        children: [
                                          AnimationContainer(
                                            text: skip.label,
                                            onPressedController: () {},
                                          ),
                                          Container(
                                            width: 120,
                                            height: 60,
                                            color: Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                }

                                return Stack(
                                  children: skipWidgets,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            right: 20,
                            child: StreamBuilder<Duration>(
                              stream: controller.player.stream.position,
                              builder: (context, position) {
                                if (position.data == null) {
                                  return const SizedBox.shrink();
                                }

                                final duration =
                                    (controller.player.state.duration.inSeconds)
                                        .abs();

                                List<Widget> skipWidgets = [];
                                if (mediaInput != null) {
                                  skipWidgets = mediaInput!.nextButtons
                                      .where((next) =>
                                          (duration -
                                                  position.data!.inSeconds) <=
                                              next.activateTimeLeft &&
                                          (duration -
                                                  position.data!.inSeconds) >=
                                              next.duration &&
                                          next.enabled)
                                      .map((next) {
                                    return GestureDetector(
                                      onTap: next.callback,
                                      child: Stack(
                                        children: [
                                          AnimationContainer(
                                            text: next.label,
                                            onPressedController: () {},
                                          ),
                                          Container(
                                            width: 120,
                                            height: 60,
                                            color: Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                }

                                return Stack(
                                  children: skipWidgets,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      child: const Text("Play"),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerFullscreen(
                              mediaInput: mediaInput,
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              controller.playVideoFromDirectLinkWithQualities();
            },
          ),
        ),
      ),
    );
  }
}

enum MediaType {
  playFromLink,
  chooseVideo,
}

Widget MyCustomPlayerWidget(MediaInputValue mediaInputValue) {
  return HomeScreen(mediaInput: mediaInputValue);
}
