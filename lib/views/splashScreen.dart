// ignore_for_file: must_be_immutable

import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/life_cycle_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final splashController = Get.put(SplashController());
  final homeCheckController = Get.put(HomeCheckController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              //Get.theme.primaryColor,
              radius: 50,
              backgroundImage: AssetImage('assets/images/splash.png'),
            ),
            const SizedBox(
              height: 15,
            ),
            GetBuilder<SplashController>(builder: (s) {
              return splashController.appName == ''
                  ? const CircularProgressIndicator()
                  : Text(
                      splashController.appName,
                      style: Get.textTheme.headlineSmall,
                    );
            })
          ],
        ),
      ),
    );
  }
}
