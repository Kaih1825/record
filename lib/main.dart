import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var shortcuts = FlutterShortcuts();
  var isRecording = false;
  StreamSubscription? listener;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shortcuts.initialize();
    shortcuts.listenAction((action) {
      print(action);
    });
    shortcuts.setShortcutItems(shortcutItems: [
      const ShortcutItem(id: "1", action: "action 1", shortLabel: "Action1", shortcutIconAsset: ShortcutIconAsset.flutterAsset, icon: "res/s1.jpeg"),
      const ShortcutItem(id: "2", action: "action 2", shortLabel: "Action2", shortcutIconAsset: ShortcutIconAsset.flutterAsset, icon: "res/s3.jpeg"),
      const ShortcutItem(id: "3", action: "action 3", shortLabel: "Action3", shortcutIconAsset: ShortcutIconAsset.flutterAsset, icon: "res/s8.jpeg"),
    ]);
  }

  void pcm() async {
    var out = File("/storage/emulated/0/Download/789.wav").openWrite();
    var fileIn = File("/storage/emulated/0/Download/789.pcm");
    writeId(out, 'RIFF');
    writeInt(out, 36 + fileIn.lengthSync()); //36+N
    writeId(out, 'WAVE');
    /* fmt chunk */
    writeId(out, 'fmt ');
    writeInt(out, 16);
    writeint(out, 1); //音訊格式(PCM)
    writeint(out, 2); //單聲道1 多聲道2
    writeInt(out, 44100); //取樣頻率
    writeInt(out, (1 * 44100 * 16 / 8).toInt()); //聲道數量*取樣頻率*位元深度/8
    writeint(out, 4);
    writeint(out, 16); //位元深度
    /* data chunk */
    writeId(out, 'data');
    writeInt(out, fileIn.lengthSync()); //N
    out.add(fileIn.readAsBytesSync()); //Data
    await out.close();
  }

  void writeId(EventSink<List<int>> out, String id) {
    out.add(id.codeUnits);
  }

  void writeInt(EventSink<List<int>> out, int val) {
    out.add([val >> 0, val >> 8, val >> 16, val >> 24]);
  }

  void writeint(EventSink<List<int>> out, int val) async {
    out.add([val >> 0, val >> 8]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Permission.microphone.request();
            if (await Permission.microphone.isGranted) {
              if (!isRecording) {
                var stream = await MicStream.microphone(
                    sampleRate: 44100, audioFormat: AudioFormat.ENCODING_PCM_16BIT, channelConfig: ChannelConfig.CHANNEL_IN_STEREO);
                var out = File("/storage/emulated/0/Download/789.pcm").openWrite();
                listener = stream!.listen((event) async {
                  out.add(event);
                  print(event);
                });
              } else {
                pcm();
                var player = AudioPlayer();
                player.play(DeviceFileSource("/storage/emulated/0/Download/789.wav"));
                listener!.cancel();
              }
              isRecording = !isRecording;
            }
            setState(() {});
          },
          backgroundColor: isRecording ? Colors.red : Colors.black,
        ),
        body: Center(
          child: Text(isRecording ? "Recording" : "Stop Recording123"),
        ),
      ),
    );
  }
}
