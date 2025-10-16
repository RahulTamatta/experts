import 'dart:developer';

import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:AstrowayCustomer/views/call/calling_screen.dart';

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

  // 🚀 WHATSAPP-LIKE: Direct call (no request, instant connection)
  Future<void> startDirectCall({
    required int astrologerId,
    required String astrologerName,
    required String callType, // 'audio' or 'video'
    String? astrologerProfile,
  }) async {
    try {
      final result = await apiHelper.startDirectCall(astrologerId, callType);
      
      if (result != null && result.status == "200") {
        // Call started successfully, navigate to call screen
        global.showToast(
          message: 'Connecting to $astrologerName...',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      } else {
        global.showToast(
          message: result?.message ?? 'Failed to start call',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      }
    } catch (e) {
      print('Exception in startDirectCall: ${e.toString()}');
      global.showToast(
        message: 'Failed to start call: $e',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  // 🚀 LEGACY: Old call request system (kept for compatibility)
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

  // 🚀 WHATSAPP-LIKE INSTANT CALL - Direct call with immediate Agora join
  Future<void> sendDirectCallRequest(int astrologerId, String astrologerName, String type, [String? astrologerProfile]) async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('🚀 [WHATSAPP CALL] Starting instant call');
      print('═══════════════════════════════════════════════════════════');
      print('🚀 [CALL] Astrologer ID: $astrologerId');
      print('🚀 [CALL] Astrologer Name: $astrologerName');
      print('🚀 [CALL] Call Type: $type');
      print('🚀 [CALL] Profile Image: ${astrologerProfile ?? "null"}');
      print('🚀 [CALL] API Endpoint: /callRequest/add');
      
      // Show connecting toast
      global.showToast(
        message: 'Calling $astrologerName...',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      
      print('📞 [API] Calling backend to create call request...');
      
      // Call backend API to initiate call and get Agora credentials
      final result = await apiHelper.sendAstrologerCallRequest(
        astrologerId, 
        true, // isFreeSession
        type, 
        '999999' // unlimited duration
      );
      
      print('📞 [API] Backend response received');
      print('📞 [API] Result is null: ${result == null}');
      print('📞 [API] Result status: ${result?.status}');
      
      if (result != null && result.status == "200") {
        final callData = result.recordList;
        
        print('✅ [SUCCESS] Got Agora credentials from backend!');
        print('✅ [SUCCESS] Call ID: ${callData['callId']}');
        print('✅ [SUCCESS] Channel Name: ${callData['channelName']}');
        print('✅ [SUCCESS] Token Length: ${callData['token']?.length ?? 0} chars');
        print('✅ [SUCCESS] Duration: ${callData['duration'] ?? '999999'}');
        print('✅ [SUCCESS] App ID: ${callData['appId'] ?? "not returned"}');
        
        // ✅ CRITICAL FIX: Close loader BEFORE navigation to prevent dialog conflict
        // The loader dialog must be dismissed before Get.to() is called
        global.hideLoader();
        
        // Small delay to ensure loader is fully dismissed
        await Future.delayed(Duration(milliseconds: 100));
        
        // Navigate to calling screen (shows "Calling..." while waiting for expert)
        print('📱 [NAVIGATION] Navigating to CallingScreen...');
        
        Get.to(() => CallingScreen(
          astrologerName: astrologerName,
          astrologerId: astrologerId,
          astrologerProfile: astrologerProfile ?? '',
          callId: callData['callId'],
          callType: type,
          channelName: callData['channelName'],
          token: callData['token'],
          duration: callData['duration'] ?? '999999',
        ));
        
        print('✅ [NAVIGATION] Successfully navigated to calling screen');
        print('✅ [CALL] Customer is now waiting for expert to accept...');
        print('═══════════════════════════════════════════════════════════');
        
      } else {
        print('❌ [ERROR] Failed to get valid response from backend');
        print('❌ [ERROR] Status: ${result?.status ?? "null"}');
        // Avoid accessing a non-existent message field on APIResult
        final fallbackMsg = (result?.status?.toString() == '500')
            ? 'Server error (500). Please try again.'
            : 'Failed to start call. Please try again.';
        global.showToast(
          message: fallbackMsg,
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
      }
      
    } catch (e, stackTrace) {
      print('❌ [EXCEPTION] Error in sendDirectCallRequest');
      print('❌ [EXCEPTION] Error: ${e.toString()}');
      print('❌ [EXCEPTION] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════════');
      global.showToast(
        message: 'Failed to connect to $astrologerName',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  // Removed unused direct call methods - now using WhatsApp-like flow with backend

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
