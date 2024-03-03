import 'package:flutter/material.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/presentation/communication_screen/communication_screen.dart';
import 'package:road_map_v2/presentation/homepage_page/homepage_page.dart';
import 'package:road_map_v2/presentation/map_screen/map_screen.dart';
import 'package:road_map_v2/presentation/map_screen/map_user.dart';
import 'package:road_map_v2/presentation/profile_screen/profile_screen.dart';
import 'package:road_map_v2/widgets/custom_bottom_bar.dart';

// ignore_for_file: must_be_immutable
class HomepageContainerScreen extends StatelessWidget {
  HomepageContainerScreen({Key? key}) : super(key: key);

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Navigator(
                key: navigatorKey,
                initialRoute: AppRoutes.homepagePage,
                onGenerateRoute: (routeSetting) => PageRouteBuilder(
                    pageBuilder: (ctx, ani, ani1) =>
                        getCurrentPage(routeSetting.name!),
                    transitionDuration: Duration(seconds: 0))),
            bottomNavigationBar: _buildBottomBar(context)));
  }

  /// Section Widget
  Widget _buildBottomBar(BuildContext context) {
    return CustomBottomBar(onChanged: (BottomBarEnum type) {
      Navigator.pushNamed(navigatorKey.currentContext!, getCurrentRoute(type));
    });
  }

  ///Handling route based on bottom click actions
  String getCurrentRoute(BottomBarEnum type) {
    switch (type) {
      case BottomBarEnum.Image16:
        return AppRoutes.homepagePage;
      case BottomBarEnum.Image19:
        return AppRoutes.mapScreen;
      case BottomBarEnum.Image18:
        return AppRoutes.profileScreen;
      case BottomBarEnum.Image22:
        return AppRoutes.commicunication;
      default:
        return "/";
    }
  }

  ///Handling page based on route
  Widget getCurrentPage(String currentRoute) {
    switch (currentRoute) {
      case AppRoutes.homepagePage:
        return HomepagePage();
      case AppRoutes.mapScreen:
        return MapUser();
      case AppRoutes.profileScreen:
        return ProfileScreen();
      case AppRoutes.commicunication:
        return CommunicationScreen();
      default:
        return DefaultWidget();
    }
  }
}
