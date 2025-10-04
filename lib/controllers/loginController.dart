import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/model/login_model.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

import '../model/device_info_login_model.dart';
import '../utils/global.dart';
import '../views/bottomNavigationBarScreen.dart';
import '../views/verifyPhoneScreen.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  late TextEditingController phoneController;
  SplashController splashController = Get.find<SplashController>();
  String validationId = "";
  double second = 0;
  var maxSecond;
  // String countryCode = "+91";
  Timer? time;
  Timer? time2;
  String smsCode = "";
  //String verificationId = "";
  String? errorText;
  APIHelper apiHelper = APIHelper();
  String selectedCountryCode = "+91";
  var flag = '🇮🇳';

  @override
  void onInit() {
    phoneController = TextEditingController();
    super.onInit();
  }
  void onHeadlessResultVerify(dynamic result) async {
    dataResponse = result;
    log("all response:-  ${dataResponse}");
    if (dataResponse['statusCode'].toString() == "200") {
      // print("phone no ${int.parse(phoneController.text)}");//errrorrrrr
      await loginAndSignupUser(
          int.parse(phoneController.text),
          // int.parse(data['authentication_details']['phone']['phone_number']
          //     .toString()),
          ""
      );
    } else {
      Fluttertoast.showToast(msg: "Invalid Otp");
      hideLoader();
    }
  }

  Future<void> startHeadlessWithWhatsapp(String type, {bool? resendOtp=false}) async {
    if (Platform.isAndroid) {
      otplessFlutterPlugin.initHeadless(appId);
      otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
    }
    if (Platform.isIOS && !isInitIos) {
      otplessFlutterPlugin.initHeadless(appId);
      otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
    }
    Map<String, dynamic> arg = type == "phone"
        ? {'phone': '${phoneController.text}', 'countryCode':selectedCountryCode}
        : {
      'channelType': "$type",
    };
    print("resend otp:- ${resendOtp}");
    type == "phone"
        ? otplessFlutterPlugin.startHeadless(resendOtp==true?onResendotp:onHeadlessResultPhone, arg)
        : otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  void onHeadlessResult(dynamic result) async {
    print("email data");
    print("${dataResponse['response']}");
    dataResponse = result;
    if (dataResponse['response']['status'].toString() == "SUCCESS") {
      if (dataResponse['response']['identities'][0]['identityType']
          .toString() ==
          "EMAIL") {
        await loginAndSignupUser(
            null,
            dataResponse['response']['identities'][0]['identityValue']
                .toString());
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/getOtlResponse'),
          body: json.encode({"token": dataResponse['response']['token']}),
          headers: await global.getApiHeaders(false),
        );

        Map data = json.decode(response.body);
        if (response.statusCode == 200) {
          await loginAndSignupUser(
              int.parse(data['authentication_details']['phone']['phone_number']
                  .toString()),
              "");
        }
      }
    } else {
      // hideLoader();
    }
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  void onResendotp(dynamic result) {
    log(" result is1 ${dataResponse}");
    dataResponse = result;
    log(" result is ${dataResponse}");
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  void onHeadlessResultPhone(dynamic result) {
    log(" result is1 ${dataResponse}");
    dataResponse = result;
    log(" result is ${dataResponse}");
    hideLoader();
    if (dataResponse['statusCode'] == 200) {
      timer();
      Get.to(() => VerifyPhoneScreen(
        phoneNumber: phoneController.text,
      ));
    }
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  final otplessFlutterPlugin = Otpless();
  var loaderVisibility = true;
  final TextEditingController urlTextContoller = TextEditingController();
  Map dataResponse = {};
  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;
  static const String appId = "EGN337D0735VTPMTQY22";

  timer() {
    maxSecond = 60;
    update();
    print("maxSecond:- ${maxSecond}");
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time!.cancel();
      }
    });
  }

  updateCountryCode(value) {
    selectedCountryCode = value.toString();
    print('countryCode -> $selectedCountryCode');
    update();
  }


  bool countryvalidator=false;

  bool validedPhone() {

    return countryvalidator;
  }



  loginAndSignupUser(int? phoneNumber, String email) async {
    try {
      await global.getDeviceData();
      LoginModel loginModel = LoginModel();
      email.toString() != ""
          ? loginModel.contactNo = null
          : loginModel.contactNo = phoneNumber.toString();
      email.toString() == "" ? null : loginModel.email = email.toString();
      loginModel.countryCode = selectedCountryCode.toString();
      loginModel.deviceInfo = DeviceInfoLoginModel();
      loginModel.deviceInfo?.appId = global.appId;
      loginModel.deviceInfo?.appVersion = global.appVersion;
      loginModel.deviceInfo?.deviceId = global.deviceId;
      loginModel.deviceInfo?.deviceLocation = global.deviceLocation ?? "";
      loginModel.deviceInfo?.deviceManufacturer = global.deviceManufacturer;
      loginModel.deviceInfo?.deviceModel = global.deviceManufacturer;
      loginModel.deviceInfo?.fcmToken = global.fcmToken;
      loginModel.deviceInfo?.appVersion = global.appVersion;

      await apiHelper.loginSignUp(loginModel).then((result) async {
        if (result.status == "200") {
          var recordId = result.recordList["recordList"];
          var token = result.recordList["token"];
          var tokenType = result.recordList["token_type"];
          await global.saveCurrentUser(recordId["id"], token, tokenType);
          await splashController.getCurrentUserData();
          await global.getCurrentUser();
          // global.hideLoader();
          final homeController = Get.find<HomeController>();
          homeController.myOrders.clear();
          time?.cancel();
          update();

          bottomController.setIndex(0, 0);
          Get.off(() => BottomNavigationBarScreen(index: 0));
        } else {
          global.hideLoader();
          Get.off(() => LoginScreen());
        }
      });
    } catch (e) {
      global.hideLoader();
      print("Exception in loginAndSignupUser():-" + e.toString());
    }
  }
}
