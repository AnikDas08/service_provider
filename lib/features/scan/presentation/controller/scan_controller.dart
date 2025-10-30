import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../widgets/qr_dialog_screen.dart';

class QRScannerController extends GetxController {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  var isFlashOn = false.obs;
  var isScanning = true.obs;
  var scannedData = ''.obs;
  var selectedRating = 0.obs;
  var isProcessing = false.obs; // Add loading state

  TextEditingController feedbackController = TextEditingController();
  TextEditingController barController = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
    feedbackController.dispose();
    barController.dispose();
    super.dispose();
  }

  void setRating(int rating) {
    selectedRating.value = rating;
  }

  void submitFeedback() {
    print('Rating: ${selectedRating.value}');
    print('Feedback: ${feedbackController.text}');

    Get.back();

    selectedRating.value = 0;
    feedbackController.clear();
  }

  Future<void> onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isScanning.value && scanData.code != null && !isProcessing.value) {
        await processScannedCode(scanData.code!);
      }
    });
  }

  // Process scanned QR code or manual ID
  Future<void> processScannedCode(String code) async {
    if (isProcessing.value) return;

    isProcessing.value = true;
    isScanning.value = false;
    scannedData.value = code;

    // Vibrate on scan
    HapticFeedback.lightImpact();

    try {
      final response = await ApiService.patch(
        ApiEndPoint.completeOrder + code,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        // Only show dialog on success
        showSuccessDialog();
      } else {
        Get.snackbar(
          "Failed",
          "Order Complete Failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Resume scanning after failure
        resumeScanning();
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Resume scanning after error
      resumeScanning();
    } finally {
      isProcessing.value = false;
    }
  }

  // Handle manual ID confirmation from TextField
  Future<void> confirmManualId() async {
    String userId = barController.text.trim();

    if (userId.isEmpty) {
      Get.snackbar(
        "Empty Field",
        "Please enter a User ID",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Process the manual ID same as scanned code
    await processScannedCode(userId);

    // Clear the text field after processing
    if (isProcessing.value == false) {
      barController.clear();
    }
  }

  void showSuccessDialog() {
    showQrDialog();
  }

  void toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      isFlashOn.value = !isFlashOn.value;
    }
  }

  void resumeScanning() {
    isScanning.value = true;
    isProcessing.value = false;
    controller?.resumeCamera();
  }

  void pauseScanning() {
    isScanning.value = false;
    controller?.pauseCamera();
  }

  void scanFromGallery() {
    print('Scan from gallery functionality');
  }
}