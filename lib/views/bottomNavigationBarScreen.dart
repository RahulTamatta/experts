// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/liveController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/splashController.dart';
import '../utils/AppColors.dart';
import '../utils/global.dart' as global;

class BottomNavigationBarScreen extends StatelessWidget {
  final int index;

  BottomNavigationBarScreen({this.index = 0}) : super();

  int? currentIndex;
  List<IconData> iconList = [
    Icons.home,
    Icons.chat,
    Icons.live_tv,
    Icons.call,
    Icons.edit_calendar_sharp,
  ];
  List<String> tabList = [
    'Home',
    'Chat',
    'Live',
    'Call',
    'History',
  ];
  final homeController = Get.find<HomeController>();
  final historyController = Get.find<HistoryController>();
  final liveController = Get.find<LiveController>();
  final chatController = Get.find<ChatController>();
  final splashController = Get.find<SplashController>();
  final bottomNavigationController = Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GetBuilder<BottomNavigationController>(builder: (controller) {
        return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: GetBuilder<BottomNavigationController>(
              builder: (c) {
                return SizedBox(
                  height: 10.h,
                  child: BottomNavigationBar(
                    backgroundColor: Colors.white,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Get.theme.primaryColor,
                    unselectedItemColor: blackColor,
                    iconSize: 21.sp,
                    currentIndex: bottomNavigationController.bottomNavIndex,
                    showSelectedLabels: true,
                    selectedLabelStyle:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    unselectedLabelStyle:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    selectedFontSize: 16.sp,
                    unselectedFontSize: 16.sp,
                    showUnselectedLabels: true,
                    elevation: 5,
                    items: List.generate(iconList.length, (index) {
                      if (index == 0) {
                        if (bottomNavigationController.isValueShow == false) {
                          bottomNavigationController.isValueShow = true;
                        }

                        return BottomNavigationBarItem(
                          icon: Icon(
                            iconList[index],
                          ),
                          activeIcon: Icon(
                            iconList[index],
                          ),
                          label: tr(tabList[index]),
                        );
                      } else if (index == 1) {
                        if (bottomNavigationController.isValueShowChat ==
                            false) {
                          bottomNavigationController.isValueShowChat = true;
                        }
                        return BottomNavigationBarItem(
                          icon: Icon(
                            iconList[index],
                          ),
                          activeIcon: Icon(
                            iconList[index],
                          ),
                          label: tr(tabList[index]),
                        );
                      } else if (index == 2) {
                        if (bottomNavigationController.isValueShowLive ==
                            false) {
                          bottomNavigationController.isValueShowLive = true;
                        }
                        return BottomNavigationBarItem(
                          activeIcon: CircleAvatar(
                            backgroundColor: Get.theme.primaryColor,
                            child: Image.asset(
                              "assets/images/live.gif",
                              height: 45,
                              fit: BoxFit.fitHeight,
                              //width: 40,
                            ),
                          ),
                          icon: Image.asset(
                            "assets/images/live.gif",
                            height: 45,
                            fit: BoxFit.fill,
                            //width: 40,
                          ),
                          label: tr(tabList[index]),
                          backgroundColor: Colors.white,
                        );
                      } else if (index == 3) {
                        if (bottomNavigationController.isValueShowCall ==
                            false) {
                          bottomNavigationController.isValueShowCall = true;
                        }
                        return BottomNavigationBarItem(
                          activeIcon: Icon(
                            Icons.phone_in_talk_sharp,
                          ),
                          icon: Icon(
                            Icons.phone_in_talk_sharp,
                          ),
                          label: tr(tabList[index]),
                          backgroundColor: Colors.white,
                        );
                      } else {
                        if (bottomNavigationController.isValueShowHist ==
                            false) {
                          bottomNavigationController.isValueShowHist = true;
                        }
                        return BottomNavigationBarItem(
                          activeIcon: Icon(
                            Icons.history_sharp,
                          ),
                          icon: Icon(
                            Icons.history_sharp,
                          ),
                          label: tr(tabList[index]),
                        );
                      }
                    }),
                    onTap: (index) async {
                      if (index == 0) {
                        // global.warningDialog(context);
                        bottomNavigationController.setBottomIndex(
                            index, bottomNavigationController.historyIndex);
                      } else if (index == 1 || index == 3) {
                        bottomNavigationController.setBottomIndex(
                            index, bottomNavigationController.historyIndex);
                      } else if (index == 2) {
                        bool isLogin = await global.isLogin();
                        if (isLogin) {
                          global.showOnlyLoaderDialog(context);
                          await bottomNavigationController
                              .getLiveAstrologerList();
                          global.hideLoader();
                          bottomNavigationController.setBottomIndex(
                              index, bottomNavigationController.historyIndex);
                        }
                      } else if (index == 4) {
                        bool isLogin = await global.isLogin();
                        if (isLogin) {
                          global.showOnlyLoaderDialog(context);
                          await global.splashController.getCurrentUserData();
                          await historyController.getPaymentLogs(
                              global.currentUserId!, false);
                          historyController.walletTransactionList = [];
                          historyController.walletTransactionList.clear();
                          historyController.walletAllDataLoaded = false;
                          await historyController.getWalletTransaction(
                              global.currentUserId!, false);
                          global.hideLoader();
                          bottomNavigationController.setBottomIndex(
                              index, bottomNavigationController.historyIndex);
                        }
                      }
                    },
                  ),
                );
              },
            ),
            body: bottomNavigationController
                .screens()
                .elementAt(bottomNavigationController.bottomNavIndex));
      }),
    );
    //);
  }
}
