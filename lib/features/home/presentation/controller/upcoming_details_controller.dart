import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_controller.dart';
import '../../../../services/api/api_service.dart';

class UpcomingViewDetailsController extends GetxController {
  // Loading state - make it observable
  var isLoading = false.obs;

  // Booking details - store raw API data
  var bookingData = <String, dynamic>{}.obs;

  // Parsed fields for easy access - make them observable
  var bookingId = ''.obs;
  var userName = '';
  var userImage = '';
  var userLocation = '';
  var serviceName = ''.obs;
  var date = ''.obs;
  var time = ''.obs;
  var amount = ''.obs;
  String chatId = "";

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
        chatId=response.data['data'][0]['chatId']??"";
        // API returns data as a List, get the first item
        if (response.data['data'] is List && response.data['data'].isNotEmpty) {
          bookingData.value = response.data['data'][0];
          _parseBookingData();
        } else if (response.data['data'] is Map) {
          // In case API returns single object
          bookingData.value = response.data['data'];
          print("chat id 👌👌👌👌 $chatId");
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
      userName = bookingData['user']['name'] ?? 'User';
      userImage = bookingData['user']['image'] ?? '';
      userLocation = bookingData['user']['location'] ?? 'Location';
    }

    print("user name : 😍😍😍😍${userName}");

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
        List<String> timeSlots = [];

        for (var slot in bookingData['slots']) {
          DateTime startTime = DateTime.parse(slot['start']);
          int hour = startTime.hour;
          int minute = startTime.minute;
          String formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          timeSlots.add(formattedTime);
        }

        // Join all time slots with comma
        time.value = timeSlots.join(', ');
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

  // Contact Now - You can implement this based on your requirements
  Future<void> contactNow() async {
    try {
      // Implement your contact logic here
      // For example: open phone dialer, chat, etc.
      print('Contact Now clicked for booking: ${bookingData['_id']}');

      Get.snackbar(
        'Contact',
        'Contact feature will be implemented',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error contacting: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate contact',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}