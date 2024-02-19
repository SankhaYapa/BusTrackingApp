import 'package:flutter/material.dart';
import 'package:road_map_v2/core/app_export.dart';

class CustomBottomBar extends StatefulWidget {
  CustomBottomBar({this.onChanged});

  Function(BottomBarEnum)? onChanged;

  @override
  CustomBottomBarState createState() => CustomBottomBarState();
}

class CustomBottomBarState extends State<CustomBottomBar> {
  int selectedIndex = 0;

  List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
      icon: ImageConstant.imgImage16,
      activeIcon: ImageConstant.imgImage16,
      type: BottomBarEnum.Image16,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgImage19,
      activeIcon: ImageConstant.imgImage19,
      type: BottomBarEnum.Image19,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgImage18,
      activeIcon: ImageConstant.imgImage18,
      type: BottomBarEnum.Image18,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgImage22,
      activeIcon: ImageConstant.imgImage22,
      type: BottomBarEnum.Image22,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68.v,
      decoration: BoxDecoration(
        border: Border.all(
          color: appTheme.blueGray400,
          width: 1.h,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        elevation: 0,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(bottomMenuList.length, (index) {
          return BottomNavigationBarItem(
            icon: CustomImageView(
              imagePath: bottomMenuList[index].icon,
              height: 39.v,
              width: 38.h,
            ),
            activeIcon: CustomImageView(
              imagePath: bottomMenuList[index].activeIcon,
              height: 34.v,
              width: 32.h,
            ),
            label: '',
          );
        }),
        onTap: (index) {
          selectedIndex = index;
          widget.onChanged?.call(bottomMenuList[index].type);
          setState(() {});
        },
      ),
    );
  }
}

enum BottomBarEnum {
  Image16,
  Image19,
  Image18,
  Image22,
}

class BottomMenuModel {
  BottomMenuModel({
    required this.icon,
    required this.activeIcon,
    required this.type,
  });

  String icon;

  String activeIcon;

  BottomBarEnum type;
}

class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please replace the respective Widget here',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
