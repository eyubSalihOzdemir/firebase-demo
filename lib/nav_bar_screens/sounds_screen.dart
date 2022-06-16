import 'package:firebase_demo/nav_bar_screens/helper/common.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'helper/firebase_functions.dart';

import 'package:just_audio/just_audio.dart';

class SoundsScreen extends StatefulWidget {
  SoundsScreen({Key? key}) : super(key: key);

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  // to be able to add different sources to different, an AudioSource list is used here
  // for further explanation, ctrl-f -> "audio_player_list_exp"
  List<AudioPlayer> _players = [];

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // stop all the players when app state is paused
    if (state == AppLifecycleState.paused) {
      for (var player in _players) {
        player.stop();
      }
    }
  }

  Stream<PositionData> _positionDataStream(var index) {
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _players[index].positionStream,
        _players[index].bufferedPositionStream,
        _players[index].durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
  }

  late Future<ListResult> _listResult;
  late Future<List> _downloadUrls;

  @override
  void initState() {
    super.initState();

    _listResult = getListResult('sounds');
    _downloadUrls = getSondUrlList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // using a variable that's initialised in initState before calling FutureBuilder to prevent unnecessary builds
        future: _listResult,
        builder: (context, AsyncSnapshot<ListResult?> snapshot) {
          var result = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02),
                  itemCount: result?.items.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      //future: getSoundUrl(index),
                      future: _downloadUrls,
                      builder: (context, AsyncSnapshot<List?> urlSnapshot) {
                        //_downloadUrls.then((value) => print("foo: $value"));
                        //print("testing: ${urlSnapshot.data?.elementAt(index)}");

                        if (urlSnapshot.hasData) {
                          // audio_player_list_exp: to be able to add different sources, audio players are initialised here
                          // after getting the song information. their url's from firebase are given using ListView.builder's
                          // "index" property and they are added to the list.
                          var fooPlayer = AudioPlayer();
                          fooPlayer.setAudioSource(AudioSource.uri(
                              Uri.parse(urlSnapshot.data!.elementAt(index))));
                          _players.add(fooPlayer);

                          return SoundsLoadedWidget(context, result, index);
                        } else {
                          return SoundsLoadingWidget();
                        }
                      },
                    );
                  }),
            );
          }
        },
      ),
    );
  }

  // card widget to be shown after getting sound information from firebase
  Container SoundsLoadedWidget(
      BuildContext context, ListResult? result, int index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(children: [
          Padding(padding: EdgeInsets.only(top: 5)),
          Text(result?.items.elementAt(index).name ?? "null"),
          Expanded(
            child: Row(
              children: [
                ButtonWidget(index),
                SoundSeekBar(index),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
        ]),
      ),
    );
  }

  // play/pause button widget for sounds
  StreamBuilder<PlayerState> ButtonWidget(int index) {
    return StreamBuilder<PlayerState>(
      stream: _players[index].playerStateStream,
      builder: (context, _snapshot) {
        final playerState = _snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return LoadingStateWidget();
        } else if (playing != true) {
          return PausedStateButton(index);
        } else if (processingState != ProcessingState.completed) {
          return PlayingStateButton(index);
        } else {
          return ReplayStateButton(index);
        }
      },
    );
  }

  // button widget to be shown for "paused" state
  Padding PausedStateButton(int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
          backgroundColor: Colors.teal.shade400,
          child: Icon(Icons.play_arrow_rounded),
          onPressed: () {
            int i = 0;

            // when a play button is clikced
            // stop all other players except the one that's playing
            for (var player in _players) {
              if (i != index) {
                player.stop();
              } else {
                player.play();
              }
              i++;
            }
          }),
    );
  }

  // utton widget to be shown for "playing" state
  Padding PlayingStateButton(int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
          child: Icon(Icons.pause), onPressed: _players[index].pause),
    );
  }

  // button widget to be shown for "replay" state
  Padding ReplayStateButton(int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
          child: Icon(Icons.replay_rounded),
          onPressed: () {
            _players[index].seek(Duration.zero);
          }),
    );
  }

  // seek bar widget to show the progress of the sound
  Expanded SoundSeekBar(int index) {
    return Expanded(
      child: StreamBuilder<PositionData>(
        stream: _positionDataStream(index),
        builder: (context, _snapshot) {
          final positionData = _snapshot.data;

          return SeekBar(
            duration: positionData?.duration ?? Duration.zero,
            position: positionData?.position ?? Duration.zero,
            bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
            onChangeEnd: _players[index].seek,
          );
        },
      ),
    );
  }
}

// widget to be shown instead of buttons when sounds are still loading
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: const CircularProgressIndicator(),
    );
  }
}

// widget to be shown when sounds are not ready yet
class SoundsLoadingWidget extends StatelessWidget {
  const SoundsLoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
