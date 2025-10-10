// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/counsellorController.dart';
import 'package:AstrowayCustomer/controllers/follow_astrologer_controller.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/themeController.dart';
import 'package:AstrowayCustomer/views/freeServicesScreen.dart';
import 'package:AstrowayCustomer/views/getReportScreen.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:AstrowayCustomer/views/myFollowingScreen.dart';
import 'package:AstrowayCustomer/views/profile/editUserProfileScreen.dart';
import 'package:AstrowayCustomer/views/settings/colorPicker.dart';
import 'package:AstrowayCustomer/views/settings/settingsScreen.dart';
import 'package:AstrowayCustomer/widget/AppVersionWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:store_redirect/store_redirect.dart';
import '../controllers/astrologer_assistant_controller.dart';
import '../controllers/customer_support_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/images.dart';
import '../views/counsellor/counsellorScreen.dart';
import '../views/customer_support/customerSupportChatScreen.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({Key? key}) : super(key: key);
  final splashController = Get.find<SplashController>();
  final callController = Get.put(CallController());
  final panchangController = Get.find<PanchangController>();
  final historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: GetBuilder<SplashController>(builder: (splashController) {
          return Column(
            children: [
              SizedBox(height: 50),
              splashController.currentUser?.profile == ""
                  ? InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        bool isLogin = await global.isLogin();
                        if (isLogin) {
                          global.showOnlyLoaderDialog(context);
                          await splashController.getCurrentUserData();
                          global.hideLoader();
                          Get.to(() => EditUserProfile());
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        child: Image.asset(
                          Images.deafultUser,
                          fit: BoxFit.fill,
                          height: 40,
                        ),
                      ),
                    )
                  : InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        bool isLogin = await global.isLogin();
                        if (isLogin) {
                          global.showOnlyLoaderDialog(context);
                          await splashController.getCurrentUserData();
                          global.hideLoader();
                          Get.to(() => EditUserProfile());
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl:
                            "${global.imgBaseurl}${splashController.currentUser?.profile}",
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                "${global.imgBaseurl}${splashController.currentUser?.profile}"),
                          );
                        },
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          return CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                Images.deafultUser,
                                fit: BoxFit.fill,
                                height: 50,
                              ));
                        },
                      ),
                    ),
              SizedBox(height: 1),
              Text(
                splashController.currentUser == null
                    ? "user"
                    : splashController.currentUser!.name == ""
                        ? "User"
                        : "${splashController.currentUser!.name}",
                style: Get.textTheme.bodyLarge!
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
              ).tr(),
              splashController.currentUser == null ||
                      splashController.currentUser!.email == null ||
                      splashController.currentUser!.email.toString() == ""
                  ? const SizedBox()
                  : Text(
                      '${splashController.currentUser!.email}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
              splashController.currentUser == null ||
                      splashController.currentUser!.contactNo.toString() ==
                          "null" ||
                      splashController.currentUser!.contactNo.toString() == ""
                  ? const SizedBox()
                  : Text(
                      '${splashController.currentUser!.countryCode}-${splashController.currentUser!.contactNo}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.6,
              ),
              GestureDetector(
                  onTap: () async {
                    final BottomNavigationController
                        bottomNavigationController =
                        Get.find<BottomNavigationController>();
                    bottomNavigationController.astrologerList = [];
                    bottomNavigationController.astrologerList.clear();
                    bottomNavigationController.isAllDataLoaded = false;
                    bottomNavigationController.update();
                    global.showOnlyLoaderDialog(context);
                    await bottomNavigationController.getAstrologerList(
                        isLazyLoading: false);
                    global.hideLoader();
                    Get.to(() => GetReportScreen());
                  },
                  child:
                      _drawerItem(icon: Icons.note_alt, title: 'Get Report')),
              GetBuilder<BottomNavigationController>(builder: (navController) {
                return GestureDetector(
                    onTap: () async {
                      global.showOnlyLoaderDialog(context);
                      navController.astrologerList = [];
                      navController.astrologerList.clear();
                      navController.isAllDataLoaded = false;
                      navController.update();
                      await navController.getAstrologerList(
                          isLazyLoading: false);
                      global.hideLoader();
                      navController.setBottomIndex(1, 0);
                    },
                    child: _drawerItem(
                        icon: Icons.circle_rounded,
                        title: 'Chat with Astrologer'));
              }),
              GetBuilder<CounsellorController>(builder: (counsellorController) {
                return GestureDetector(
                    onTap: () async {
                      global.showOnlyLoaderDialog(context);
                      counsellorController.counsellorList = [];
                      counsellorController.update();
                      await counsellorController.getCounsellorsData(false);
                      global.hideLoader();
                      Get.to(() => CounsellorScreen());
                      //navController.setBottomIndex(2, 0);
                    },
                    child: _drawerItem(
                        icon: Icons.person_outline,
                        title: 'Chat With Counsellors'));
              }),
              GestureDetector(
                  onTap: () async {
                    bool isLogin = await global.isLogin();
                    if (isLogin) {
                      final FollowAstrologerController
                          followAstrologerController =
                          Get.find<FollowAstrologerController>();
                      followAstrologerController.followedAstrologer.clear();
                      followAstrologerController.isAllDataLoaded = false;
                      global.showOnlyLoaderDialog(context);
                      await followAstrologerController
                          .getFollowedAstrologerList(false);
                      global.hideLoader();
                      Get.to(() => MyFollowingScreen());
                    }
                  },
                  child: _drawerItem(
                      icon: Icons.verified_user, title: 'My Following')),
              GetBuilder<HomeController>(builder: (homeController) {
                return GestureDetector(
                    onTap: () async {
                      DateTime datePanchang = DateTime.now();
                      int formattedYear =
                          int.parse(DateFormat('yyyy').format(datePanchang));
                      int formattedDay =
                          int.parse(DateFormat('dd').format(datePanchang));
                      int formattedMonth =
                          int.parse(DateFormat('MM').format(datePanchang));
                      int formattedHour =
                          int.parse(DateFormat('HH').format(datePanchang));
                      int formattedMint =
                          int.parse(DateFormat('mm').format(datePanchang));
                      global.showOnlyLoaderDialog(context);
                      await homeController.getBlog();
                      await homeController.getAstrologyVideos();
                      await panchangController.getPanchangDetail(
                          day: formattedDay,
                          hour: formattedHour,
                          min: formattedMint,
                          month: formattedMonth,
                          year: formattedYear);
                      global.hideLoader();
                      Get.to(() => FreeServiceScreen());
                    },
                    child: _drawerItem(
                        icon: Icons.usb_rounded, title: 'Free Services'));
              }),
              GetBuilder<ThemeController>(builder: (themeController) {
                return GestureDetector(
                    onTap: () async {
                      Get.to(() => ColorPickerPage());
                    },
                    child:
                        _drawerItem(icon: Icons.brightness_2, title: 'Theme'));
              }),
              GestureDetector(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      StoreRedirect.redirect(
                        androidAppId: "com.nexora.fittalk",
                      );
                    }
                  },
                  child: _drawerItem(
                      icon: Icons.person, title: 'Sign Up as Astrologer')),
              global.currentUserId != null
                  ? GestureDetector(
                      onTap: () async {
                        SettingsController settingsController =
                            Get.find<SettingsController>();
                        global.showOnlyLoaderDialog(context);
                        await settingsController.getBlockAstrologerList();
                        global.hideLoader();
                        Get.to(() => SettingListScreen());
                      },
                      child:
                          _drawerItem(icon: Icons.settings, title: 'Settings'))
                  : GestureDetector(
                      onTap: () {
                        Get.off(() => LoginScreen());
                      },
                      child: _drawerItem(
                          icon: Icons.arrow_circle_right_outlined,
                          title: 'Login')),
              GestureDetector(
                onTap: () async {
                  bool isLogin = await global.isLogin();
                  if (isLogin) {
                    CustomerSupportController customerSupportController =
                        Get.find<CustomerSupportController>();
                    AstrologerAssistantController
                        astrologerAssistantController =
                        Get.find<AstrologerAssistantController>();
                    global.showOnlyLoaderDialog(context);
                    await customerSupportController.getCustomerTickets();
                    astrologerAssistantController
                        .getChatWithAstrologerAssisteant();

                    global.hideLoader();
                    Get.to(() => CustomerSupportChat());
                  }
                  //  Get.off(() => LoginScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Row(children: [
                    Image.asset(
                      Images.customerService,
                      height: 20,
                      width: 20,
                      color: Get.theme.primaryColor,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "${tr("Support")} ${tr("Chat")}",
                      style: Get.textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    ).tr(),
                  ]),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.6,
              ),
              Text(
                "Also Available On",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ).tr(),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/facebook.png",
                    fit: BoxFit.cover,
                    height: 25,
                  ),
                  Image.asset("assets/images/instagram.png",
                      fit: BoxFit.cover, height: 25),
                  Image.asset("assets/images/twitter.png",
                      fit: BoxFit.cover, height: 25),
                  Image.asset("assets/images/youtube.png",
                      fit: BoxFit.fitHeight, height: 25),
                ],
              ),
              SizedBox(height: 2),
              const AppVersionWidget(),
              SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 50,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(children: [
        Icon(
          icon,
          color: Get.theme.primaryColor,
          size: 18,
        ),
        SizedBox(
          width: 15,
        ),
        Text(
          title,
          style: Get.textTheme.bodyLarge!
              .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
        ).tr(),
      ]),
    );
  }
}
