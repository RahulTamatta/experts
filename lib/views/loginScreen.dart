// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/loginController.dart';
import 'package:AstrowayCustomer/controllers/search_controller.dart';
import 'package:AstrowayCustomer/utils/AppColors.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

String privacyUrl = "https://astrowaypro.diploy.in/privacy-and-policy";
String termsconditionUrl = "https://astrowaypro.diploy.in/terms-and-condition";
String refundpolicy = 'https://astrowaypro.diploy.in/refundPolicy';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final homeController = Get.find<HomeController>();
  final _initialPhone = PhoneNumber(isoCode: "IN");

  late String? codeVerifier;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipPath(
                    clipper: CustomClipPath(),
                    child: Container(
                        color: Get.theme.primaryColor,
                        width: Get.width,
                        height: Get.height * 0.22,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.find<SearchControllerCustom>()
                                        .serachTextController
                                        .clear();
                                    Get.find<SearchControllerCustom>()
                                        .searchText = '';
                                    homeController.myOrders.clear();
                                    BottomNavigationController
                                        bottomNavigationController =
                                        Get.find<BottomNavigationController>();
                                    bottomNavigationController.setIndex(0, 0);
                                    Get.off(() =>
                                        BottomNavigationBarScreen(index: 0));
                                  },
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(right: 2.w, top: 2.h),
                                    child: Text(
                                      "Skip",
                                      textAlign: TextAlign.end,
                                      style:
                                          Get.textTheme.titleMedium!.copyWith(
                                        color: whiteColor,
                                      ),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Get.height * 0.01),
                            Image.asset(
                              "assets/images/splash.png",
                              fit: BoxFit.cover,
                              height: Get.height * 0.15,
                            ),
                          ],
                        )))),
                Container(
                    width: Get.width,
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: Get.height * 0.06,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Login to Astroway',
                                    style: Get.textTheme.titleMedium!.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800),
                                    textAlign: TextAlign.center)
                                .tr(),
                          ],
                        ),
                        SizedBox(
                          height: Get.height * 0.02,
                        ),
                        GetBuilder<LoginController>(builder: (loginController) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: SizedBox(
                                    child: Theme(
                                      data: ThemeData(
                                        dialogTheme: DialogThemeData(
                                          contentTextStyle: const TextStyle(
                                              color: Colors.white),
                                          backgroundColor: Colors.grey[800],
                                          surfaceTintColor: Colors.grey[800],
                                        ),
                                      ),
                                      //MOBILE
                                      child: SizedBox(
                                        child: InternationalPhoneNumberInput(
                                          textFieldController:
                                              loginController.phoneController,
                                          inputDecoration:
                                              const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Phone number',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                          onInputValidated: (bool value) {
                                            loginController.countryvalidator =
                                                value;
                                            loginController
                                                .update(); // If using GetX or setState if you're using StatefulWidget
                                            print(
                                                "Number valid? ${loginController.countryvalidator}");
                                          },
                                          selectorConfig: const SelectorConfig(
                                            leadingPadding: 2,
                                            selectorType: PhoneInputSelectorType
                                                .BOTTOM_SHEET,
                                          ),
                                          ignoreBlank: false,
                                          autoValidateMode:
                                              AutovalidateMode.disabled,
                                          selectorTextStyle: const TextStyle(
                                              color: Colors.black),
                                          searchBoxDecoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(2.w)),
                                                borderSide: const BorderSide(
                                                    color: Colors.black),
                                              ),
                                              hintText: "Search",
                                              hintStyle: const TextStyle(
                                                color: Colors.black,
                                              )),
                                          initialValue: _initialPhone,
                                          formatInput: false,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              signed: true, decimal: false),
                                          inputBorder: InputBorder.none,
                                          onSaved: (PhoneNumber number) {
                                            log('On Saved: ${number.dialCode}');
                                            loginController.updateCountryCode(
                                                number.dialCode);
                                            loginController.updateCountryCode(
                                                number.dialCode);
                                          },
                                          onFieldSubmitted: (value) {
                                            log('On onFieldSubmitted: $value');
                                            FocusScope.of(context).unfocus();
                                          },
                                          onInputChanged: (PhoneNumber number) {
                                            log('On onInputChanged: ${number.dialCode}');
                                            log('On onInputChanged: ${number.phoneNumber}');
                                            loginController.updateCountryCode(
                                                number.dialCode);
                                            loginController.updateCountryCode(
                                                number.dialCode);
                                          },
                                          onSubmit: () {
                                            log('On onSubmit:');
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  bool isValid = loginController.validedPhone();

                                  if (isValid) {
                                    dynamic phoneno =
                                        loginController.phoneController.text;
                                    log('phone no is $phoneno');
                                    global.showOnlyLoaderDialog(Get.context);
                                    await loginController
                                        .startHeadlessWithWhatsapp('phone');
                                  } else {
                                    global.showToast(
                                      message: "Invalid Number",
                                      textColor: global.textColor,
                                      bgColor: global.toastBackGoundColor,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    color: Get.theme.primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'SEND OTP',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ).tr(),
                                      Image.asset(
                                        'assets/images/arrow_left.png',
                                        color: Colors.white,
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.height * 0.01,
                              ),
                              InkWell(
                                onTap: () {
                                  global.showOnlyLoaderDialog(context);
                                  loginController
                                      .startHeadlessWithWhatsapp("WHATSAPP");
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius:
                                          BorderRadius.circular(10.sp)),
                                  width: 100.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/whatsapp.png",
                                        height: 6.h,
                                        width: 16.w,
                                        fit: BoxFit.cover,
                                      ),
                                      Text('Continue with Whatsapp').tr(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.height * 0.01,
                              ),
                              InkWell(
                                onTap: () {
                                  global.showOnlyLoaderDialog(context);
                                  loginController
                                      .startHeadlessWithWhatsapp("GMAIL");
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius:
                                          BorderRadius.circular(10.sp)),
                                  width: 100.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/gmail.png",
                                        height: 5.h,
                                        width: 7.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      SizedBox(
                                        width: 3.w,
                                      ),
                                      Text('Continue with Gmail').tr(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              SizedBox(
                                child: Row(children: [
                                  Text(
                                    'By signing up, you agree to our ',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ).tr(),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(termsconditionUrl));
                                    },
                                    child: Text(
                                      'Terms of use',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 11,
                                          color: Colors.blue),
                                    ).tr(),
                                  ),
                                  Text(' and ',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 11))
                                      .tr(),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(privacyUrl));
                                    },
                                    child: Text(
                                      ' Privacy',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 11,
                                          color: Colors.blue),
                                    ).tr(),
                                  ),
                                ]),
                              ),
                              GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(privacyUrl));
                                },
                                child: Text(
                                  'Policy',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 11,
                                    color: Colors.blue,
                                  ),
                                ).tr(),
                              ),
                            ],
                          );
                        }),
                        SizedBox(
                          height: Get.height * 0.01,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            height: 5.h,
                            color: Get.theme.primaryColor
                                .withOpacity(0.8), // Background color
                            child: Stack(
                              children: [
                                Positioned(
                                  left: -2,
                                  top: 0,
                                  bottom: 0,
                                  child: CustomPaint(
                                    size: Size(15,
                                        5.h), // Adjust the size of the triangle
                                    painter: LeftTrianglePainter(),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  top: 0,
                                  bottom: 0,
                                  child: CustomPaint(
                                    size: Size(15,
                                        5.h), // Adjust the size of the triangle
                                    painter: RightTrianglePainter(),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'First Chat Free on Signup',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w400),
                                  ).tr(),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 22.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                child: Card(
                                  elevation: 0,
                                  margin: EdgeInsets.only(top: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 6)
                                        .copyWith(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              height: 68,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                color: Colors.grey[200],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  Images.confidential,
                                                  height: 45,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Private &\nConfidential',
                                              textAlign: TextAlign.center,
                                              style: Get
                                                  .theme.textTheme.titleMedium!
                                                  .copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.0,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 65,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                color: Colors.grey[200],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  Images.verifiedAccount,
                                                  height: 45,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text("Verified\nAstrologer"),
                                            // global.buildTranslatedText(
                                            //     'Verified\n ${global.getSystemFlagValueForLogin(global.systemFlagNameList.professionTitle)}',
                                            //     Get.theme.textTheme.titleMedium!
                                            //         .copyWith(
                                            //       fontSize: 16.sp,
                                            //       fontWeight: FontWeight.w400,
                                            //       letterSpacing: 0.5,
                                            //     )),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 65,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                color: Colors.grey[200],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  Images.payment,
                                                  height: 45,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              'Secure\nPayments',
                                              textAlign: TextAlign.center,
                                              style: Get
                                                  .theme.textTheme.titleMedium!
                                                  .copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.0,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 5.0;
  @override
  Path getClip(Size size) {
    Path path_1 = Path();
    path_1.moveTo(size.width * -0.0034000, size.height * -0.0005200);
    path_1.lineTo(size.width * 3.0044000, size.height * 0.0041400);
    path_1.quadraticBezierTo(size.width * 1.0017750, size.height * 0.6117900,
        size.width * 1.0009000, size.height * 0.8143400);
    path_1.cubicTo(
        size.width * 0.7438000,
        size.height * 1.0302400,
        size.width * 0.3289375,
        size.height * 1.0551400,
        size.width * 0.0006000,
        size.height * 0.8136600);
    path_1.quadraticBezierTo(size.width * -0.0010250, size.height * 0.6101200,
        size.width * -0.0034000, size.height * -0.0005200);
    path_1.close();

    return path_1;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LeftTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white; // Triangle color

    Path path = Path();
    path.moveTo(size.width, size.height / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RightTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white; // Triangle color

    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
