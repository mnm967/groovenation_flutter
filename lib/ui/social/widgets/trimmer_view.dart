import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  final Function _onVideoPicked;

  TrimmerView(this.file, this._onVideoPicked);

  @override
  _TrimmerViewState createState() => _TrimmerViewState(_onVideoPicked);
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();
  final Function onVideoPicked;

  _TrimmerViewState(this.onVideoPicked);

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool _isCompressing = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await _trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    print("in path: " + widget.file.path);

    _loadVideo();
  }

  // Future<String?> _compressVideo(String videoPath) async {
  //   print("Path: " + videoPath);
  //   MediaInfo? mediaInfo = await (VideoCompress.compressVideo(
  //     videoPath,
  //     quality: VideoQuality.MediumQuality,
  //     deleteOrigin: true, // It's false by default
  //   ));

  //   return mediaInfo!.path;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Video"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: _progressVisibility || _isCompressing,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then(
                            (outputPath) {
                              print("Final Size: " +
                                  File(outputPath!).lengthSync().toString());
                              onVideoPicked(outputPath);
                              Navigator.pop(context);
                            },
                          );
                        },
                  child: Text("DONE"),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimEditor(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: 30),
                    fit: BoxFit.contain,
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(
                        () {
                          _isPlaying = value;
                        },
                      );
                    },
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(
                      () {
                        _isPlaying = playbackState;
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
