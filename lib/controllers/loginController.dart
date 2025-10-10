import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// dart:io removed - no longer needed
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/main.dart';
import 'package:AstrowayCustomer/model/login_model.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';
// OTPless removed - now using Firebase Auth

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
      Fluttertoast.showToast(msg: "Invalid Otp");
      hideLoader();
    }
  }

  // Firebase Auth method - replaces OTPless
  Future<void> startHeadlessWithWhatsapp(String type, {bool? resendOtp=false}) async {
    try {
      if (type == "GMAIL") {
        // Gmail authentication using Firebase Auth + Google Sign-In
        await signInWithGoogle();
      } else {
        // WhatsApp/Phone authentication using Firebase Phone Auth
        debugPrint("Using Firebase Auth for phone OTP verification");
        
        if (resendOtp == true) {
          await resendOTP();
        } else {
          await sendOTP();
        }
      }
    } catch (e) {
      global.hideLoader();
      global.showToast(
        message: "Authentication failed: ${e.toString()}",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      print("Error in startHeadlessWithWhatsapp: $e");
    }
  }

  // Google Sign-In method using Firebase Auth + Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        global.hideLoader();
        global.showToast(
          message: "Google Sign-In cancelled",
          textColor: Colors.white,
          bgColor: Colors.grey,
        );
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        String email = userCredential.user!.email ?? "";
        String name = userCredential.user!.displayName ?? "";
        print("Google Sign-In successful: $email ($name)");
        
        global.hideLoader();
        global.showToast(
          message: "Google Sign-In successful! Welcome $name",
          textColor: Colors.white,
          bgColor: Colors.green,
        );
        
        // Call the existing login API with email
        await loginAndSignupUser(null, email);
      }
    } catch (e) {
      global.hideLoader();
      global.showToast(
        message: "Google Sign-In failed: ${e.toString()}",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      print("Error in Google Sign-In: $e");
    }
  }

  void onHeadlessResult(dynamic result) async {
    print("email data");
    print("${dataResponse['response']}");
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

  // OTPless removed - Firebase Auth is now used
  var loaderVisibility = true;
  final TextEditingController urlTextContoller = TextEditingController();
  Map dataResponse = {};
  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;
  // OTPless app ID removed - using Firebase Auth

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

  // Firebase Auth Methods
  String _verificationId = "";
  
  // Helper method to format phone number to E.164 format
  String _formatPhoneNumberToE164(String countryCode, String phoneNumber) {
    // Remove any non-digit characters from phone number
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Ensure country code starts with +
    String cleanCountryCode = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    
    // Remove leading zeros from phone number
    cleanPhone = cleanPhone.replaceFirst(RegExp(r'^0+'), '');
    
    // Combine country code and phone number
    String e164Number = cleanCountryCode + cleanPhone;
    
    print("Original: $countryCode $phoneNumber -> E.164: $e164Number");
    return e164Number;
  }
  
  Future<void> sendOTP() async {
    try {
      // Validate inputs
      if (phoneController.text.isEmpty) {
        global.showToast(
          message: "Please enter phone number",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
        return;
      }
      
      if (selectedCountryCode.isEmpty) {
        global.showToast(
          message: "Please select country code",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
        return;
      }
      
      // Format phone number to E.164 format for Firebase
      String phoneNumber = _formatPhoneNumberToE164(selectedCountryCode, phoneController.text);
      print("Formatted phone number for Firebase: $phoneNumber");
      
      // Validate E.164 format
      if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phoneNumber)) {
        global.showToast(
          message: "Please enter a valid phone number",
          textColor: Colors.white,
          bgColor: Colors.red,
        );
        return;
      }
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          global.hideLoader();
          global.showToast(
            message: "Verification failed: ${e.message}",
            textColor: Colors.white,
            bgColor: Colors.red,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          timer();
          Get.to(() => VerifyPhoneScreen(phoneNumber: phoneController.text));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      global.hideLoader();
      print("Error sending OTP: $e");
    }
  }

  Future<void> verifyOTP(String otpCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpCode,
      );
      
      await _signInWithCredential(credential);
    } catch (e) {
      global.hideLoader();
      global.showToast(
        message: "Invalid OTP",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      print("Error verifying OTP: $e");
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        String firebasePhoneNumber = userCredential.user!.phoneNumber ?? "";
        print("Firebase returned phone number: $firebasePhoneNumber");
        
        // Extract phone number without country code for API call
        String cleanCountryCode = selectedCountryCode.startsWith('+') ? selectedCountryCode : '+$selectedCountryCode';
        String cleanPhoneNumber = firebasePhoneNumber.replaceFirst(cleanCountryCode, "");
        
        // Remove any leading zeros
        cleanPhoneNumber = cleanPhoneNumber.replaceFirst(RegExp(r'^0+'), '');
        
        print("Clean phone number for API: $cleanPhoneNumber");
        await loginAndSignupUser(int.parse(cleanPhoneNumber), "");
      }
    } catch (e) {
      global.hideLoader();
      global.showToast(
        message: "Sign in failed",
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      print("Error signing in: $e");
    }
  }

  Future<void> resendOTP() async {
    if (maxSecond <= 0) {
      await sendOTP();
    }
  }
}
