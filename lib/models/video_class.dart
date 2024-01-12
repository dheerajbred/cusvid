import 'package:manual_video_player/models/quality_class.dart';

class VideoClass {
  String videoURL;
  List<String>? subtitle;
  Map<String, String>? httpHeaders;
  List<QualityClass>? qualities;

  VideoClass({
    required this.videoURL,
    this.subtitle,
    this.httpHeaders,
    this.qualities,
  });
}
