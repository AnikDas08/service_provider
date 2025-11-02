import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/message/presentation/screen/chat_screen.dart';
import 'package:haircutmen_user_app/features/overview/presentation/screen/overview_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key}) {
    Get.put(HomeNavController());
  }

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg", "label": AppString.home},
    {"icon": "assets/icons/overview_icon.svg", "label": AppString.overview},
    {"icon": "assets/icons/scan_icon.svg", "label": AppString.qr_text},
    {"icon": "assets/icons/message_icon.svg", "label": AppString.message},
    {"icon": "assets/icons/profile.svg", "label": AppString.profile},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeNavController>();

    return Obx(
          () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            controller.selectedIndex.value == 0 ? HomeScreen():Container(),
            controller.selectedIndex.value == 1 ?OverviewScreen():Container(),
            controller.selectedIndex.value == 2 ? QRScannerScreen() : Container(),
            controller.selectedIndex.value == 3 ?ChatListScreen():Container(),
            controller.selectedIndex.value == 4 ?ProfileScreen():Container(),
          ],
        ),
        bottomNavigationBar: Container(
          color: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navItems.length, (index) {
              final isSelected = controller.selectedIndex.value == index;
              return GestureDetector(
                onTap: () => controller.changeIndex(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        _navItems[index]["icon"]!,
                        width: 26.w,
                        height: 26.h,
                        colorFilter: ColorFilter.mode(
                          isSelected ? Colors.white : Colors.white54,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      CommonText(
                        text: _navItems[index]["label"]!,
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
