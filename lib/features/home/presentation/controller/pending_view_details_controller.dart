import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_controller.dart';
import '../../../../services/api/api_service.dart';

class PendingViewDetailsController extends GetxController {
  // Loading state - make it observable
  var isLoading = false.obs;

  // Booking details - store raw API data
  var bookingData = <String, dynamic>{}.obs;

  // Parsed fields for easy access - make them observable
  var bookingId = ''.obs;
  var userName = ''.obs;
  var userImage = ''.obs;
  var userLocation = ''.obs;
  var serviceName = ''.obs;
  var date = ''.obs;
  var time = ''.obs;
  var amount = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get booking ID from arguments
    if (Get.arguments != null && Get.arguments['bookingId'] != null) {
      String fullBookingId = Get.arguments['bookingId'];
      fetchBookingDetails(fullBookingId);
    }
  }

  // Fetch booking details from API
  Future<void> fetchBookingDetails(String id) async {
    isLoading.value = true;

    try {
      final response = await ApiService.get('booking/$id');

      if (response.statusCode == 200) {
        // API returns data as a List, get the first item
        if (response.data['data'] is List && response.data['data'].isNotEmpty) {
          bookingData.value = response.data['data'][0];
          _parseBookingData();
        } else if (response.data['data'] is Map) {
          // In case API returns single object
          bookingData.value = response.data['data'];
          _parseBookingData();
        }
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch booking details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Parse booking data from API response
  void _parseBookingData() {
    // User details
    if (bookingData['user'] != null && bookingData['user'] is Map) {
      userName.value = bookingData['user']['name'] ?? 'User';
      userImage.value = bookingData['user']['image'] ?? '';
      userLocation.value = bookingData['user']['location'] ?? 'Location';
    }

    print("user name : 😍😍😍😍${userName.value}");

    // Service name from category
    if (bookingData['services'] != null && bookingData['services'] is List) {
      List<String> categoryNames = [];
      for (var service in bookingData['services']) {
        if (service is Map && service['category'] != null && service['category'] is Map) {
          String? categoryName = service['category']['name'];
          if (categoryName != null && categoryName.isNotEmpty) {
            categoryNames.add(categoryName);
          }
        }
      }
      if (categoryNames.isNotEmpty) {
        serviceName.value = categoryNames.join(', ');
      } else {
        serviceName.value = 'Service';
      }
    } else {
      serviceName.value = 'Service';
    }

    // Parse date
    if (bookingData['date'] != null) {
      try {
        DateTime dateTime = DateTime.parse(bookingData['date']);
        date.value = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
      } catch (e) {
        date.value = '00.00.0000';
      }
    }

    // Parse time (start time) - 24 hour format
    if (bookingData['slots'] != null && bookingData['slots'].isNotEmpty) {
      try {
        DateTime startTime = DateTime.parse(bookingData['slots'][0]['start']);
        int hour = startTime.hour;
        int minute = startTime.minute;
        time.value = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } catch (e) {
        time.value = '10:00';
      }
    }

    // Amount
    amount.value = bookingData['amount']?.toString() ?? '0';

    // Booking ID (last 4 digits)
    if (bookingData['_id'] != null && bookingData['_id'].toString().length >= 4) {
      bookingId.value = bookingData['_id'].toString().substring(bookingData['_id'].toString().length - 4);
    }
  }

  // Confirm booking
  Future<void> confirmBooking() async {
    try {
      String fullBookingId = bookingData['_id'] ?? '';

      if (fullBookingId.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid booking ID',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Make PATCH API call to confirm booking
      final response = await ApiService.patch(
        'booking/$fullBookingId',
        body: {
          'status': 'confirmed', // or whatever status your API expects
        },
      );

      if (response.statusCode == 200) {
        print('Booking confirmed: $fullBookingId');


        Get.offAllNamed(AppRoutes.homeNav);
        Get.snackbar(
          'Success',
          'Booking confirmed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );


      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to confirm booking',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('Error confirming booking: $e');
      Get.snackbar(
        'Error',
        'Failed to confirm booking',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cancel booking
  Future<void> cancelBooking() async {
    try {
      String fullBookingId = bookingData['_id'] ?? '';

      if (fullBookingId.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid booking ID',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Make DELETE API call to cancel booking
      final response = await ApiService.delete('booking/$fullBookingId');

      if (response.statusCode == 200) {
        print('Booking cancelled: $fullBookingId');

        Get.find<HomeController>().fetchAllBookings();
        Get.offAllNamed(AppRoutes.homeNav);
        Get.snackbar(
          'Success',
          'Booking cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to cancel booking',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('Error cancelling booking: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel booking',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}