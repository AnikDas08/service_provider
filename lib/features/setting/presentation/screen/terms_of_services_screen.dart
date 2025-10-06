import 'package:flutter/material.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/app_bar/custom_appbars.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_string.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: AppString.term_condition_text,),
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
      ),
    );
  }
}
