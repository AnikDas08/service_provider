
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/app_storage/app_auth_storage.dart';
import 'package:haircutmen_user_app/component/app_storage/storage_key.dart';
import 'package:haircutmen_user_app/features/profile/data/profile_model.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';

class ProfileController extends GetxController {
  /// Language List here
  List languages = ["English", "French", "Arabic"];

  /// form key here
  final formKey = GlobalKey<FormState>();

  /// select Language here
  String selectedLanguage = "English";

  /// select image here
  String? image;

  /// edit button loading here
  bool isLoading = false;

  /// all controller here
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  var name = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var location = "".obs;

  ProfileData? profileData;
  bool isProfileLoading=false;


  @override
  void onInit() {
    super.onInit();
    getProfile();
  }


  /// select image function here
  getProfileImage() async {
    image = await OtherHelper.openGalleryForProfile();
    update();
  }

  /// select language  function here
  selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }

  Future<void> getProfile()async{
    isProfileLoading=true;
    update();
    try{
      final token=AppAuthStorage().getValue(StorageKey.token);
      final response=await ApiService.get(
        ApiEndPoint.user,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}"
        }
      );
      if(response.statusCode==200){
        final profileModel=ProfileModel.fromJson(response.data);
        profileData = profileModel.data;
        nameController.text=profileData?.name??"";
        numberController.text=profileData?.contact??"";
        name.value=profileData?.name??"";
        phone.value=profileData?.contact??"";
        email.value=profileData?.email??"";
        location.value=profileData?.location??"";
        update();
      }
      else{
        ///rtrfgg
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    }
    catch(e){
      Utils.errorSnackBar(0, e.toString());
    }
      isProfileLoading=false;
      update();

  }



  /// update profile function here
  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;

    if (!LocalStorage.isLogIn) return;
    isLoading = true;
    update();

    Map<String, String> body = {
      "fullName": nameController.text,
      "phone": numberController.text,
    };

    var response = await ApiService.multipart(
      ApiEndPoint.user,
      body: body,
      imagePath: image,
      imageName: "image",
    );

    if (response.statusCode == 200) {
      var data = response.data;

      LocalStorage.userId = data['data']?["_id"] ?? "";
      LocalStorage.myImage = data['data']?["image"] ?? "";
      LocalStorage.myName = data['data']?["fullName"] ?? "";
      LocalStorage.myEmail = data['data']?["email"] ?? "";

      LocalStorage.setString("userId", LocalStorage.userId);
      LocalStorage.setString("myImage", LocalStorage.myImage);
      LocalStorage.setString("myName", LocalStorage.myName);
      LocalStorage.setString("myEmail", LocalStorage.myEmail);

      Utils.successSnackBar("Successfully Profile Updated", response.message);
      Get.toNamed(AppRoutes.profile);
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
    }

    isLoading = false;
    update();
  }
}
