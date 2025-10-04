import 'dart:convert';

import 'package:AstrowayCustomer/controllers/IntakeController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/kundliMatchingController.dart';
import 'package:AstrowayCustomer/controllers/reportController.dart';
import 'package:AstrowayCustomer/controllers/search_controller.dart';
import 'package:AstrowayCustomer/controllers/search_place_controller.dart';
import 'package:AstrowayCustomer/controllers/userProfileController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../widget/commonAppbar.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

// ignore: must_be_immutable
class PlaceOfBirthSearchScreen extends StatelessWidget {
  final int? flagId;
  PlaceOfBirthSearchScreen({Key? key, this.flagId}) : super(key: key);
  UserProfileController userProfileController =
      Get.find<UserProfileController>();
  KundliController kundliController = Get.find<KundliController>();
  IntakeController callIntakeController = Get.find<IntakeController>();
  ReportController reportController = Get.find<ReportController>();
  KundliMatchingController kundliMatchingController =
      Get.find<KundliMatchingController>();
  CallController callController = Get.find<CallController>();
  SearchControllerCustom searchController = Get.find<SearchControllerCustom>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: CommonAppBar(
          title: tr('Place of Birth'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            GetBuilder<SearchPlaceController>(builder: (searchPlaceController) {
          return Column(
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (value) async {
                    await searchPlaceController.autoCompleteSearch(value);
                  },
                  controller: searchPlaceController.searchController,
                  decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Get.theme.iconTheme.color,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      hintText: 'Search City',
                      hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: searchPlaceController.predictions!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(searchPlaceController
                          .predictions![index].primaryText),
                      onTap: () async {
                        List<Location> location;
                        if (kIsWeb) {
                          List<Map<String, double>> hardcodedData = [
                            {'latitude': 40.7128, 'longitude': -74.0060},
                            {'latitude': 40.7128, 'longitude': -74.0060},
                          ];
                          location = hardcodedData.map((data) {
                            return Location(
                                latitude: data['latitude']!,
                                longitude: data['longitude']!,
                                timestamp: DateTime.now());
                          }).toList();
                        } else {
                          print("timezone");
                          print("${searchPlaceController
                              .predictions![index].primaryText
                              .toString()}");
                          location = await locationFromAddress(
                            searchPlaceController
                                .predictions![index].primaryText
                                .toString(),
                          );
                        }
                        debugPrint('loc lat is ${location[0].latitude}');
                        kundliController.lat = location[0].latitude;
                        kundliController.long = location[0].longitude;

                        kundliMatchingController.lat = location[0].latitude;
                        kundliMatchingController.long = location[0].longitude;
                        print('${location[0].latitude} :- location');
                        print('${location[0].longitude} :- location');
                        await kundliController.getGeoCodingLatLong(
                            latitude: location[0].latitude,
                            longitude: location[0].longitude,
                            flagId: flagId,
                            kundliMatchingController: kundliMatchingController);
                        searchPlaceController.searchController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        searchPlaceController.update();
                        kundliController.birthKundliPlaceController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        kundliController.update();

                        kundliController.editBirthPlaceController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        kundliController.update();
                        if (flagId == 1) {
                          kundliMatchingController.cBoysBirthPlace.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          kundliMatchingController.boyLat =
                              location[0].latitude;
                          kundliMatchingController.boyLong =
                              location[0].longitude;
                          kundliMatchingController.update();
                        }
                        if (flagId == 2) {
                          kundliMatchingController.cGirlBirthPlace.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          kundliMatchingController.girlLat =
                              location[0].latitude;
                          kundliMatchingController.girlLong =
                              location[0].longitude;
                          kundliMatchingController.update();
                        }
                        if (flagId == 4) {
                          userProfileController.addressController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                        }
                        if (flagId == 3) {
                          userProfileController.placeBirthController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                        }
                        if (flagId == 5) {
                          callIntakeController.lat = location[0].latitude;
                          callIntakeController.long = location[0].longitude;
                          callIntakeController.getGeoCodingLatLong(
                            latitude: callIntakeController.lat,
                            longitude: callIntakeController.long
                          );
                          callIntakeController.placeController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                        }
                        if (flagId == 6) {
                          callIntakeController.partnerPlaceController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                        }
                        if (flagId == 7) {
                          reportController.placeController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          reportController.update();
                        }
                        if (flagId == 8) {
                          reportController.partnerPlaceController.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          reportController.update();
                        }
                        callIntakeController.update();
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<List<Location>> getLocationFromAddress(String address) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${global.getSystemFlagValue(global.systemFlagNameList.googleMapApiKey)}');

    debugPrint('location url: ${url}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        debugPrint('location lat : ${location['lat']}');
        debugPrint('location long : ${location['long']}');
        debugPrint('location : ${location}');

        return [
          // Location(latitude: location['lat'], longitude: location['lng'])
        ]; // Assuming Location class has lat and lng properties
      } else {
        print('Geocoding error: ${data['status']}');
        return [];
      }
    } else {
      print('Error fetching location data: ${response.statusCode}');
      return [];
    }
  }
}
