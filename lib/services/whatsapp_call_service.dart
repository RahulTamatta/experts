// ignore_for_file: avoid_print

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/views/call/whatsapp_call_screen.dart';

/**
 * 🚀 WHATSAPP-LIKE: Direct Call Service
 * No validation, no requests, instant connection
 */
class WhatsAppCallService extends GetxController {
  static final WhatsAppCallService _instance = WhatsAppCallService._internal();
  factory WhatsAppCallService() => _instance;
  WhatsAppCallService._internal();

  final APIHelper apiHelper = APIHelper();
  RtcEngine? _agoraEngine;
  
  // Call state
  var isInCall = false.obs;
  var isCallConnected = false.obs;
  var callDuration = 0.obs;
  var isMuted = false.obs;
  var isSpeakerOn = true.obs;
  var isVideoEnabled = true.obs;
  
  // Call details
  String? currentChannelName;
  String? currentToken;
  String? currentAppId;
  int? remoteUid;
  
  /**
   * 🚀 Start WhatsApp-like direct call (Audio/Video)
   */
  Future<void> startDirectCall({
    required int astrologerId,
    required String astrologerName,
    required String callType, // 'audio' or 'video'
    String? astrologerProfile,
  }) async {
    try {
      print('🚀 [WHATSAPP CALL] Starting direct call to astrologer $astrologerId');
      
      if (isInCall.value) {
        global.showToast(
          message: 'Already in a call',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
        return;
      }

      // Show connecting dialog
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Calling $astrologerName...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Call backend to start direct call
      final response = await apiHelper.startDirectCall(astrologerId, callType);

      Get.back(); // Close connecting dialog

      if (response != null && response['status'] == 200) {
        // Extract call details
        currentChannelName = response['channelName'];
        currentToken = response['token'];
        currentAppId = response['appId'];
        
        print('🚀 [WHATSAPP CALL] Call setup successful');
        print('🚀 [WHATSAPP CALL] Channel: $currentChannelName');
        print('🚀 [WHATSAPP CALL] Token: ${currentToken?.substring(0, 20)}...');

        // Initialize Agora and join call
        await _initializeAgora();
        await _joinCall();

        // Navigate to call screen
        Get.to(() => WhatsAppCallScreen(
          channelName: currentChannelName!,
          token: currentToken!,
          appId: currentAppId!,
          astrologerName: astrologerName,
          astrologerProfile: astrologerProfile,
          callType: callType,
          isInitiator: true,
        ));

        isInCall.value = true;
        
      } else {
        global.showToast(
          message: response?['message'] ?? 'Failed to start call',
          textColor: Colors.white,
          bgColor: Colors.red,
        );
      }

    } catch (e) {
      Get.back(); // Close any open dialogs
      print('❌ [WHATSAPP CALL] Error starting call: $e');
      global.showToast(
        message: 'Failed to start call: $e',
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }

  /**
   * 🚀 Answer incoming WhatsApp-like call
   */
  Future<void> answerCall({
    required String channelName,
    required String token,
    required String appId,
    required String customerName,
    required String callType,
    String? customerProfile,
  }) async {
    try {
      print('🚀 [WHATSAPP CALL] Answering incoming call');
      
      currentChannelName = channelName;
      currentToken = token;
      currentAppId = appId;

      // Initialize Agora and join call
      await _initializeAgora();
      await _joinCall();

      // Navigate to call screen
      Get.to(() => WhatsAppCallScreen(
        channelName: channelName,
        token: token,
        appId: appId,
        astrologerName: customerName,
        astrologerProfile: customerProfile,
        callType: callType,
        isInitiator: false,
      ));

      isInCall.value = true;
      isCallConnected.value = true;

    } catch (e) {
      print('❌ [WHATSAPP CALL] Error answering call: $e');
      global.showToast(
        message: 'Failed to answer call: $e',
        textColor: Colors.white,
        bgColor: Colors.red,
      );
    }
  }

  /**
   * 🚀 End current call
   */
  Future<void> endCall() async {
    try {
      print('🚀 [WHATSAPP CALL] Ending call');

      // Leave Agora channel
      await _agoraEngine?.leaveChannel();
      await _agoraEngine?.release();
      _agoraEngine = null;

      // Reset state
      isInCall.value = false;
      isCallConnected.value = false;
      callDuration.value = 0;
      currentChannelName = null;
      currentToken = null;
      currentAppId = null;
      remoteUid = null;

      // Navigate back
      Get.back();

    } catch (e) {
      print('❌ [WHATSAPP CALL] Error ending call: $e');
    }
  }

  /**
   * 🚀 Initialize Agora RTC Engine
   */
  Future<void> _initializeAgora() async {
    try {
      if (_agoraEngine != null) {
        await _agoraEngine!.release();
      }

      // Create Agora engine
      _agoraEngine = createAgoraRtcEngine();
      
      await _agoraEngine!.initialize(RtcEngineContext(
        appId: currentAppId!,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Set up event handlers
      _agoraEngine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('🚀 [AGORA] Joined channel: ${connection.channelId}');
          isCallConnected.value = true;
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print('🚀 [AGORA] Remote user joined: $uid');
          remoteUid = uid;
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          print('🚀 [AGORA] Remote user left: $uid');
          if (uid == remoteUid) {
            remoteUid = null;
            // Other user ended call
            endCall();
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('🚀 [AGORA] Left channel');
          isCallConnected.value = false;
        },
      ));

      // Enable audio/video
      await _agoraEngine!.enableAudio();
      await _agoraEngine!.enableVideo();
      
      print('🚀 [AGORA] Engine initialized successfully');

    } catch (e) {
      print('❌ [AGORA] Failed to initialize engine: $e');
      throw e;
    }
  }

  /**
   * 🚀 Join Agora channel
   */
  Future<void> _joinCall() async {
    try {
      await _agoraEngine!.joinChannel(
        token: currentToken!,
        channelId: currentChannelName!,
        uid: global.currentUserId ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      
      print('🚀 [AGORA] Joining channel: $currentChannelName');

    } catch (e) {
      print('❌ [AGORA] Failed to join channel: $e');
      throw e;
    }
  }

  /**
   * 🚀 Toggle mute
   */
  Future<void> toggleMute() async {
    try {
      isMuted.value = !isMuted.value;
      await _agoraEngine?.muteLocalAudioStream(isMuted.value);
      print('🚀 [AGORA] Mute toggled: ${isMuted.value}');
    } catch (e) {
      print('❌ [AGORA] Failed to toggle mute: $e');
    }
  }

  /**
   * 🚀 Toggle speaker
   */
  Future<void> toggleSpeaker() async {
    try {
      isSpeakerOn.value = !isSpeakerOn.value;
      await _agoraEngine?.setEnableSpeakerphone(isSpeakerOn.value);
      print('🚀 [AGORA] Speaker toggled: ${isSpeakerOn.value}');
    } catch (e) {
      print('❌ [AGORA] Failed to toggle speaker: $e');
    }
  }

  /**
   * 🚀 Toggle video (for video calls)
   */
  Future<void> toggleVideo() async {
    try {
      isVideoEnabled.value = !isVideoEnabled.value;
      await _agoraEngine?.muteLocalVideoStream(!isVideoEnabled.value);
      print('🚀 [AGORA] Video toggled: ${isVideoEnabled.value}');
    } catch (e) {
      print('❌ [AGORA] Failed to toggle video: $e');
    }
  }

  /**
   * 🚀 Switch camera (front/back)
   */
  Future<void> switchCamera() async {
    try {
      await _agoraEngine?.switchCamera();
      print('🚀 [AGORA] Camera switched');
    } catch (e) {
      print('❌ [AGORA] Failed to switch camera: $e');
    }
  }

  /**
   * Get Agora engine for rendering video
   */
  RtcEngine? get agoraEngine => _agoraEngine;
}
