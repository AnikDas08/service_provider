import 'package:flutter/material.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../component/text/common_text.dart';
import '../../../../../utils/constants/app_string.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Body Section stats here
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CustomAppBar(title: AppString.privacy_policy,),
              SizedBox(height: 20,),
              CommonText(
                  text: AppString.privacy_policy,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                textAlign: TextAlign.start,
                maxLines: 50,
                color: AppColors.black300,
              )
            ],
          ),
        ),
      )
    );
  }
}
