import 'dart:async';
import 'dart:io';

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
      const ShortcutItem(
          id: "1",
          action: "action 1",
          shortLabel: "Action1",
          shortcutIconAsset: ShortcutIconAsset.flutterAsset,
          icon: "res/s1.jpeg"),
      const ShortcutItem(
          id: "2",
          action: "action 2",
          shortLabel: "Action2",
          shortcutIconAsset: ShortcutIconAsset.flutterAsset,
          icon: "res/s3.jpeg"),
      const ShortcutItem(
          id: "3",
          action: "action 3",
          shortLabel: "Action3",
          shortcutIconAsset: ShortcutIconAsset.flutterAsset,
          icon: "res/s8.jpeg"),
    ]);
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
                var out =
                    File("/storage/emulated/0/Download/123.pcm").openWrite();
                var stream = await MicStream.microphone(
                    sampleRate: 44100,
                    audioFormat: AudioFormat.ENCODING_PCM_8BIT);
                listener = stream!.listen((event) {
                  // out.add(event);
                  print(event);
                });
              } else {
                listener!.cancel();
              }
              isRecording = !isRecording;
            }
            setState(() {});
          },
          backgroundColor: isRecording ? Colors.red : Colors.black,
        ),
        body: Center(
          child: Text(isRecording ? "Recording" : "Stop Recording"),
        ),
      ),
    );
  }
}
