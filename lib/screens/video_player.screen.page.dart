// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manual_video_player/screens/home_screen.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:video_cast/chrome_cast_media_type.dart';
import 'package:video_cast/video_cast.dart';

import 'package:manual_video_player/Animation/animated.dart';
import 'package:manual_video_player/models/quality_class.dart';

import '../controllers/home_controller.dart';

Widget MyCustomFullscreenPlayerWidget(MediaInputValue mediaInputValue) {
  return Scaffold(
    body: Center(
      child: ElevatedButton(
          onPressed: () {
            Get.to(VideoPlayerFullscreen(
              mediaInput: mediaInputValue,
            ));
          },
          child: Text("Full Screen player")),
    ),
  );
}

class VideoPlayerFullscreen extends StatefulWidget {
  VideoPlayerFullscreen({
    super.key,
    this.mediaInput,
  });
  final MediaInputValue? mediaInput;

  @override
  State<VideoPlayerFullscreen> createState() => _VideoPlayerFullscreenState();
}

class _VideoPlayerFullscreenState extends State<VideoPlayerFullscreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  VideoState? videoState;
  bool isFullScreen = false;
  bool taskClosed = false;

  var a = 0;

  late Floating pip; // Initializing a variable to handle PiP functionalities
  bool isPipAvailable = false; // Variable to track PiP availability status

  @override
  void initState() {
    pip =
        Floating(); // Instantiating the "Floating" instance to manage PiP functionality
    super.initState();
    _checkPiPAvailability(); // Checking the availability of PiP upon initializing the widget
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Listening to app lifecycle changes to detect when the app enters the hidden state (minimized)
    if (state == AppLifecycleState.hidden && isPipAvailable) {
      // Triggering PiP mode with a landscape aspect ratio when the app is minimized
      pip.enable(aspectRatio: const Rational.landscape());
    }
  }

  // Method to verify the availability of PiP feature asynchronously
  _checkPiPAvailability() async {
    isPipAvailable = await pip
        .isPipAvailable; // Checking if PiP mode is available on the device
    setState(
        () {}); // Triggering a UI update based on the PiP availability status
  }

  setFullScreen() {
    if (!isFullScreen && !taskClosed) {
      isFullScreen = true;
      videoState?.enterFullscreen();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  setHalfScreen() {
    if (isFullScreen && !taskClosed) {
      isFullScreen = false;
      taskClosed = true;
      videoState?.exitFullscreen();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    int x = widget.mediaInput == null
        ? 0
        : widget.mediaInput!.skipButtonShowOn == null
            ? 0
            : widget.mediaInput!.skipButtonShowOn!;
    int y = widget.mediaInput == null
        ? 50
        : widget.mediaInput!.nextButtonShowOn == null
            ? 50
            : widget.mediaInput!.nextButtonDuration!;
    if (widget.mediaInput != null) {
      debugPrint("value is of ${widget.mediaInput!.videoUrl}");
    }

    return GetBuilder<HomeController>(
      init: HomeController(widget.mediaInput),
      builder: (controller) {
        return SafeArea(
          child: PiPSwitcher(
            floating: pip,
            childWhenEnabled: Scaffold(
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
                      icon:
                          const ImageIcon(AssetImage("assets/speedometer.png")),
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
                    widget.mediaInput != null &&
                            widget.mediaInput!.extraWidget != null
                        ? widget.mediaInput!.extraWidget!
                        : MaterialCustomButton(
                            onPressed: controller.qualitySelector,
                            icon: const ImageIcon(
                                AssetImage("assets/setting.png")),
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
                                      seconds: -((controller.player.state
                                                  .duration.inSeconds -
                                              (position.data!.inSeconds - 10))
                                          .abs())));
                                } else {
                                  controller.player.seek(Duration(
                                      seconds: -((controller.player.state
                                                  .duration.inSeconds -
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
                                      seconds: -((controller.player.state
                                                  .duration.inSeconds -
                                              (position.data!.inSeconds + 10))
                                          .abs())));
                                } else {
                                  controller.player.seek(Duration(
                                      seconds: -((controller.player.state
                                                  .duration.inSeconds -
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
                                (widget.mediaInput == null
                                    ? 30 + x
                                    : widget.mediaInput!.skipButtonDuration ==
                                            null
                                        ? 30 + x
                                        : (widget.mediaInput!
                                                .skipButtonDuration! +
                                            x))) &&
                            (widget.mediaInput == null ||
                                (widget.mediaInput != null &&
                                    widget.mediaInput!.skipButtonEnabled)) &&
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
                        } else if (((controller
                                            .player.state.duration.inSeconds -
                                        a)
                                    .abs() <=
                                (widget.mediaInput == null
                                    ? 50
                                    : widget.mediaInput!.nextButtonShowOn ==
                                            null
                                        ? 50
                                        : widget
                                            .mediaInput!.nextButtonShowOn!)) &&
                            (widget.mediaInput == null ||
                                (widget.mediaInput != null &&
                                    widget.mediaInput!.nextButtonEnabled)) &&
                            ((controller.player.state.duration.inSeconds - a)
                                    .abs() >=
                                ((widget.mediaInput == null
                                        ? 50
                                        : widget.mediaInput!.nextButtonShowOn ==
                                                null
                                            ? 50
                                            : widget.mediaInput!
                                                .nextButtonShowOn!) -
                                    y))) {
                          return GestureDetector(
                            onTap: () {
                              widget.mediaInput != null &&
                                      widget.mediaInput!.userProvidedFunction !=
                                          null
                                  ? widget.mediaInput!.userProvidedFunction
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
                  buttonBarButtonSize: 30.0,
                  buttonBarButtonColor: Colors.white,
                  topButtonBar: [
                    const MaterialFullscreenButton(
                      icon: Icon(Icons.arrow_back),
                      iconSize: 30.0,
                    ),
                    const SizedBox(height: 8),
                    const Text("Full"),
                    const Spacer(),
                    MaterialCustomButton(
                      onPressed: () {
                        videoState?.exitFullscreen();
                        controller.speedSelector2();
                      },
                      icon:
                          const ImageIcon(AssetImage("assets/speedometer.png")),
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
                        color: Colors.white,
                        child: SafeArea(
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: List.generate(
                                10,
                                (index) => Container(
                                      width: 30,
                                      height: 30,
                                      color: Colors.blue,
                                      child: Center(
                                        child: Text(index.toString()),
                                      ),
                                    )),
                          ),
                        ),
                      ),
                    ),
                    MaterialCustomButton(
                      onPressed: controller.qualitySelector2,
                      icon: const ImageIcon(AssetImage("assets/setting.png")),
                      iconSize: 30.0,
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
                                  if (position.hasData &&
                                      position.data != null) {
                                    controller.player.seek(Duration(
                                        seconds: -((controller.player.state
                                                    .duration.inSeconds -
                                                (position.data!.inSeconds - 10))
                                            .abs())));
                                  } else {
                                    controller.player.seek(Duration(
                                        seconds: -((controller.player.state
                                                    .duration.inSeconds -
                                                (a - 10))
                                            .abs())));
                                    a = min(a - 10, 0);
                                  }
                                },
                                icon: const Icon(Icons.replay_10_outlined),
                                iconSize: 30.0,
                              ),
                              MaterialCustomButton(
                                onPressed: () {
                                  if (position.hasData &&
                                      position.data != null) {
                                    controller.player.seek(Duration(
                                        seconds: -((controller.player.state
                                                    .duration.inSeconds -
                                                (position.data!.inSeconds + 10))
                                            .abs())));
                                  } else {
                                    controller.player.seek(Duration(
                                        seconds: -((controller.player.state
                                                    .duration.inSeconds -
                                                (a + 10))
                                            .abs())));
                                    a += 10;
                                  }
                                },
                                icon: const Icon(Icons.forward_10_outlined),
                                iconSize: 30.0,
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
                                (widget.mediaInput == null
                                    ? 30 + x
                                    : widget.mediaInput!.skipButtonDuration ==
                                            null
                                        ? 30 + x
                                        : (widget.mediaInput!
                                                .skipButtonDuration! +
                                            x))) &&
                            (widget.mediaInput == null ||
                                (widget.mediaInput != null &&
                                    widget.mediaInput!.skipButtonEnabled)) &&
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
                        } else if (((controller
                                            .player.state.duration.inSeconds -
                                        a)
                                    .abs() <=
                                (widget.mediaInput == null
                                    ? 50
                                    : widget.mediaInput!.nextButtonShowOn ==
                                            null
                                        ? 50
                                        : widget
                                            .mediaInput!.nextButtonShowOn!)) &&
                            (widget.mediaInput == null ||
                                (widget.mediaInput != null &&
                                    widget.mediaInput!.nextButtonEnabled)) &&
                            ((controller.player.state.duration.inSeconds - a)
                                    .abs() >=
                                ((widget.mediaInput == null
                                        ? 50
                                        : widget.mediaInput!.nextButtonShowOn ==
                                                null
                                            ? 50
                                            : widget.mediaInput!
                                                .nextButtonShowOn!) -
                                    y))) {
                          return GestureDetector(
                            onTap: () {
                              widget.mediaInput != null &&
                                      widget.mediaInput!.userProvidedFunction !=
                                          null
                                  ? widget.mediaInput!.userProvidedFunction
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
                      child: Builder(
                        builder: (
                          context,
                        ) {
                          SchedulerBinding.instance.addPostFrameCallback(
                            (timeStamp) {
                              setFullScreen();
                            },
                          );
                          return Video(
                            controls: (state) {
                              videoState = state;
                              return media_kit_video_controls
                                  .AdaptiveVideoControls(state);
                            },
                            onExitFullscreen: () async {
                              // setHalfScreen();
                              defaultExitNativeFullscreen().then((value) {
                                setHalfScreen();
                                setState(() {});
                                Future.delayed(
                                        const Duration(milliseconds: 500))
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              });
                            },
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
                              padding: EdgeInsets.all(12.0),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            childWhenDisabled: Builder(
              builder: (
                context,
              ) {
                SchedulerBinding.instance.addPostFrameCallback(
                  (timeStamp) {
                    setFullScreen();
                  },
                );
                return Video(
                  controls: (state) {
                    videoState = state;
                    return media_kit_video_controls.AdaptiveVideoControls(
                        state);
                  },
                  onExitFullscreen: () async {
                    // setHalfScreen();
                    defaultExitNativeFullscreen().then((value) {
                      setHalfScreen();
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 500))
                          .then((value) {
                        Navigator.pop(context);
                      });
                    });
                  },
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
                    padding: EdgeInsets.all(12.0),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
