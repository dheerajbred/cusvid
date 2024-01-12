import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:file_picker/file_picker.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:manual_video_player/models/quality_class.dart';
import 'package:manual_video_player/models/video_class.dart';
import 'package:manual_video_player/screens/home_screen.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_cast/video_cast.dart';

class HomeController extends GetxController {
  Future<void> onInit() async {
    super.onInit();

    if(mediaInputValue!=null){
      if(mediaInputValue!.type==MediaType.chooseVideo){
        videoSource.value = mediaInputValue!.file!.files.single.path ?? "";

        player.stream.position.listen((event) {
          player.setRate(playbackSpeed.value);
        });

        player.open(
          Media(
            videoSource.value,
            httpHeaders: {
              'Foo': 'Bar',
              'Accept': '*/*',
              'Range': 'bytes=0-',
            },
          ),
        );

        if (isSubtitleEnabled.value == true) {
           player.setSubtitleTrack(SubtitleTrack.auto());
        } else {
           player.setSubtitleTrack(SubtitleTrack.no());
        }

      }
      else{
        VideoClass video = VideoClass(
          videoURL: mediaInputValue!.videoUrl!,
          qualities: mediaInputValue!.qualityUrl ?? [],
          subtitle: mediaInputValue!.subtitleUrl??[],
        );
        playVideo(video);
        update();
      }
    }

  }
  HomeController(this.mediaInputValue);
final MediaInputValue? mediaInputValue;
  final Player player = Player();
   RxBool hello = true.obs;
  late VideoController videoPlayerController = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      enableHardwareAcceleration: true,
      androidAttachSurfaceAfterVideoParameters: true,
    ),
  );
  TextEditingController videoLink = TextEditingController();

  ChromeCastController? chromeCast;
  Floating floating = Floating();
  RxBool isSubtitleEnabled = false.obs;
  RxDouble playbackSpeed = 1.0.obs;
  RxBool isCasting = false.obs;
  RxString selectedQualityName = "".obs;
  RxString videoSource = "".obs;
  VideoClass? currentVideo;
  RxList<PlatformFile> selectVideos = <PlatformFile>[].obs;
  Duration currentPosition = Duration.zero;
  Duration position = Duration.zero;
  Container container = Container();
  final String testVideoLink = 'https://server15700.contentdm.oclc.org/dmwebservices/index.php?q=dmGetStreamingFile/p15700coll2/15.mp4/byte/json';
  final String testSubtitleLink = 'https://cdmdemo.contentdm.oclc.org/utils/getfile/collection/p15700coll2/id/18/filename/video2.vtt';





  @override
  onClose() async {
    await player.dispose();

    super.onClose();
  }





  ///Functionality For Pick Video From Storage
  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {

      videoSource.value = result.files.single.path ?? "";

      player.stream.position.listen((event) {
        player.setRate(playbackSpeed.value);
      });

      player.open(
        Media(
          videoSource.value,
          httpHeaders: {
            'Foo': 'Bar',
            'Accept': '*/*',
            'Range': 'bytes=0-',
          },
        ),
      );

      if (isSubtitleEnabled.value == true) {
        await player.setSubtitleTrack(SubtitleTrack.auto());
      } else {
        await player.setSubtitleTrack(SubtitleTrack.no());
      }
    }
    update();
  }

  ///Functionality For Play Video From Link
  Future<void> playVideoFromLink() async {
    if (videoLink.text.trim().isNotEmpty) {
      videoSource.value = videoLink.text.trim();
      player.stream.position.listen(
        (event) {
          player.setRate(playbackSpeed.value);
        },
      );

      if (isSubtitleEnabled.value == true) {
        await player.setSubtitleTrack(SubtitleTrack.auto());
      } else {
        await player.setSubtitleTrack(SubtitleTrack.no());
      }

      player.open(Media(videoSource.value));
    } else {
      Get.showSnackbar(
        const GetSnackBar(
          backgroundColor: Colors.red,
          message: "Please Enter a Link",
          duration: Duration(seconds: 3),
        ),
      );
    }
    update();
  }

  ///Functionality For Play Video From Direct Link
  void playVideoFromDirectLink() {
    VideoClass video = VideoClass(
      videoURL: testVideoLink,
      subtitle: [testSubtitleLink],
    );
    playVideo(video);
    update();
  }

  ///Functionality For Play Video From Direct Link With Qualities
  void playVideoFromDirectLinkWithQualities() {
    VideoClass video = VideoClass(
      videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      qualities: [
        QualityClass(name: "480x270", link: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
        QualityClass(name: "1280x720", link: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
      ],
      subtitle: ["https://www.capsubservices.com/assets/downloads/subtitle/01hour/SubRip%2001%20Hour.srt"],
    );
    playVideo(video);
    update();
  }

  ///Functionality For Play M3U8 Video
  void playM3U8Video() {
    VideoClass video = VideoClass(
      videoURL: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8",
    );
    playVideo(video);
    update();
  }

  ///Functionality For Play M3U8 Video With Qualities
  void playM3U8VideoWithQualities() async {
    final content = await get(Uri.parse("https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"));
    List<QualityClass> qualities = [];
    try {
      var hlsPlaylistParser = HlsPlaylistParser.create();
      var playlist = await hlsPlaylistParser.parseString(Uri.parse(''), content.body);
      if (playlist is HlsMasterPlaylist) {
        List<Variant> variants = playlist.variants;

        for (Variant variant in variants) {
          qualities.add(
            QualityClass(
              name: "${variant.format.width}x${variant.format.height}",
              link: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/${variant.url}",
            ),
          );
        }
      } else if (playlist is HlsMediaPlaylist) {
        log('Single media playlist detected.', name: "Single");
      }
    } catch (e) {
      log('Error parsing M3U8 file: $e', name: "Error");
    }
    VideoClass video = VideoClass(
      videoURL: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8",
      qualities: qualities,
    );
    playVideo(video);
    update();
  }

  ///Functionality For Play Video
  Future<void> playVideo(VideoClass video) async {
    currentVideo = video;

    player.open(
      Media(
        video.videoURL,
        httpHeaders: video.httpHeaders,
      ),
    );

    if (isSubtitleEnabled.value == true && video.subtitle != null && video.subtitle![0].trim().isNotEmpty) {
      player.setSubtitleTrack(SubtitleTrack.uri(video.subtitle![0], language: "en"));
    } else {
      player.setSubtitleTrack(SubtitleTrack.no());
    }

    update();
  }
  ///Functionality For Play Playlist
  Future<void> pickMultipleVideos() async {
    List<PlatformFile> pickedFiles = [];

    try {
      pickedFiles = (await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.video))!.files;
    } catch (e) {
      log("Error Picking Files: $e", name: "Error On Select Files");
      return;
    }

    List<Media> mediaList = pickedFiles
        .map((file) => Media(
              file.path!,
              httpHeaders: {
                'Foo': 'Bar',
                'Accept': '*/*',
                'Range': 'bytes=0-',
              },
            ))
        .toList();

    Playlist playlist = Playlist(mediaList);

    try {
      await player.open(playlist);
    } catch (e) {
      log("Error Opening Playlist: $e", name: "Playlist Error");
      return;
    }

    selectVideos.value = pickedFiles;

    player.stream.position.listen((event) {
      player.setRate(playbackSpeed.value);
    });

    update();
  }

  ///Functionality For Enable PIP Mode
  Future<void> enablePIPMode(BuildContext context) async {
    final rational = Rational.landscape();
    final screenSize = MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final status = await floating.enable(
      aspectRatio: rational,
      sourceRectHint: Rectangle<int>(
        0,
        (screenSize.height ~/ 2) - (height ~/ 2),
        screenSize.width.toInt(),
        height,
      ),
    );
    update();
  }

  ///Functionality For Show Subtitle
  Future<void> toggleSubtitles() async {
    Get.bottomSheet(
      Wrap(
          children: [
            Container(
                height: Get.height*0.4,
                width: Get.width,
                child: Column(
                  children: [
                    Align(alignment: Alignment.centerLeft,child: Text("Subtitile",style: TextStyle(
                        fontSize: 20
                    ),)),
                    SizedBox(height: 20,),
                    Expanded(
                      child: ListView(
                        shrinkWrap: false,
                        physics: NeverScrollableScrollPhysics(),
                        // padding: EdgeInsets.zero,
                        children: ["English","None"].map((language) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              decoration: BoxDecoration(

                                  color:  isSubtitleEnabled.value&&language=="English"||language=="None"&&!isSubtitleEnabled.value? Colors.red:Colors.black45,
                                  borderRadius: BorderRadius.all(Radius.circular(15))

                              ),
                              child: ListTile(
                                title: Text("${language}", style: TextStyle(color: Colors.white)),
                                onTap: (){
                                  if(language=='None'){
                                    isSubtitleEnabled.value  = false;
                                    player.setSubtitleTrack(SubtitleTrack.no());
                                  }
                                  else{
                                    isSubtitleEnabled.value  = true;
                                    player.setSubtitleTrack(SubtitleTrack.uri(testSubtitleLink, language: 'en'));
                                  }
                                  Get.back();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),


                  ],
                )


            )
          ],
      )
    );
  }
  Future<void> toggleSubtitles2 () async{
    Get.dialog(
      AlertDialog(
        alignment: Alignment.centerRight,
        backgroundColor: Colors.black,
        content: SingleChildScrollView(
          child: Container(
              height: Get.height,
              width: Get.width*0.4,
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft,child: Text("Subtitile",style: TextStyle(
                      fontSize: 20
                  ),)),
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView(
                      shrinkWrap: false,
                      physics: NeverScrollableScrollPhysics(),
                      // padding: EdgeInsets.zero,
                      children: ["English","None"].map((language) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(

                                color:  isSubtitleEnabled.value&&language=="English"||language=="None"&&!isSubtitleEnabled.value? Colors.red:Colors.black45,
                                borderRadius: BorderRadius.all(Radius.circular(15))

                            ),
                            child: ListTile(
                              title: Text("${language}x", style: TextStyle(color: Colors.white)),
                              onTap: (){
                                if(language=='None'){
                                  isSubtitleEnabled.value  = false;
                                  player.setSubtitleTrack(SubtitleTrack.no());
                                }
                                else{
                                  isSubtitleEnabled.value  = true;
                                  player.setSubtitleTrack(SubtitleTrack.uri(testSubtitleLink, language: 'en'));
                                }
                                Get.back();
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),


                ],
              )


          ),
        ),
      ),


    );
    update();
  }

  ///Functionality For Change Playback Speed
  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    player.setRate(playbackSpeed.value);
    update();
  }

  ///Widgets Of Show Speed Sheet
  void speedSelector() {
    Get.back();
    Get.bottomSheet(
      Wrap(
       children: [
         Container(
           height: Get.height*0.4,
             width: Get.width,
             child: Padding(
               padding: const EdgeInsets.only(left: 18.0,right: 10),
               child: Column(
                 children: [
                   Padding(
                     padding: const EdgeInsets.only(left: 8.0,top: 18),
                     child: Align(alignment: Alignment.centerLeft,child: Text("Playback Speed",style: TextStyle(
                         fontSize: 20
                     ),)),
                   ),
                   SizedBox(height: 20,),
                   Expanded(
                     child: ListView(
                       shrinkWrap: false,
                       physics: NeverScrollableScrollPhysics(),
                       // padding: EdgeInsets.zero,
                       children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                         return Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Container(
                             decoration: BoxDecoration(

                                 color: speed == playbackSpeed.value ? Colors.red:Colors.black45,
                                 borderRadius: BorderRadius.all(Radius.circular(15))

                             ),
                             child: ListTile(
                               title: Text("${speed}x", style: TextStyle(color: Colors.white)),
                               onTap: () {
                                 changePlaybackSpeed(speed);
                                 Get.back();
                               },
                             ),
                           ),
                         );
                       }).toList(),
                     ),
                   ),


                 ],
               ),
             )


         ),
       ],
      ),
      backgroundColor: Colors.black,
    );
    update();
  }
  void speedSelector2() {


    // Uncomment the line below to start the animation automatically
    // _animationController.forward();
    Get.dialog(
        AlertDialog(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.black,
          content: SingleChildScrollView(
            child: Container(
      height: Get.height,
      width: Get.width*0.4,
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft,child: Text("Playback Speed",style: TextStyle(
                    fontSize: 20
                  ),)),
                    SizedBox(height: 20,),
                    Expanded(
                      child: ListView(
                        shrinkWrap: false,
                        physics: NeverScrollableScrollPhysics(),
                        // padding: EdgeInsets.zero,
                        children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              decoration: BoxDecoration(

                                color: speed == playbackSpeed.value ? Colors.red:Colors.black45,
                                borderRadius: BorderRadius.all(Radius.circular(15))

                              ),
                              child: ListTile(
                                title: Text("${speed}x", style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  changePlaybackSpeed(speed);
                                  Get.back();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),


                ],
              )


    ),
          ),
        ),
      useSafeArea: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionCurve: Curves.linear,
    );


    update();
  }
  void chapterselect(){
    Get.back();
    Get.bottomSheet(Wrap(
      children: [
        SingleChildScrollView(
          child: Container(
              height: Get.height*0.4,
              width: Get.width,
              color: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0,right: 18),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0,top: 10),
                      child: Align(alignment: Alignment.centerLeft,child: Text("Chapters",style: TextStyle(
                          fontSize: 20
                      ),)),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: false,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index)
                          {
                            return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                          child: Text("${index+1}",style: TextStyle(
                                              fontSize: Get.width*0.045
                                          ),),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),

                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),

                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                          child: Text("${index+5}",style: TextStyle(
                                              fontSize: Get.width*0.045
                                          ),),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),

                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                          child: Text("${index+9}",style: TextStyle(
                                              fontSize: Get.width*0.045
                                          ),),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),

                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                          child: Text("${index+13}",style: TextStyle(
                                              fontSize: Get.width*0.045
                                          ),),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            );
                          }
                      ),
                    ),


                  ],
                ),
              )


          ),
        )
      ],
    ));
  }
  void chapterselect2(){

    Get.dialog(
      AlertDialog(
        alignment: Alignment.centerRight,
        backgroundColor: Colors.black,
        content: SingleChildScrollView(
          child: Container(
              height: Get.height,
              width: Get.width*0.4,
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft,child: Text("Chapters",style: TextStyle(
                      fontSize: 20
                  ),)),
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: false,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index)
                       {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                    child: Text("${index+1}",style: TextStyle(
                                      fontSize: Get.width*0.045
                                    ),),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),

                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),

                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                    child: Text("${index+5}",style: TextStyle(
                                        fontSize: Get.width*0.045
                                    ),),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),

                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                    child: Text("${index+9}",style: TextStyle(
                                        fontSize: Get.width*0.045
                                    ),),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),

                                  ),

                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                    child: Text("${index+13}",style: TextStyle(
                                        fontSize: Get.width*0.045
                                    ),),
                                  ),
                                ),
                              ),
                            ],
                          )
                        );
                      }
                    ),
                  ),


                ],
              )


          ),
        ),
      ),


    );
    update();
  }

  ///Widgets Of Show Qualities
  void qualitySelector() {
    Get.back();
    Get.bottomSheet(
      Wrap(
        children: [
          Container(
            height: Get.height*0.4,
            width: Get.width,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0,left: 12),
                    child: Text(
                      "Video Quality",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: currentVideo!=null&&currentVideo?.qualities!=null?ListView(
                    shrinkWrap: false,
                    physics: NeverScrollableScrollPhysics(),

                    children: [

                      for (var i = 0; i < currentVideo!.qualities!.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:currentVideo!.qualities![i].name ==
                                  selectedQualityName.value
                                  ? Colors.red
                                  : Colors.black45,
                              borderRadius:
                              BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ListTile(
                              title: Text(
                                currentVideo!.qualities![i].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                Get.back();
                                currentPosition = player.state.position;
                                await player.open(
                                  Media(
                                    currentVideo!.qualities![i].link,
                                    httpHeaders: currentVideo!.httpHeaders,
                                  ),
                                  play: false,
                                );
                                await player.stream.buffer.first;
                                player.seek(currentPosition);
                                await player.play();
                                selectedQualityName.value =
                                    currentVideo!.qualities![i].name;
                                update();
                              },
                            ),
                          ),
                        ),
                    ],
                  ):const SizedBox(),
                ),
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
    update();
  }
  void qualitySelector2() {
    Get.dialog(
      AlertDialog(
        alignment: Alignment.centerRight,
        backgroundColor: Colors.black,
        content: SingleChildScrollView(
          child: Container(
            height: Get.height,
            width: Get.width * 0.4,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Video Quality",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: currentVideo!=null&&currentVideo?.qualities!=null?ListView(
                    shrinkWrap: false,
                    physics: NeverScrollableScrollPhysics(),

                    children: [

                      for (var i = 0; i < currentVideo!.qualities!.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:currentVideo!.qualities![i].name ==
                            selectedQualityName.value
                            ? Colors.red
                                : Colors.black45,
                              borderRadius:
                              BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ListTile(
                              title: Text(
                                currentVideo!.qualities![i].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                Get.back();
                                currentPosition = player.state.position;
                                await player.open(
                                  Media(
                                    currentVideo!.qualities![i].link,
                                    httpHeaders: currentVideo!.httpHeaders,
                                  ),
                                  play: false,
                                );
                                await player.stream.buffer.first;
                                player.seek(currentPosition);
                                await player.play();
                                selectedQualityName.value =
                                    currentVideo!.qualities![i].name;
                                update();
                              },
                            ),
                          ),
                        ),
                    ],
                  ):const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      )

    );
    update();
  }


  ///Functionality For Create Cast
  void createChromeCast(ChromeCastController controller) {
    chromeCast = controller;
    chromeCast?.addSessionListener();
    update();
  }

  ///Functionality For Skip Button\
  Future<void> onSkip() async {
    player.seek(const Duration(minutes: 1));
    await player.play();
    update();
  }
  Future<void> onSkip2(int second) async {
    player.seek( Duration(milliseconds: second));
    await player.play();
    update();
  }

  ///Functionality For Skip Button\
  Future<void> onNext() async {
    player.next();
    await player.play();
    update();
  }
}


