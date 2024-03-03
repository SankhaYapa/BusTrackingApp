import 'package:flutter/material.dart';
import 'package:road_map_v2/presentation/communication_screen/communication_screen.dart';
import 'package:road_map_v2/presentation/homepage_page/homepage_page.dart';
import 'package:road_map_v2/presentation/map_screen/map_user.dart';
import 'package:road_map_v2/presentation/splash_screen/splash_screen.dart';
import 'package:road_map_v2/presentation/login_screen/login_screen.dart';
import 'package:road_map_v2/presentation/homepage_container_screen/homepage_container_screen.dart';
import 'package:road_map_v2/presentation/map_screen/map_screen.dart';
import 'package:road_map_v2/presentation/profile_screen/profile_screen.dart';
import 'package:road_map_v2/presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash_screen';

  static const String loginScreen = '/login_screen';

  static const String homepagePage = '/homepage_page';

  static const String homepageContainerScreen = '/homepage_container_screen';

  static const String mapScreen = '/map_screen';

  static const String profileScreen = '/profile_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String commicunication = '/app_navigation_screen';

  static const String appNavigationmapUser = '/app_navigation_screen_user';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    homepageContainerScreen: (context) => HomepageContainerScreen(),
    mapScreen: (context) => MapUser(),
    profileScreen: (context) => ProfileScreen(),
    appNavigationScreen: (context) => AppNavigationScreen(),
    commicunication: (context) => CommunicationScreen(),
    appNavigationmapUser: (context) => MapUser()
  };
}
