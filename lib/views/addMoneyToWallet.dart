
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/model/businessLayer/baseRoute.dart';
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widget/commonAppbar.dart';

class AddmoneyToWallet extends BaseRoute {
  AddmoneyToWallet({a, o}) : super(a: a, o: o, r: 'AddMoneyToWallet');
  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      appBar:kIsWeb?AppBar(
        leading: SizedBox(),
      ): PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Add money to wallet',
          )),
      body: SingleChildScrollView(
        child: kIsWeb?
        GetBuilder<SplashController>(builder: (splash) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width*0.13
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Recharge Your Wallet Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700),
                    ).tr(),
                  ],
                ),
                SizedBox(height: 6,),
                Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.w500,
                    fontSize: 16.sp
                  ),
                ).tr(),
                Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${splashController.currentUser!.walletAmount.toString()}', style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                GetBuilder<WalletController>(builder: (c) {
                  return GridView.builder(
                      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 3 / 1.5,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 0.5,
                        mainAxisExtent: MediaQuery.of(context).size.height*0.13
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: walletController.paymentAmount.length,
                      itemBuilder: (context, index) {
                        print("cashbackprice");
                        print("${walletController.paymentAmount[index].cashback}");
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => PaymentInformationScreen(
                                  amount: double.parse(walletController.paymentAmount[index].amount.toString()),
                                ));
                          },
                          child: Container(
                            margin:  EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width*0.007,
                              vertical: MediaQuery.of(context).size.height*0.008,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 15,),
                                      Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.paymentAmount[index].amount}',
                                        style: TextStyle(
                                          fontSize:13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                     // index.isOdd?SizedBox():
                                     Container(
                                       decoration: BoxDecoration(
                                           color: Get.theme.primaryColor,
                                           borderRadius: BorderRadius.only(
                                             bottomLeft: Radius.circular(5),
                                             bottomRight: Radius.circular(5),
                                           )
                                       ),
                                       // padding: EdgeInsets.symmetric(
                                       //     vertical: 3
                                       // ),
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Text( "Get ${walletController.paymentAmount[index].cashback}% Extra",
                                             style: TextStyle(
                                                fontSize:13,
                                               color: Colors.white,
                                               fontWeight: FontWeight.w600,
                                             ),
                                      ),
                                         ],
                                       ),
                                     )
                                    ],
                                  )),
                            ),
                          ),
                        );
                      });
                })
              ],
            ),
          );
        }):
        GetBuilder<SplashController>(builder: (splash) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Recharge Your Wallet Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ).tr(),
                  ],
                ),
                SizedBox(height: 6,),
                Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.w500),
                ).tr(),
                Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${splashController.currentUser!.walletAmount.toString()}', style: Get.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                GetBuilder<WalletController>(builder: (c) {
                  return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 1.5,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: walletController.paymentAmount.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => PaymentInformationScreen(
                              amount: double.parse(walletController.paymentAmount[index].amount.toString()),
                              cashback: walletController.paymentAmount[index].cashback,
                            ));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 15,),
                                      Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.paymentAmount[index].amount}',
                                        style: TextStyle(
                                          fontSize:13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                      // index.isOdd?SizedBox():
                                      walletController.paymentAmount[index].cashback==0?SizedBox():  Expanded(
                                        flex: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Get.theme.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              )
                                          ),
                                          // padding: EdgeInsets.symmetric(
                                          //     vertical: 3
                                          // ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text( "Get ${walletController.paymentAmount[index].cashback}% Extra",
                                                style: TextStyle(
                                                  fontSize:13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        );
                      });
                })
              ],
            ),
          );
        }),
      ),
    );
  }
}
