import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:rdl_radiant/src/screens/attendence/attendence_evening.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/set_customer_location.dart';

import '../../../apis/apis.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';
import '../conveyance/controller/conveyance_data_controller.dart';
import '../conveyance/conveyance_page.dart';
import '../conveyance/model/conveyance_data_model.dart';
import '../delivary_ramaining/controller/delivery_remaning_controller.dart';
import '../delivary_ramaining/delivery_remaining_page.dart';
import '../delivary_ramaining/models/deliver_remaing_model.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final LoadingTextController loadingTextController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    "assets/app_logo_big.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const Text(
                  "ODMS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 40,
                  ),
                ),
                Text(
                  "Outbound Delivery Management System",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                )
              ],
            ),
          ),
          const Gap(10),
          SizedBox(
            child: TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                Get.to(
                  () => const AttendenceEvening(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.verified_outlined,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Evening Attendence',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Get.to(
                  () => const SetCustomerLocation(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Set Coustomer Location',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: callOverDueList,
              child: Row(
                children: [
                  const Gap(20),
                  Container(
                    height: 35,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: const DecorationImage(
                        image: AssetImage("assets/overdue.jpg"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  const Gap(19),
                  const Text(
                    'Overdue',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: callConveyanceList,
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.emoji_transportation,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Conveyance',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   child: TextButton(
          //     onPressed: () async {
          //       if (Navigator.canPop(context)) {
          //         Navigator.pop(context);
          //       }
          //       Get.to(
          //         () => const SelectJourneyEndLocation(),
          //       );
          //     },
          //     child: const Row(
          //       children: [
          //         Gap(20),
          //         Icon(Icons.drive_eta),
          //         Gap(20),
          //         Text('Start Journey'),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Hive.deleteBoxFromDisk('info');
                await Hive.openBox('info');
                unawaited(
                  Get.offAll(
                    () => const LoginPage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void callOverDueList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getOverdueList/${box.get('sap_id')}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await get(url);
    if (kDebugMode) {
      log("Got Delivery Remaning List");
      log(response.statusCode.toString());
      log(response.body);
    }

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      final modelFormHTTPResponse = DeliveryRemaing.fromJson(response.body);
      final patners = modelFormHTTPResponse.result!;
      Map<String, List<Result>> mapForMarge = {};
      for (var patner in patners) {
        List<Result> previosList = mapForMarge[patner.partner] ?? [];
        if (previosList.isNotEmpty) {
          previosList[0].invoiceList!.addAll(patner.invoiceList!);
          mapForMarge[patner.partner!] = previosList;
        } else {
          previosList.add(patner);
          mapForMarge[patner.partner!] = previosList;
        }
      }

      modelFormHTTPResponse.result = [];
      mapForMarge.forEach(
        (key, value) {
          modelFormHTTPResponse.result!.add(value[0]);
        },
      );

      final controller = Get.put(
        DeliveryRemaningController(modelFormHTTPResponse),
      );
      controller.deliveryRemaing.value = modelFormHTTPResponse;
      controller.constDeliveryRemaing.value = modelFormHTTPResponse;
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
      controller.pageType.value = 'Overdue';
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await Get.to(
        () => const DeliveryRemainingPage(),
      );
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callConveyanceList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$conveyanceList?da_code=${box.get('sap_id')}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      log("Message with success: ${response.body}");

      Map decoded = jsonDecode(response.body);

      final conveyanceDataController = Get.put(ConveyanceDataController());
      var temList = <SavePharmaceuticalsLocationData>[];
      List<Map> tem = List<Map>.from(decoded['result']);
      for (int i = 0; i < tem.length; i++) {
        temList.add(SavePharmaceuticalsLocationData.fromMap(
            Map<String, dynamic>.from(tem[i])));
      }
      conveyanceDataController.convenceData.value = temList.reversed.toList();

      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Get.to(
        () => const ConveyancePage(),
      );
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }
}
