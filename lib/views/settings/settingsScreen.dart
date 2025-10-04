import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/settings_controller.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/block_astrologer_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/commonAppbar.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import '../loginScreen.dart';

class SettingListScreen extends StatelessWidget {
  const SettingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: CommonAppBar(
              title: 'Settings',
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GetBuilder<SettingsController>(builder: (settingsController) {
                return settingsController.blockedAstroloer.isEmpty
                    ? const SizedBox()
                    : GestureDetector(
                  onTap: () async {
                    global.showOnlyLoaderDialog(context);
                    await settingsController.getBlockAstrologerList();
                    global.hideLoader();
                    Get.to(() => BlockAstrologerScreen());
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Block Astrologer",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ).tr(),
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(termsconditionUrl));
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Terms and Condition",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ).tr(),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(privacyUrl));
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ).tr(),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(refundpolicy));
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Refund Policy",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ).tr(),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        "Are you sure you want to logout?",
                        style: Get.textTheme.titleMedium,
                      ).tr(),
                      content: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('No').tr(),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                HistoryController historyController =
                                Get.find<HistoryController>();
                                historyController.chatHistoryList.clear();
                                historyController.astroMallHistoryList.clear();
                                historyController.reportHistoryList.clear();
                                historyController.callHistoryList.clear();
                                historyController.paymentLogsList.clear();
                                historyController.walletTransactionList.clear();
                                global.logoutUser();
                              },
                              child: Text('YES').tr(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Text(
                              "Logout my account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ).tr(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
