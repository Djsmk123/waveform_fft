// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_audio_capture/flutter_audio_capture.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterAudioCapture _plugin = FlutterAudioCapture();

  @override
  void initState() {
    super.initState();
    // Need to initialize before use note that this is async!
    _plugin.init();
  }

  Future<void> _startCapture() async {
    await _plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
  }

  Future<void> _stopCapture() async {
    await _plugin.stop();
  }

  void listener(dynamic obj) {
    print(obj);
  }

  void onError(Object e) {
    print(e);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Audio Capture Plugin'),
        ),
        body: Column(children: [
          Expanded(
              child: Row(
            children: [
              Expanded(child: Center(child: FloatingActionButton(onPressed: _startCapture, child: Text("Start")))),
              Expanded(child: Center(child: FloatingActionButton(onPressed: _stopCapture, child: Text("Stop")))),
            ],
          ))
        ]),
      ),
    );
  }
}
