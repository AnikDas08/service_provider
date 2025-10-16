/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/auth/sign%20up/data/provider_models.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import '../../../../../services/api/api_response_model.dart';
import '../../../../../services/api/api_service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ServicePair {
  TextEditingController serviceController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? selectedCategoryId;
  String? selectedSubCategoryId;
}

class CompleteProfileController extends GetxController {
  // Controllers
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController pricePerHourController = TextEditingController();

  // Observables
  var profileImage = Rxn<File>();
  RxList uploadedImages = <String>[].obs;
  var serviceDistance = 0.0.obs;
  var isPrivacyAccepted = false.obs;
  var selectedLanguages = <String>[].obs;
  var servicePairs = <ServicePair>[].obs;

  // API Data
  var categories = <Map<String, dynamic>>[].obs;
  var subCategoriesMap = <String, List<Map<String, dynamic>>>{}.obs;
  var isLoadingSubCategories = <String, bool>{}.obs;
  var isUploadingImage = false.obs;

  // Location
  double latitude = 0.0;
  double longitude = 0.0;

  // Static Data
  final languages = ['Bangla', 'English', 'Arabic', 'French', 'Spanish'];

  @override
  void onInit() {
    super.onInit();
    addService();
    requestPermissionsAndFetchLocation();
    fetchCategories();
  }

  // ----------------- API Calls -----------------
  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.category,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          categories.value = List<Map<String, dynamic>>.from(data['data']);
          print("Categories loaded: ${categories.length}");
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
      Get.snackbar("Error", "Failed to load categories");
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      // Set loading state
      isLoadingSubCategories[categoryId] = true;
      isLoadingSubCategories.refresh();

      print("Fetching subcategories for category: $categoryId");

      final response = await ApiService.get(
        "${ApiEndPoint.subCategory}?category=$categoryId",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      print("Subcategory response status: ${response.statusCode}");
      print("Subcategory response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          subCategoriesMap[categoryId] = List<Map<String, dynamic>>.from(
            data['data'],
          );
          subCategoriesMap.refresh();
          print(
            "Subcategories loaded: ${subCategoriesMap[categoryId]?.length ?? 0}",
          );
        } else {
          print("No subcategories found for category: $categoryId");
          subCategoriesMap[categoryId] = [];
          subCategoriesMap.refresh();
        }
      } else {
        print("Failed to fetch subcategories. Status: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load subcategories");
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
      Get.snackbar("Error", "Failed to load subcategories: $e");
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      // Remove loading state
      isLoadingSubCategories[categoryId] = false;
      isLoadingSubCategories.refresh();
    }
  }

  Future<void> updateProfileImage() async {
    if (profileImage.value == null) return;

    try {
      isUploadingImage.value = true;

      await ApiService.multipart(
        "user/profile",
        method: "PATCH",
        imageName: "image", // change to backend expected field
        imagePath: profileImage.value!.path,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      */
/*if (response.statusCode == 200) {
        //Get.snackbar("Success", "Profile image updated successfully!", backgroundColor: Colors.green[100]);
      } else {
        Get.snackbar("Error", response.data['message'] ?? "Failed to update profile image", backgroundColor: Colors.red[100]);
      }*//*

    } catch (e) {
      //Get.snackbar("Error", "Something went wrong: $e", backgroundColor: Colors.red[100]);
    } finally {
      isUploadingImage.value = false;
    }
  }

  List<Map<String, dynamic>> getSubCategoriesForCategory(String categoryId) {
    return subCategoriesMap[categoryId] ?? [];
  }

  bool isSubCategoriesLoading(String categoryId) {
    return isLoadingSubCategories[categoryId] ?? false;
  }

  // ----------------- Permissions & Location -----------------
  Future<void> requestPermissionsAndFetchLocation() async {
    await _requestLocationPermission();
    await getCurrentLocation();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Error",
        "Location permissions are permanently denied, cannot fetch location.",
      );
      return;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      print("Location fetched - Lat: $latitude, Long: $longitude");
      // Don't update locationController here - let user type their own location
      update();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to get location: $e",
        backgroundColor: Colors.red[100],
      );
    }
  }

  // ----------------- Service Management -----------------
  void addService() {
    servicePairs.add(ServicePair());
  }

  void deleteService(int index) {
    if (index < servicePairs.length) servicePairs.removeAt(index);
  }

  void onCategorySelected(
      int pairIndex,
      String categoryId,
      String categoryName,
      ) async {
    if (pairIndex < servicePairs.length) {
      print("Category selected: $categoryName (ID: $categoryId)");

      servicePairs[pairIndex].selectedCategoryId = categoryId;
      servicePairs[pairIndex].serviceController.text = categoryName;
      servicePairs[pairIndex].selectedSubCategoryId = null;
      servicePairs[pairIndex].serviceTypeController.clear();

      // Fetch subcategories for the selected category
      await fetchSubCategories(categoryId);
      update();
    }
  }

  void onSubCategorySelected(
      int pairIndex,
      String subCategoryId,
      String subCategoryName,
      ) {
    if (pairIndex < servicePairs.length) {
      print("Subcategory selected: $subCategoryName (ID: $subCategoryId)");

      servicePairs[pairIndex].selectedSubCategoryId = subCategoryId;
      servicePairs[pairIndex].serviceTypeController.text = subCategoryName;
      update();
    }
  }

  void selectFromDropdown(TextEditingController controller, String value) {
    controller.text = value;
    update();
  }

  // ----------------- Image Upload -----------------
  Future<void> handleImageUpload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) profileImage.value = File(picked.path);
  }

  Future<void> handleWorkPhotosUpload() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked != null) uploadedImages.addAll(picked.map((e) => e.path));
  }

  void removeWorkPhoto(int index) {
    uploadedImages.removeAt(index);
  }

  // ----------------- Languages -----------------
  void toggleLanguageSelection(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
  }

  bool isLanguageSelected(String language) {
    return selectedLanguages.contains(language);
  }

  // ----------------- Slider -----------------
  void updateServiceDistance(double value) {
    serviceDistance.value = value;
  }

  // ----------------- Privacy -----------------
  void togglePrivacyAcceptance() {
    isPrivacyAccepted.value = !isPrivacyAccepted.value;
  }

  // ----------------- Validation -----------------
  bool validateForm() {
    if (aboutMeController.text.isEmpty) {
      Get.snackbar("Error", "About Me is required");
      return false;
    }
    if (locationController.text.isEmpty) {
      Get.snackbar("Error", "Primary Location is required");
      return false;
    }
    if (latitude == 0.0 || longitude == 0.0) {
      Get.snackbar(
        "Error",
        "Location coordinates not available. Please enable GPS.",
      );
      return false;
    }
    if (!isPrivacyAccepted.value) {
      Get.snackbar("Error", "Please accept Privacy & Terms");
      return false;
    }
    if (servicePairs.any(
          (pair) =>
      pair.selectedCategoryId == null ||
          pair.selectedSubCategoryId == null ||
          pair.priceController.text.isEmpty,
    )) {
      Get.snackbar("Error", "Please fill all service details");
      return false;
    }
    return true;
  }

  // ----------------- Post Profile -----------------
  Future<void> confirmProfile() async {
    if (!validateForm()) return;
    await _postProviderProfile();
  }

  Future<void> _postProviderProfile() async {
    try {
      // Prepare data object
      Map<String, dynamic> dataObj = {
        "aboutMe": aboutMeController.text.trim(),
        "serviceLanguage": selectedLanguages.toList(),
        "primaryLocation": locationController.text.trim(),
        "location": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "serviceDistance": serviceDistance.value,
        "pricePerHour":
        double.tryParse(pricePerHourController.text.trim()) ?? 0.0,
        "isRead": isPrivacyAccepted.value,
      };

      // Prepare services array
      List<Map<String, dynamic>> servicesArray =
      servicePairs.map((pair) {
        return {
          "category": pair.selectedCategoryId ?? "",
          "subCategory": pair.selectedSubCategoryId ?? "",
          "price": double.tryParse(pair.priceController.text.trim()) ?? 0.0,
        };
      }).toList();

      List files = [
        for (var image in uploadedImages)
          {"name": "serviceImages", "image": image},
      ];

      final response = await ApiService.multipartImage(
        ApiEndPoint.provider,
        files: files,
        body: {
          "data": jsonEncode(dataObj),
          'services': jsonEncode(servicesArray),
        },
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Profile uploaded successfully!",
          backgroundColor: Colors.green[100],
        );
        await updateProfileImage();
        Get.offAllNamed(AppRoutes.homeNav);
      } else {
        Get.snackbar(
          "Error",
          response.message,
          backgroundColor: Colors.red[100],
          duration: const Duration(seconds: 4),
          maxWidth: 400,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send profile: $e",
        backgroundColor: Colors.red[100],
      );
      print("Error details: $e");
    }
  }

  // Custom method to handle FormData with multiple images
  Future<ApiResponseModel> _makeMultipartRequest(
      String url,
      FormData formData,
      Map<String, String> headers,
      ) async {
    try {
      Dio dio = Dio();

      // Add interceptor for base URL and default settings
      dio.options.baseUrl = ApiEndPoint.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.sendTimeout = const Duration(seconds: 30);

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {...headers, "Content-Type": "multipart/form-data"},
        ),
      );

      if (response.statusCode == 201) {
        return ApiResponseModel(200, response.data);
      }
      return ApiResponseModel(response.statusCode, response.data);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.badResponse) {
        return ApiResponseModel(
          error.response?.statusCode,
          error.response?.data,
        );
      }
      return ApiResponseModel(500, {"message": "Request failed"});
    } catch (e) {
      return ApiResponseModel(500, {"message": "Unknown error occurred"});
    }
  }
}
*/
