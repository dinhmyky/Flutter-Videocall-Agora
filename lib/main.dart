import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

const appId="a7e5a882723942fc9fe7e69490b66fc4";
const token="006a7e5a882723942fc9fe7e69490b66fc4IABY+wR2pW97PJ8IXHlZHDHTA9mfmICmrN+3Buxld1oWN7GeB4IAAAAAEAAwak95jpYYYQEAAQCOlhhh";

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int ?_remoteUid;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora()async{
    // retrieve permission
    await [Permission.microphone, Permission.camera].request();

    // create engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed){
          print ("Local user $uid joined");
        },
        userJoined: (int uid, int elapsed){
          print("Remote user $uid joined");
          setState((){
            _remoteUid=uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("Remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(token, "p", null, 0);
  }

  // Local view, remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video call for help"),
      ),
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: RtcLocalView.SurfaceView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Remote user's video
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid:_remoteUid!);
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}



