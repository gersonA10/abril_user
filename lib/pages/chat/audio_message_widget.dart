import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class AudioMessageWidget extends StatefulWidget {
  const AudioMessageWidget({super.key, required this.url});

  final String url;

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  PlayerController player = PlayerController();
  PlayerState playerState = PlayerState.initialized;
  bool showWaves = false;

  @override
  void initState() {
    super.initState();
    downloadWave();
  }

  Future<void> downloadWave() async {
    Response response = await get(Uri.parse(widget.url));
    Uint8List bytes = response.bodyBytes;
    final appDirectory = await getApplicationCacheDirectory();
    File file = File('${appDirectory.path}/${widget.url.split('/').last}');

    if (response.statusCode == 200) {
      await file.writeAsBytes(bytes);
      player.preparePlayer(path: file.path).then((value) {
        if (mounted) {
          showWaves = true;
          setState(() {});
        }
      });
      player.onPlayerStateChanged.listen((state) {
        playerState = state;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              playerState.isPlaying ? Icons.pause : Icons.play_arrow,
              color: theme
            ),
            onPressed: () async {
              try {
                if (playerState.isPlaying) {
                  await player.pausePlayer();
                } else {
                  await player.startPlayer(
                    // finishMode: FinishMode.pause,
                    forceRefresh: true,
                  );
                }
              // ignore: empty_catches
              } catch (e) {
              }
            },
          ),
          Expanded(
            child: showWaves
                ? AudioFileWaveforms(
                      size: const Size(200, 50),
                      playerController: player,
                      enableSeekGesture: true,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        // backgroundColor: Colors.black,
                        fixedWaveColor: Colors.grey,
                        liveWaveColor: buttonColor,
                      ),
                    )
                : Image.asset(
                    'assets/images/audio_waves.png',
                    height: 32,
                  ),
          ),
        ],
      ),
    );
  }
}
