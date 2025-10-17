// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/chat/endDialog.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/bottomNavigationController.dart';

class AcceptCallScreen extends StatefulWidget {
  final String? astrologerName;
  final int? astrologerId;
  final String? astrologerProfile;
  final String? token;
  final String? callChannel;
  final int? callId;
  bool isfromnotification;
  String? duration;
  final String? appId; // App ID from backend (must match token)
  AcceptCallScreen({
    super.key,
    this.astrologerName,
    this.callId,
    this.astrologerId,
    this.astrologerProfile,
    this.token,
    this.callChannel,
    this.duration,
    this.isfromnotification = false,
    this.appId,
  });

  @override
  State<AcceptCallScreen> createState() => _AcceptCallScreenState();
}

class _AcceptCallScreenState extends State<AcceptCallScreen> {
  final _callController = Get.find<CallController>();
  final bottomNavicontroller = Get.find<BottomNavigationController>();
  int uid = 0;
  int? remoteID;
  late RtcEngine agoraEngine;
  bool isJoined = false;
  bool isCalling = true;
  Timer? timer;
  Timer? timer2;
  Timer? secTimer;
  bool isMuted = false;
  bool isSpeaker = false;
  int callVolume = 50;
  int? min;
  int? sec;
  int totalSecond = 0;
  bool isHostJoin = false;
  int? localUserId;
  int? endTime;

  bool isStart = false;
  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    log('widget.isfromnotification  -> ${widget.isfromnotification}');
    if (widget.isfromnotification == false) {
      print("akjsbdkjsnad");
      print("${DateTime.now().millisecondsSinceEpoch + 1000 * 300}");
      setupVoiceSDKEngine();
    } else {
      log('you are coming from notificaiotn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        global.showToast(
          message: tr('Please leave the call by pressing leave button'),
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
        return false;
      },
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              color: Get.theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.astrologerName ?? 'User',
                          style: Get.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        SizedBox(
                          child: status(),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: Get.height * 0.1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Get.theme.primaryColor),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    child: widget.astrologerProfile == null || widget.astrologerProfile == ""
                        ? Image.asset(
                            Images.deafultUser,
                            fit: BoxFit.contain,
                            height: 60,
                            width: 40,
                          )
                        : CachedNetworkImage(
                            imageUrl: '${global.imgBaseurl}${widget.astrologerProfile}',
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              child: Image.network(
                                '${global.imgBaseurl}${widget.astrologerProfile}',
                                fit: BoxFit.contain,
                                height: 60,
                              ),
                            ),
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset(
                              Images.deafultUser,
                              fit: BoxFit.contain,
                              height: 60,
                              width: 40,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
        bottomSheet: Container(
          height: Get.height * 0.1,
          padding: EdgeInsets.all(10),
          color: Get.theme.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isSpeaker = !isSpeaker;
                  });
                  onVolume(isSpeaker);
                },
                child: Icon(
                  isSpeaker ? Icons.volume_up : Icons.volume_off,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () async {
                  print("jaksndkjnsa");
                  print("${_callController.totalSeconds}");
                  if (_callController.totalSeconds < 60 && endTime != null) {
                    Get.dialog(
                      EndDialog(),
                    );
                  } else {
                    print('leave call from cut');
                    global.showOnlyLoaderDialog(Get.context);
                    await leave();
                    global.hideLoader();
                    log('leave call from cut');
                    Get.back();
                    Get.back();
                    BottomNavigationController bottomNavigationController =
                        Get.find<BottomNavigationController>();
                    bottomNavigationController.setIndex(0, 0);
                    Get.to(() => BottomNavigationBarScreen(
                          index: 0,
                        ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isMuted = !isMuted;
                    log('mute $isMuted');
                  });
                  onMute(isMuted);
                },
                child: Icon(
                  isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setupVoiceSDKEngine() async {
    print('🎤 [CUSTOMER SETUP] Requesting microphone permission...');
    // retrieve or request microphone permission
    await [Permission.microphone].request();
    //create an instance of the Agora engine
    try {
      print('🎤 [CUSTOMER SETUP] Creating Agora engine...');
      agoraEngine = createAgoraRtcEngine();
      
      // ✅ FIX: Use appId from backend (widget) if available, otherwise fallback to system flag
      final String effectiveAppId = (widget.appId != null && widget.appId!.isNotEmpty)
          ? widget.appId!
          : global.getSystemFlagValue(global.systemFlagNameList.agoraAppId);
      
      await agoraEngine.initialize(RtcEngineContext(appId: effectiveAppId));
      print('✅ [CUSTOMER SETUP] Agora engine initialized');
      print('✅ [CUSTOMER SETUP] Using App ID: ${effectiveAppId.substring(0, effectiveAppId.length > 6 ? 6 : effectiveAppId.length)}********');
      
      // Explicitly configure audio for voice communication
      await agoraEngine.enableAudio();
      await agoraEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard,
      );
    } catch (e) {
      print('❌ [CUSTOMER SETUP] Exception in setupVoiceSDKEngine: ${e.toString()}');
    }

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          print('✅ [CUSTOMER JOIN SUCCESS] Customer joined channel!');
          print('✅ [CUSTOMER JOIN SUCCESS] Local UID: ${connection.localUid}');
          print('✅ [CUSTOMER JOIN SUCCESS] Channel: ${connection.channelId}');
          print('✅ [CUSTOMER JOIN SUCCESS] Elapsed: ${elapsed}ms');
          print('✅ [CUSTOMER JOIN SUCCESS] Now waiting for expert to join...');
          setState(() {
            isJoined = true;
            localUserId = connection.localUid;
            global.localUid = localUserId;
          });
          await callController.getAgoraResourceId(
              widget.callChannel!, global.localUid!);
          // Route audio after join to avoid ERR_NOT_READY
          try {
            await Future.delayed(const Duration(milliseconds: 200));
            onVolume(isSpeaker);
            onMute(isMuted);
          } catch (e) {
            print('⚠️ set speaker/mute post-join failed: $e');
          }
        },
        onUserJoined:
            (RtcConnection connection, int remoteUId, int elapsed) async {
          print('✅ [EXPERT JOINED] Expert joined the call!');
          print('✅ [EXPERT JOINED] Expert UID: $remoteUId');
          print('✅ [EXPERT JOINED] Expected expert ID: ${widget.astrologerId}');
          print('✅ [EXPERT JOINED] Starting call timer now...');
          setState(() {
            isHostJoin = true;
            remoteID = remoteUId;
            endTime = DateTime.now().millisecondsSinceEpoch +
                1000 * int.parse(widget.duration.toString());

            _callController.totalSeconds = 0;
            _callController.update();
            timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
              _callController.totalSeconds = _callController.totalSeconds + 1;

              _callController.update();
            });
          });
          // await callController.getAgoraResourceId2(
          //     widget.callChannel!, remoteID!);
          await startRecord();

          callController.isLeaveCall = false;
          callController.update();
          print('✅ [AUDIO] Unmuting all remote audio streams...');
          // Ensure we are receiving remote audio
          try {
            await agoraEngine.muteAllRemoteAudioStreams(false);
            print('✅ [AUDIO] Remote audio streams unmuted successfully');
          } catch (e) {
            print('⚠️ [AUDIO] muteAllRemoteAudioStreams(false) failed: $e');
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUId,
            UserOfflineReasonType reason) async {
          print('leave call from userOffline');
          await leave();
          log('leave call from cut');
          Get.back();
          Get.back();
          BottomNavigationController bottomNavigationController =
              Get.find<BottomNavigationController>();
          bottomNavigationController.setIndex(0, 0);
          Get.to(() => BottomNavigationBarScreen(
                index: 0,
              ));
        },
        onRtcStats: (connection, stats) {},
        onLocalAudioStateChanged: (connection, state, reason) {
          print('🎙️ [AUDIO] Local audio state: $state, reason: $reason');
        },
        onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
          print('👂 [AUDIO] Remote($remoteUid) audio state: $state, reason: $reason');
        },
        onError: (err, msg) {
          print('❌ [AGORA ERROR] code: $err, message: $msg');
        },
      ),
    );
    // Join last to ensure engine fully initialized
    join();
  }

  Widget status() {
    return endTime == null
        ? Text("Joining.. ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16.sp,
            ))
        : CountdownTimer(
            endTime: endTime,
            widgetBuilder: (_, CurrentRemainingTime? time) {
              if (time == null) {
                return Text(
                  '00:00:00',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: time.hours != null && time.hours != 0
                    ? Text(
                        '${time.hours ?? '00'} :${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      )
                    : time.min != null
                        ? Text(
                            '${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'} :${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          )
                        : Text(
                            '${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
              );
            },
            onEnd: () async {
              log('in onEnd ${callController.isLeaveCall}');
              if (callController.isLeaveCall == false) {
                global.showOnlyLoaderDialog(Get.context);
                await leave();
                global.hideLoader();
                Get.back();
                Get.back();
                bottomNavicontroller.setIndex(1, 0);
                Get.to(() => BottomNavigationBarScreen(index: 0));
              }
            },
          );
  }

  void join() async {
    // ✅ FIX: Use actual customer user ID, not 0
    if (global.currentUserId == null) {
      await global.getCurrentUser();
    }
    uid = global.currentUserId ?? 0;
    
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    print('in join method of customer call');
    print('token:- ${widget.token!}');
    print('channelId:- ${widget.callChannel!}');
    print('uid:- ${uid}');
    await agoraEngine.joinChannel(
      token: widget.token!,
      channelId: widget.callChannel!,
      options: options,
      uid: uid,
    );
  }

  Future startRecord() async {
    await callController.agoraStartRecording(
        widget.callChannel!, global.localUid!, widget.token!);
    // await callController.agoraStartRecording2(
    //     widget.callChannel!, remoteID!, widget.token!);
  }

  Future stopRecord() async {
    await callController.agoraStopRecording(
        widget.callId!, widget.callChannel!, global.localUid!);
    await callController.agoraStopRecording2(
        widget.callId!, widget.callChannel!, remoteID!);
  }

  void onMute(bool mute) {
    try {
      agoraEngine.muteLocalAudioStream(mute);
      print('🎛️ [AUDIO] Local mute set to: $mute');
    } catch (e) {
      print('❌ [AUDIO] muteLocalAudioStream error: $e');
    }
  }

  void onVolume(bool isSpeaker) {
    try {
      agoraEngine.setEnableSpeakerphone(isSpeaker);
      print('🔈 [AUDIO] Speakerphone: $isSpeaker');
    } catch (e) {
      print('❌ [AUDIO] setEnableSpeakerphone error: $e');
    }
  }

  Future<void> leave() async {
    callController.showBottomAcceptCall = false;
    callController.callBottom = false;
    callController.isLeaveCall = true;
    global.sp!.remove('callBottom');
    global.sp!.setInt('callBottom', 0);
    callController.callBottom = false;
    callController.update();
    await stopRecord();
    global.showOnlyLoaderDialog(Get.context);
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    if (timer2 != null) {
      timer2?.cancel();
      timer2 = null;
    }
    await callController.endCall(widget.callId!, _callController.totalSeconds,
        global.agoraSid1, global.agoraSid2);
    await global.splashController.getCurrentUserData();
    global.hideLoader();
    if (mounted) {
      setState(() {
        isJoined = false;
        remoteID = null;
        global.localUid = null;
      });
    }
    debugPrint('end all call fluttercallkit');
    await FlutterCallkitIncoming.endAllCalls();

    agoraEngine.leaveChannel();
    agoraEngine.release(sync: true);
    global.localUid = null;

    Get.back();
  }

  @override
  void dispose() {
    print('🔴 [DISPOSE] Cleaning up customer call resources');
    
    // ✅ FIX: Properly cleanup Agora to prevent ERR_JOIN_CHANNEL_REJECTED (-17)
    try {
      agoraEngine.leaveChannel();
      agoraEngine.release(sync: true);
      print('✅ [DISPOSE] Agora cleaned up successfully');
    } catch (e) {
      print('⚠️ [DISPOSE] Agora cleanup error: $e');
    }
    
    if (timer != null) {
      timer!.cancel();
      print('stop timer in despose');
      global.localUid = null;
    }
    if (secTimer != null) {
      secTimer!.cancel();
    }
    super.dispose();
  }
}
