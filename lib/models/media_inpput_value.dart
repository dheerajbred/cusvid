import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:manual_video_player/models/quality_class.dart';
import 'package:manual_video_player/screens/home_screen.dart';

class MediaInputValue {
  final MediaType type;
  final String? videoUrl;
  final List<String>? subtitleUrl;

  final List<SkipButton> skipButtons;
  final List<NextButton> nextButtons;

  final bool? extraWidgetEnabled;
  final Widget? extraWidget;
  final List<QualityClass>? qualityUrl;
  final FilePickerResult? file;
  final void Function()? userProvidedFunction;
  final Widget? sidebarWidget;

  MediaInputValue(
      {this.sidebarWidget,
      required this.skipButtons,
      required this.nextButtons,
      required this.type,
      this.videoUrl,
      this.userProvidedFunction,
      this.extraWidget,
      required this.extraWidgetEnabled,
      this.subtitleUrl,
      this.qualityUrl,
      this.file})
      : assert(type != MediaType.playFromLink || videoUrl != null,
            'Video URL is required for Video with link'),
        assert(type != MediaType.chooseVideo || file != null,
            'Video URL is required for Video with link');
}

/// Use this class to enter values of skip
class SkipButton {
  final int duration;
  final int activateOn;
  final String label;
  final int skipTime;
  final bool enabled;

  SkipButton(
      {required this.duration,
      required this.activateOn,
      required this.label,
      required this.skipTime,
      required this.enabled});
}

class NextButton {
  final int duration;
  final int activateTimeLeft;
  final bool enabled;
  final String label;
  final VoidCallback? callback;

  NextButton(
      {required this.duration,
      required this.activateTimeLeft,
      required this.label,
      this.callback,
      required this.enabled});
}
