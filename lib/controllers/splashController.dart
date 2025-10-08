import 'dart:async';
import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/model/current_user_model.dart';
import 'package:AstrowayCustomer/model/systemFlagModel.dart';
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/astrologerProfile/astrologerProfile.dart';
import '../views/bottomNavigationBarScreen.dart';
import '../views/call/accept_call_screen.dart';
import '../views/call/incoming_call_request.dart';
import '../views/call/oneToOneVideo/onetooneVideo.dart';
import '../views/chat/incoming_chat_request.dart';

class SplashController extends GetxController {
  APIHelper apiHelper = APIHelper();
  CurrentUserModel? currentUser;
  CurrentUserModel? currentUserPayment;
  String? appShareLinkForLiveSreaming;
  String? version;
  double? totalGst;
  var syatemFlag = <SystemFlag>[];
  String appName = "";
  String currentLanguageCode = 'en';
  @override
  void onInit() {
    _inIt();
    super.onInit();
  }

  _inIt() async {
     await getSystemFlag();
    // FutureBuilder(
    //   future: splashController.getSystemFlag(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     } else if (snapshot.connectionState == ConnectionState.done) {
    //       if (snapshot.hasError) {
    //         debugPrint('getSystemFlag error ${snapshot.error}');
    //       }
    //       debugPrint('getSystemFlag');
    //       return const SizedBox();
    //     } else {
    //       return const SizedBox();
    //     }
    //   },
    // );
    appName =
        global.getSystemFlagValueForLogin(global.systemFlagNameList.appName);
    global.sp = await SharedPreferences.getInstance();
    currentLanguageCode = global.sp!.getString('currentLanguage') ?? 'en';
    global.sp!.setString('currentLanguage', currentLanguageCode);
    print("currentLanguageinSplash");
    print("${global.sp!.getString('currentLanguage')}");
    update();
    Timer(const Duration(seconds: 5), () async {
      try {
        bool isLogin = await global.isLogin();
        final bottomNavigationController =
            Get.find<BottomNavigationController>();
        final homeController = Get.find<HomeController>();

        print("isLoginsplashscreen ${isLogin}");
        if (isLogin) {
          PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
            version = packageInfo.version;
            update();
          });
          await global.checkBody().then((result) async {
            if (result) {
              await apiHelper.validateSession().then((result) async {
                if (result.status == "200") {
                  currentUser = result.recordList;
                  global.saveUser(currentUser!);
                  global.user = currentUser!;
                  global.showOnlyLoaderDialog(Get.context);
                  await splashController.getCurrentUserData();
                  global.hideLoader();

                  await global.getCurrentUser();
                  _loadsaveChatData();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadSavedData();
                  });
                  if (global.generalPayload != null) {
                    Map<String, dynamic> convetedPayLoad =
                        json.decode(global.generalPayload);
                    Map<String, dynamic> body =
                        jsonDecode(convetedPayLoad['body']);
                    if (body["notificationType"] == 1) {
                      body['call_type'].toString() == "11"
                          ? Get.to(() => OneToOneLiveScreen(
                                channelname: body["channelName"],
                                callId: body["callId"],
                                fcmToken: body["token"],
                                end_time: body['call_duration'].toString(),
                              ))
                          : Get.to(() => IncomingCallRequest(
                                astrologerId: body["astrologerId"],
                                astrologerName: body["astrologerName"] == null
                                    ? "Astrologer"
                                    : body["astrologerName"],
                                astrologerProfile: body["profile"] == null
                                    ? ""
                                    : body["profile"],
                                token: body["token"],
                                channel: body["channelName"],
                                callId: int.parse(body["callId"].toString()),
                                fcmToken: body["fcmToken"] ?? "",
                                duration: body['call_duration'].toString(),
                              ));
                    } else if (body["notificationType"] == 3) {
                      Get.to(() => IncomingChatRequest(
                          astrologerName: body["astrologerName"] == null
                              ? "Astrologer"
                              : body["astrologerName"],
                          profile:
                              body["profile"] == null ? "" : body["profile"],
                          fireBasechatId: body["firebaseChatId"],
                          chatId: int.parse(body["chatId"].toString()),
                          astrologerId: body["astrologerId"],
                          fcmToken: body["fcmToken"],
                          duration: body['chat_duration'].toString()));
                    } else if (body["notificationType"] == 4) {
                      print('live astrologer');
                      Get.find<ReviewController>()
                          .getReviewData(body["astrologerId"]);
                      await Get.find<BottomNavigationController>()
                          .getAstrologerbyId(body["astrologerId"]);
                      Get.to(() => AstrologerProfile(index: 0));
                    } else {
                      print('other notification');
                      bottomNavigationController.setIndex(1, 0);
                      Get.off(() => BottomNavigationBarScreen(index: 1));
                    }
                  } else {
                    bottomNavigationController.setIndex(0, 0);
                    Get.off(() => BottomNavigationBarScreen(index: 0));
                  }
                } else {
                  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                    version = packageInfo.version;
                    update();
                  });
                  sp = await SharedPreferences.getInstance();
                  sp!.remove("currentUser");
                  sp!.remove("currentUserId");
                  sp!.remove("token");
                  sp!.remove("tokenType");
                  user = CurrentUserModel();
                  sp!.clear();

                  homeController.myOrders.clear();
                  Get.off(() => LoginScreen());
                }
              });
            }
          });
        } else {
          PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
            version = packageInfo.version;
            update();
          });
          Get.off(() => LoginScreen());
        }
      } catch (e) {
        print('Exception in _inIt():' + e.toString());
      }
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    bool? isacceptedcall = await prefs.getBool('is_accepted');
    print('is accepted or not $isacceptedcall');
    if (isacceptedcall == true) {
      // Handle call end action
      String? dataaccepted = await prefs.getString('is_accepted_data');
      if (dataaccepted!.isNotEmpty) {
        await prefs.setBool('is_accepted', false);
        print('is accepted dataaccepted $dataaccepted}');
        callAccept(jsonDecode(dataaccepted));
        await prefs.setString('is_accepted_data', '');
      }
    }

    bool? isrejectedcall = await prefs.getBool('is_rejected');
    if (isrejectedcall == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> chatData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatdata', '');

    if (chatData.containsKey('body')) {
      Map<String, dynamic> body = jsonDecode(chatData['body']);
      if (body["notificationType"] == 3) {
        Get.to(() => IncomingChatRequest(
              astrologerName: body["astrologerName"] ?? "Astrologer",
              profile: body["profile"] ?? "",
              fireBasechatId: body["firebaseChatId"],
              chatId: int.parse(body["chatId"].toString()),
              astrologerId: body["astrologerId"],
              fcmToken: body["fcmToken"],
              duration: body['chat_duration'].toString(),
            ));
      } else {
        print('Notification type is not 3');
      }
    } else {
      print('No body field found in chat data.');
    }
  }

  void _loadsaveChatData() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isChatDataAvailable = await prefs.getBool('is_chatdataAvailable');
    print('isChatDataAvailable: $isChatDataAvailable');
    if (isChatDataAvailable == true) {
      await prefs.setBool('is_chatdataAvailable', false);
      String? chatDataJson = await prefs.getString('chatdata');
      if (chatDataJson != null) {
        Map<String, dynamic> chatData = jsonDecode(chatDataJson);
        print('Loaded chat data: $chatData');
        _handleNotificationNavigation(chatData);
      } else {
        print('No chat data found in SharedPreferences.');
      }
    } else {
      print('No chat data available.');
    }
  }

  Future<void> createAstrologerShareLink() async {
    try {
      await Share.share(
        'Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career. I would recommend you to connect with best Astrologer at ${global.getSystemFlagValue(global.systemFlagNameList.appName)}.',
        subject:
            'Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career. I would recommend you to connect with best Astrologer at ${global.getSystemFlagValue(global.systemFlagNameList.appName)}. $appShareLinkForLiveSreaming',
      );
    } catch (e) {
      print("Exception - global.dart - referAndEarn():" + e.toString());
    }
  }

  getCurrentUserData() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.sp = await SharedPreferences.getInstance();
          await apiHelper.getCurrentUser().then((result) {
            if (result.status == "200") {
              currentUser = result.recordList;
              global.saveUser(currentUser!);
              global.user = currentUser!;
              print('current user profile from splash ${global.user.profile}');
              update();
            } else {}
          });
        }
      });
    } catch (e) {
      print('Exception in getCurrentUserData():' + e.toString());
    }
  }

  getSystemFlag() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.sp = await SharedPreferences.getInstance();
          await apiHelper.getSystemFlag().then((result) {
            if (result != null && result.status == "200") {
              syatemFlag = result.recordList ?? <SystemFlag>[];
              update();
            } else {
              print('Failed to load system flags, using empty list');
              syatemFlag = <SystemFlag>[];
              update();
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getSystemFlag():' + e.toString());
      syatemFlag = <SystemFlag>[];
      update();
    }
  }
}

@pragma('vm:entry-point')
void callAccept(Map<String, dynamic> extraData) async {
  print('extra call astrologerId ${extraData['astrologerId']}');

  final callController = Get.find<CallController>();
  if (extraData['call_type'] == 10) {
    await callController.acceptedCall(extraData["callId"]);
    Get.to(
      () => AcceptCallScreen(
        astrologerId: extraData["astrologerId"],
        astrologerName: extraData["astrologerName"] == null
            ? "Astrologer"
            : extraData["astrologerName"],
        astrologerProfile:
            extraData["profile"] == null ? "" : extraData["profile"],
        token: extraData["token"],
        callChannel: extraData["channelName"],
        callId: extraData["callId"],
        duration: extraData['call_duration'].toString(),
      ),
    );
  } else if (extraData['call_type'] == 11) {
    Get.to(() => OneToOneLiveScreen(
          channelname: extraData["channelName"],
          callId: extraData["callId"],
          fcmToken: extraData["token"].toString(),
          end_time: extraData['call_duration'].toString(),
        ));
  }
}
