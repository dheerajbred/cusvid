import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/Animation/animated.dart';
import 'package:manual_video_player/models/quality_class.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:video_cast/chrome_cast_media_type.dart';
import 'package:video_cast/video_cast.dart';

import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, this.mediaInput});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var a = 0;
  final MediaInputValue? mediaInput;

  @override
  Widget build(BuildContext context) {
    int x = mediaInput == null
        ? 0
        : mediaInput!.skipButtonShowOn == null
            ? 0
            : mediaInput!.skipButtonShowOn!;
    int y = mediaInput == null
        ? 50
        : mediaInput!.nextButtonShowOn == null
            ? 50
            : mediaInput!.nextButtonDuration!;
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
                    controller.chapterselect();
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
                StreamBuilder<Duration>(
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
                                  seconds: -((controller
                                              .player.state.duration.inSeconds -
                                          (position.data!.inSeconds - 10))
                                      .abs())));
                            } else {
                              controller.player.seek(Duration(
                                  seconds: -((controller
                                              .player.state.duration.inSeconds -
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
                                  seconds: -((controller
                                              .player.state.duration.inSeconds -
                                          (position.data!.inSeconds + 10))
                                      .abs())));
                            } else {
                              controller.player.seek(Duration(
                                  seconds: -((controller
                                              .player.state.duration.inSeconds -
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
                const MaterialDesktopVolumeButton(
                  volumeHighIcon: Icon(Icons.volume_up_rounded),
                  volumeLowIcon: Icon(Icons.volume_down_rounded),
                ),
                const Spacer(),
                StreamBuilder<Duration>(
                  stream: controller.player.stream.position,
                  builder: (context, position) {
                    //  log("${controller.player.state.duration.inSeconds} ", name: "Duration");

                    if ((a <=
                            (mediaInput == null
                                ? 30 + x
                                : mediaInput!.skipButtonDuration == null
                                    ? 30 + x
                                    : (mediaInput!.skipButtonDuration! + x))) &&
                        (mediaInput == null ||
                            (mediaInput != null &&
                                mediaInput!.skipButtonEnabled)) &&
                        (a >= x)) {
                      return GestureDetector(
                        onTap: () {
                          debugPrint("Hello world i am here");
                          controller.onSkip();
                        },
                        child: Stack(
                          children: [
                            AnimationContainer(
                              text: 'SKIP',
                              onPressedController: () {},
                            ),
                            Container(
                              width: 120,
                              height: 60,
                              color: Colors.transparent,
                            ),
                          ],
                        ),
                        //
                      );
                    } else if (((controller.player.state.duration.inSeconds - a)
                                .abs() <=
                            (mediaInput == null
                                ? 50
                                : mediaInput!.nextButtonShowOn == null
                                    ? 50
                                    : mediaInput!.nextButtonShowOn!)) &&
                        (mediaInput == null ||
                            (mediaInput != null &&
                                mediaInput!.nextButtonEnabled)) &&
                        ((controller.player.state.duration.inSeconds - a)
                                .abs() >=
                            ((mediaInput == null
                                    ? 50
                                    : mediaInput!.nextButtonShowOn == null
                                        ? 50
                                        : mediaInput!.nextButtonShowOn!) -
                                y))) {
                      return GestureDetector(
                        onTap: () {
                          mediaInput != null &&
                                  mediaInput!.userProvidedFunction != null
                              ? mediaInput!.userProvidedFunction
                              : controller.onNext;
                          debugPrint("Hello world i am here");
                        },
                        child: Stack(
                          children: [
                            AnimationContainer(
                              text: 'NEXT EPISODE',
                              onPressedController: () {},
                            ),
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
                    } else {
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
            fullscreen: MaterialVideoControlsThemeData(
              seekBarMargin: const EdgeInsets.only(bottom: 50, right: 180),
              seekBarThumbSize: 20,
              bottomButtonBarMargin: const EdgeInsets.only(bottom: 20),
              automaticallyImplySkipNextButton: false,
              controlsHoverDuration:
                  const Duration(seconds: 5, milliseconds: 400),
              automaticallyImplySkipPreviousButton: false,
              shiftSubtitlesOnControlsVisibilityChange: true,
              volumeGesture: true,
              displaySeekBar: true,
              seekOnDoubleTap: true,
              buttonBarButtonSize: 24.0,
              buttonBarButtonColor: Colors.white,
              topButtonBar: [
                const MaterialFullscreenButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 24.0,
                ),
                const SizedBox(height: 8),
                //TODO: Change to Video Title
                const Text("Full"),
                const Spacer(),

                //TODO: Do Necessary Changes
                MaterialCustomButton(
                  onPressed: () {
                    controller.speedSelector2();
                  },
                  icon: const ImageIcon(AssetImage("assets/speedometer.png")),
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
                //TODO: Episodes
                MaterialCustomButton(
                  onPressed: controller.chapterselect2,
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
                const Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: MaterialPlayOrPauseButton(),
                ),
                StreamBuilder<Duration>(
                  stream: controller.player.stream.position,
                  builder: (context, position) {
                    if (position.hasData && position.data != null) {
                      a = position.data!.inSeconds;
                    }
                    // log("${controller.player.state.duration.inSeconds} ", name: "Duration");
                    return Padding(
                      padding: const EdgeInsets.only(top: 37.0),
                      child: Row(
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
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 29.0),
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

                    if ((a <=
                            (mediaInput == null
                                ? 30 + x
                                : mediaInput!.skipButtonDuration == null
                                    ? 30 + x
                                    : (mediaInput!.skipButtonDuration! + x))) &&
                        (mediaInput == null ||
                            (mediaInput != null &&
                                mediaInput!.skipButtonEnabled)) &&
                        (a >= x)) {
                      return GestureDetector(
                        onTap: () {
                          debugPrint("Hello world i am here");
                          controller.onSkip();
                        },
                        child: Stack(
                          children: [
                            AnimationContainer(
                              text: 'SKIP',
                              onPressedController: () {},
                            ),
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
                    } else if (((controller.player.state.duration.inSeconds - a)
                                .abs() <=
                            (mediaInput == null
                                ? 50
                                : mediaInput!.nextButtonShowOn == null
                                    ? 50
                                    : mediaInput!.nextButtonShowOn!)) &&
                        (mediaInput == null ||
                            (mediaInput != null &&
                                mediaInput!.nextButtonEnabled)) &&
                        ((controller.player.state.duration.inSeconds - a)
                                .abs() >=
                            ((mediaInput == null
                                    ? 50
                                    : mediaInput!.nextButtonShowOn == null
                                        ? 50
                                        : mediaInput!.nextButtonShowOn!) -
                                y))) {
                      return GestureDetector(
                        onTap: () {
                          mediaInput != null &&
                                  mediaInput!.userProvidedFunction != null
                              ? mediaInput!.userProvidedFunction
                              : controller.onNext;
                          debugPrint("Hello world i am here");
                        },
                        child: Stack(
                          children: [
                            AnimationContainer(
                              text: 'NEXT EPISODE',
                              onPressedController: () {},
                            ),
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
                    } else {
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
              child: Center(
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

class MediaInputValue {
  final MediaType type;
  final String? videoUrl;
  final List<String>? subtitleUrl;
  final bool skipButtonEnabled;
  final int? skipButtonShowOn;
  final int? skipButtonSkipTo;
  final int? skipButtonDuration;

  final int? nextButtonDuration;
  // nextButtonShowOn -> time in seconds before the video ends..
  final int? nextButtonShowOn;
  final bool nextButtonEnabled;
  final bool? extraWidgetEnabled;
  final Widget? extraWidget;
  final List<QualityClass>? qualityUrl;
  final FilePickerResult? file;
  final void Function()? userProvidedFunction;
  MediaInputValue(
      {required this.type,
      this.nextButtonShowOn,
      this.skipButtonSkipTo,
      this.skipButtonShowOn,
      required this.skipButtonEnabled,
      this.videoUrl,
      this.userProvidedFunction,
      this.extraWidget,
      required this.extraWidgetEnabled,
      required this.nextButtonEnabled,
      this.subtitleUrl,
      this.nextButtonDuration,
      this.skipButtonDuration,
      this.qualityUrl,
      this.file})
      : assert(type != MediaType.playFromLink || videoUrl != null,
            'Video URL is required for Video with link'),
        assert(type != MediaType.chooseVideo || file != null,
            'Video URL is required for Video with link');
}
