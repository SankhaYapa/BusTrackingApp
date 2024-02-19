import 'package:flutter/material.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/widgets/custom_elevated_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 21.h),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 32.v),
                      CustomImageView(
                          imagePath: ImageConstant.imgIllustratedFri,
                          height: 180.v,
                          width: 150.h),
                      SizedBox(height: 207.v),
                      Container(
                          width: 293.h,
                          margin: EdgeInsets.symmetric(horizontal: 27.h),
                          child: Text("Real-Time Safety, With Travel Buddy",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displaySmall)),
                      SizedBox(height: 26.v),
                      CustomElevatedButton(
                          text: "Start",
                          margin: EdgeInsets.only(left: 9.h),
                          onPressed: () {
                            onTapStart(context);
                          })
                    ]))));
  }

  /// Navigates to the loginScreen when the action is triggered.
  onTapStart(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }
}
