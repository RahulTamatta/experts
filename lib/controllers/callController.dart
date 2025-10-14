import 'dart:developer';

import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/views/call/accept_call_screen.dart';

class CallController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;

  int currentIndex = 0;
  int totalSeconds = 0;
  bool showBottomAcceptCall = false;
  int? bottomAstrologerId;
  String bottomAstrologerName = "Astrologer";
  String? bottomAstrologerProfile;
  String? bottomToken;
  int? bottomCallId;
  String? bottomChannel;
  String? bottomFcmToken;
  bool callBottom = false;
  APIHelper apiHelper = APIHelper();
  bool isLeaveCall = false;
  String callType = "";
  int duration = 0;

  var resourceId;

  @override
  void onInit() async {
    tabController =
        TabController(length: 5, vsync: this, initialIndex: currentIndex);

    super.onInit();
  }

  showBottomAcceptCallRequest({
    required int astrologerId,
    required String channelName,
    required int callId,
    required String astroName,
    required String fcmToken,
    required String astroProfile,
    required String token,
    required String callType,
  }) async {
    print('in callcontroller showBottomAcceptCallRequest');
    showBottomAcceptCall = true;
    bottomAstrologerId = astrologerId;
    bottomAstrologerName = astroName;
    bottomAstrologerProfile = astroProfile;
    bottomToken = token;
    bottomCallId = callId;
    bottomFcmToken = fcmToken;
    bottomChannel = channelName;
    callType = callType;

    await global.sp!.setInt('callBottom', 1);
    await global.sp!.setInt('bottomCallAstrologerId', astrologerId);
    await global.sp!.setString('bottomCallAstrologerName', astroName);
    await global.sp!.setString('bottomCallAstrologerProfile', astroProfile);
    await global.sp!.setString('bottomCallToken', token);
    await global.sp!.setInt('bottomCallId', callId);
    await global.sp!.setString('bottomCallFcmToken', fcmToken);
    await global.sp!.setString('bottomCallChannel', channelName);
    await global.sp!.setString('bottomCallcallType', callType);
    update();
  }

  @override
  void onClose() {
    super.onClose();
  }

  setTabIndex(int index) {
    tabController!.index = index;
    currentIndex = index;
    print('ontapp tab index:- $currentIndex');
    update();
  }

  sendCallRequest(
      int astrologerId, bool isFreeSession, String type, String mins) async {
    try {
      await apiHelper
          .sendAstrologerCallRequest(astrologerId, isFreeSession, type, mins)
          .then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Sending call request..',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'Failed to send call request',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print('Exception in sendCallRequest : - ${e.toString()}');
    }
  }

  // 🚀 INSTANT DIRECT CALL - No request/accept flow, immediate call initiation
  Future<void> sendDirectCallRequest(int astrologerId, String astrologerName, String type) async {
    try {
      print('🚀 [INSTANT CALL] Starting instant $type call');
      print('🚀 [INSTANT CALL] Astrologer ID: $astrologerId');
      print('🚀 [INSTANT CALL] Astrologer Name: $astrologerName');
      print('🚀 [INSTANT CALL] Call Type: $type');
      print('🚀 [INSTANT CALL] User ID: ${global.currentUserId}');
      
      // Show loading indicator
      global.showToast(
        message: 'Connecting to $astrologerName...',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      
      // Generate unique call ID and channel name
      String callId = '${astrologerId}_${global.currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
      String channelName = 'call_$callId';
      
      // Directly initiate call without backend request/accept flow
      await _initiateDirectCall(astrologerId, astrologerName, type, callId, channelName);
      
      print('🚀 [INSTANT CALL] $type call initiated successfully');
      
    } catch (e) {
      print('❌ [INSTANT CALL] Exception: ${e.toString()}');
      global.showToast(
        message: 'Failed to connect to $astrologerName',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  // 🎯 Direct call initiation without request/accept flow
  Future<void> _initiateDirectCall(int astrologerId, String astrologerName, String type, String callId, String channelName) async {
    try {
      // Set up call parameters
      global.agoraChannelName = channelName;
      global.agoraToken = ""; // Will be generated by Agora or use temp token
      
      // Navigate directly to call screen
      if (type.toLowerCase() == 'call' || type.toLowerCase() == 'videocall') {
        // Use AcceptCallScreen for both audio and video calls
        Get.to(() => AcceptCallScreen(
          astrologerId: astrologerId,
          astrologerName: astrologerName,
          astrologerProfile: '',
          token: global.agoraToken,
          callChannel: channelName,
          callId: int.tryParse(callId.split('_').last) ?? 0,
          duration: '999999', // Unlimited duration for direct calls
          isfromnotification: false, // Direct call, not from notification
        ));
      }
      
      // Optional: Send notification to expert (non-blocking)
      _notifyExpertOfDirectCall(astrologerId, astrologerName, type, callId, channelName);
      
      print('🎯 [DIRECT CALL] Call screen opened for $type with $astrologerName');
      
    } catch (e) {
      print('❌ [DIRECT CALL] Failed to initiate call: $e');
      throw e;
    }
  }

  // 📱 Send notification to expert about incoming direct call (optional, non-blocking)
  Future<void> _notifyExpertOfDirectCall(int astrologerId, String astrologerName, String type, String callId, String channelName) async {
    try {
      // This is optional - just notify expert but don't wait for acceptance
      // Expert can join the call directly if available
      
      // Send FCM notification to expert (fire and forget)
      // This doesn't block the call - customer can start talking immediately
      print('📱 [NOTIFICATION] Sending direct call notification to expert $astrologerId');
      print('📱 [NOTIFICATION] Call details: $type call on channel $channelName');
      
      // TODO: Implement actual FCM notification sending here if needed
      // For now, just log the notification attempt
      
    } catch (e) {
      print('⚠️ [NOTIFICATION] Failed to notify expert: $e (call continues anyway)');
    }
  }

  acceptedCall(int callId) async {
    try {
      await apiHelper.acceptCall(callId).then((result) {
        if (result.status == "200") {
        } else {
          global.showToast(
            message: 'Call Accepet fail',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print("Exception acceptedCall:-" + e.toString());
    }
  }

  rejectedCall(int callId) async {
    try {
      await apiHelper.rejectCall(callId).then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Call Rejected',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'Call Reject fail',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      print("Exception rejectedCall:-" + e.toString());
    }
  }

  Future endCall(int callId, int seconds, String sId, String sId1) async {
    try {
      await apiHelper.endCall(callId, seconds, sId, sId1).then((result) {
        if (result.status == "200") {
          global.showToast(
            message: 'Call Ended',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
          return 1;
        } else {
          global.showToast(
            message: 'Call Ended fail',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
          return 0;
        }
      });
    } catch (e) {
      print("Exception endCall:-" + e.toString());
    }
  }

  getAgoraResourceId(String cname, int uid) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getResourceId(cname, uid).then((result) {
            resourceId = result.recordList;
            log('resourceId response 1:- $result');
            log('resourceId 1 ${resourceId["resourceId"]}');
            global.agoraResourceId = resourceId["resourceId"];
            log('global agoraResourceId  1${global.agoraResourceId}');
          });
        }
      });
    } catch (e) {
      print("Exception getAgoraResourceId 1:-" + e.toString());
    }
  }

  // getAgoraResourceId2(String cname, int uid) async {
  //   try {
  //     await global.checkBody().then((result) async {
  //       if (result) {
  //         await apiHelper.getResourceId(cname, uid).then((result) {
  //           resourceId = result.recordList;
  //           log('resourceId response 2:- $result');
  //           log('resourceId 2 ${resourceId["resourceId"]}');
  //           global.agoraResourceId2 = resourceId["resourceId"];
  //           log('global agoraResourceId  2${global.agoraResourceId}');
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     print("Exception getAgoraResourceId 2:-" + e.toString());
  //   }
  // }

  agoraStartRecording(String cname, int uid, String token) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .agoraStartCloudRecording(cname, uid, token)
              .then((result) {
            log('start recording response:- ${result.recordList}');
            global.agoraSid1 = result.recordList["sid"];
            log('global agoraSId ${global.agoraSid1}');

            global.showToast(
              message: 'Start recording success',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          });
        }
      });
    } catch (e) {
      print("Exception getAgoraResourceId:-" + e.toString());
    }
  }

  agoraStopRecording(int callId, String cname, int uid) async {
    print('controller stop1');
    try {
      await apiHelper.agoraStopCloudRecording(cname, uid).then((result) async {
        log('stop recording response:- ${result.recordList}');
      });
    } catch (e) {
      print("Exception agoraStopRecording:-" + e.toString());
    }
  }

  agoraStopRecording2(int callId, String cname, int uid) async {
    print('controller stop2');
    try {} catch (e) {
      print("Exception agoraStopRecording2:-" + e.toString());
    }
  }

  stopRecordingStoreData(int callId, String channelName) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .stopRecoedingStoreData(callId, channelName, global.agoraSid1)
              .then((result) {
            if (result.status == "200") {
              global.showToast(
                message: 'store sid successfully',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            } else {
              global.showToast(
                message: 'Failed store sid',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception stopRecordingStoreData:-" + e.toString());
    }
  }
}
