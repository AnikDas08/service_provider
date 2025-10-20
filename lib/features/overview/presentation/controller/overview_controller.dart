import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';

import '../../../../utils/constants/app_string.dart';

class OverviewController extends GetxController {
  // Tabs
  var selectedTab = 0.obs;

  // Selected month and year from dropdown
  var selectedMonth = ''.obs;
  var selectedYear = ''.obs;

  // Calendar state
  var focusedDay = DateTime.now().obs;
  var selectedDay = Rxn<DateTime>();

  // Working day toggles - ALL FALSE by default
  var workingDays = <String, bool>{
    AppString.saturday_text: false,
    AppString.sunday_text: false,
    AppString.monday_text: false,
    AppString.tuesday_text: false,
    AppString.wednesday_text: false,
    AppString.thursday_text: false,
    AppString.friday_text: false,
  }.obs;

  // Working times for each day - Empty by default
  var workingTimes = <String, Map<String, String>>{
    AppString.monday_text: {"start": "", "end": ""},
    AppString.tuesday_text: {"start": "", "end": ""},
    AppString.wednesday_text: {"start": "", "end": ""},
    AppString.thursday_text: {"start": "", "end": ""},
    AppString.friday_text: {"start": "", "end": ""},
    AppString.saturday_text: {"start": "", "end": ""},
    AppString.sunday_text: {"start": "", "end": ""},
  }.obs;

  // Store fetched schedules
  var scheduleList = <Map<String, dynamic>>[].obs;

  // Statistics
  var successfulBooking = 0.obs;
  var canceledBooking = 0.obs;
  var totalMoneyEarned = 0.obs;

  // Loading state
  var isLoading = false.obs;

  // Time options for dropdown
  final List<String> timeOptions = [
    "00:00", "00:30", "01:00", "01:30", "02:00", "02:30",
    "03:00", "03:30", "04:00", "04:30", "05:00", "05:30",
    "06:00", "06:30", "07:00", "07:30", "08:00", "08:30",
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
    "15:00", "15:30", "16:00", "16:30", "17:00", "17:30",
    "18:00", "18:30", "19:00", "19:30", "20:00", "20:30",
    "21:00", "21:30", "22:00", "22:30", "23:00", "23:30",
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = DateTime.now();

    // Set initial month and year
    final now = DateTime.now();
    selectedMonth.value = _monthName(now.month);
    selectedYear.value = now.year.toString();

    // Initialize working times for all days
    workingTimes[AppString.monday_text] = {"start": "", "end": ""};
    workingTimes[AppString.tuesday_text] = {"start": "", "end": ""};
    workingTimes[AppString.wednesday_text] = {"start": "", "end": ""};
    workingTimes[AppString.thursday_text] = {"start": "", "end": ""};
    workingTimes[AppString.friday_text] = {"start": "", "end": ""};
    workingTimes[AppString.saturday_text] = {"start": "", "end": ""};
    workingTimes[AppString.sunday_text] = {"start": "", "end": ""};

    // Fetch schedules on init
    fetchSchedules();
  }

  // Tab change
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Day selected in TableCalendar
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    selectedDay.value = selectedDate;
    focusedDay.value = focusedDate;

    // Fetch schedules for the new selected week
    fetchSchedules();

    // Force refresh of ordered days list
    selectedDay.refresh();
  }

  // Change month from dropdown
  void changeMonth(String month) {
    selectedMonth.value = month;

    // Update focusedDay to first day of selected month, keeping the year
    int monthIndex = _monthIndex(month);
    focusedDay.value = DateTime(focusedDay.value.year, monthIndex, 1);
  }

  // Change year from dropdown
  void changeYear(String year) {
    selectedYear.value = year;

    // Update focusedDay to selected year, keeping the month
    focusedDay.value = DateTime(int.parse(year), focusedDay.value.month, 1);
  }

  // Top month name for display
  String get currentMonth => selectedMonth.value;

  // Get ordered list of days starting from selected date (ONLY NEXT 7 DAYS INCLUDING SELECTED)
  List<String> getOrderedDays() {
    // Get the selected date or use today
    DateTime baseDate = selectedDay.value ?? DateTime.now();

    // Day names in order matching DateTime.weekday
    // DateTime.weekday: Monday = 1, Tuesday = 2, ..., Sunday = 7
    const allDays = [
      AppString.monday_text,    // index 0 = Monday (weekday 1)
      AppString.tuesday_text,   // index 1 = Tuesday (weekday 2)
      AppString.wednesday_text, // index 2 = Wednesday (weekday 3)
      AppString.thursday_text,  // index 3 = Thursday (weekday 4)
      AppString.friday_text,    // index 4 = Friday (weekday 5)
      AppString.saturday_text,  // index 5 = Saturday (weekday 6)
      AppString.sunday_text,    // index 6 = Sunday (weekday 7)
    ];

    // Get the weekday of the selected date (1 = Monday, 7 = Sunday)
    // Convert to 0-6 index (0 = Monday, 6 = Sunday)
    int startIndex = baseDate.weekday - 1;

    // Create ordered list starting from selected day (next 7 days including today)
    List<String> orderedDays = [];
    for (int i = 0; i < 7; i++) {
      int dayIndex = (startIndex + i) % 7;
      orderedDays.add(allDays[dayIndex]);
    }

    return orderedDays;
  }

  // Get the actual date for a specific day name based on selected date
  DateTime getDateForDay(String dayName) {
    DateTime baseDate = selectedDay.value ?? DateTime.now();

    // Map day names to weekday numbers (1 = Monday, 7 = Sunday)
    const dayToWeekday = {
      AppString.monday_text: 1,
      AppString.tuesday_text: 2,
      AppString.wednesday_text: 3,
      AppString.thursday_text: 4,
      AppString.friday_text: 5,
      AppString.saturday_text: 6,
      AppString.sunday_text: 7,
    };

    int selectedWeekday = baseDate.weekday;
    int targetWeekday = dayToWeekday[dayName]!;

    // Calculate days to add (0-6) - ALWAYS FORWARD
    // This ensures we only get future dates from the selected date
    int daysToAdd = (targetWeekday - selectedWeekday + 7) % 7;

    return baseDate.add(Duration(days: daysToAdd));
  }

  // Replace your existing toggleDay method with this:

  // Replace your existing toggleDay method with this:

  void toggleDay(String day, bool value) async {
    // Check if there's a schedule for this day FIRST
    DateTime dayDate = getDateForDay(day);
    String dateStr = _formatDateForComparison(dayDate);

    // Find schedule for this specific date
    var schedule = scheduleList.firstWhereOrNull((s) {
      String scheduleDateStr = _formatDateForComparison(DateTime.parse(s['date']));
      return scheduleDateStr == dateStr;
    });

    // If schedule exists, hit the API to update isActive
    if (schedule != null && schedule['_id'] != null) {
      String scheduleId = schedule['_id'];

      // Update UI optimistically
      workingDays[day] = value;
      workingDays.refresh();

      try {
        print("🔄 Updating isActive for schedule $scheduleId to: $value");
        print("📍 Switch: ${value ? 'ON (Open)' : 'OFF (Closed)'}");

        final response = await ApiService.patch(
          "${ApiEndPoint.scheduleProvider}/$scheduleId",
          body: {
            "isActive": value,
          },
          header: {
            "Authorization": "Bearer ${LocalStorage.token}",
          },
        );

        if (response.statusCode == 200) {
          print("✅ Schedule isActive updated to: $value");
          Get.snackbar(
            'Success',
            value ? 'Schedule opened for $day' : 'Schedule closed for $day',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          // Revert UI on failure
          workingDays[day] = !value;
          workingDays.refresh();

          Get.snackbar(
            'Error',
            'Failed to update schedule',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // Revert UI on error
        workingDays[day] = !value;
        workingDays.refresh();

        print("❌ Error updating schedule: $e");
        Get.snackbar(
          'Error',
          'Failed to update schedule',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // No schedule exists - just update UI (no API call)
      workingDays[day] = value;
      workingDays.refresh();
      print("ℹ️ No schedule exists for $day - toggle is UI only");
    }
  }

// Also UPDATE your _applySchedulesToWeek method to use isActive from API:

  void _applySchedulesToWeek() {
    DateTime baseDate = selectedDay.value ?? DateTime.now();
    DateTime startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

    // Reset ALL working days and times BEFORE applying new schedules
    workingDays.updateAll((key, value) => false);
    workingTimes.updateAll((key, value) => {"start": "", "end": ""});

    print("🔍 Applying schedules for next 7 days starting from: ${_formatDateForComparison(startDate)}");

    // Get the NEXT 7 days starting from selected date
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateStr = _formatDateForComparison(currentDate);
      String dayName = _getDayNameFromWeekday(currentDate.weekday);

      // Find schedule for this EXACT date
      var schedule = scheduleList.firstWhereOrNull((s) {
        String scheduleDateStr = _formatDateForComparison(DateTime.parse(s['date']));
        return scheduleDateStr == dateStr;
      });

      if (schedule != null) {
        DateTime startTime = DateTime.parse(schedule['startTime']).toUtc();
        DateTime endTime = DateTime.parse(schedule['endTime']).toUtc();

        String startTimeStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
        String endTimeStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";

        // ✅ Set switch based on isActive from API
        bool isActive = schedule['isActive'] ?? false;
        workingDays[dayName] = isActive;

        workingTimes[dayName] = {
          "start": startTimeStr,
          "end": endTimeStr,
        };

        print("✅ Applied schedule for $dayName ($dateStr): $startTimeStr - $endTimeStr | isActive: $isActive");
      } else {
        workingDays[dayName] = false;
        workingTimes[dayName] = {"start": "", "end": ""};
        print("❌ No schedule for $dayName ($dateStr)");
      }
    }

    workingDays.refresh();
    workingTimes.refresh();

    print("🔄 Schedule application complete. Active days: ${workingDays.entries.where((e) => e.value).map((e) => e.key).toList()}");
  }

  String _formatDateForComparison(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }


  // Get formatted working time for display
  String getWorkingTime(String day) {
    if (workingTimes.containsKey(day)) {
      final times = workingTimes[day]!;
      String start = times['start'] ?? "";
      String end = times['end'] ?? "";

      // If both are empty, show "Select Schedule"
      if (start.isEmpty && end.isEmpty) {
        return "Select Schedule";
      }
      // If one is empty, still show "Select Schedule"
      if (start.isEmpty || end.isEmpty) {
        return "Select Schedule";
      }
      // Both are filled, show the time range
      return "$start - $end";
    }
    return "Select Schedule";
  }

  // Get start time for a specific day
  String getStartTime(String day) {
    final times = workingTimes[day]!;
    String start = times['start'] ?? "";
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['start'] ?? "07:00";
    }
    if (start=="") {
      return "Select start time";
    }
    return "07:00";
  }

  // Get end time for a specific day
  String getEndTime(String day) {
    final times = workingTimes[day]!;
    String end = times['end'] ?? "Select Start Time";
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['end'] ?? "22:00";
    }
    if (end.isEmpty) {
      return "Select end Time";
    }
    return "22:00";
  }

  // Update start time for a specific day
  void updateStartTime(String day, String startTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00", "end": "22:00"};
    }
    workingTimes[day]!['start'] = startTime;
    workingTimes.refresh();
  }

  // Update end time for a specific day
  void updateEndTime(String day, String endTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00", "end": "22:00"};
    }
    workingTimes[day]!['end'] = endTime;
    workingTimes.refresh();
  }

  // Update working time for a specific day
  void updateWorkingTime(String day, String startTime, String endTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {};
    }
    workingTimes[day]!['start'] = startTime;
    workingTimes[day]!['end'] = endTime;
    workingTimes.refresh();
  }

  // Show start time picker
  void showStartTimePicker(String day) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppString.start_time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.minPositive,
          height: 300,
          child: ListView.builder(
            itemCount: timeOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(timeOptions[index]),
                onTap: () {
                  updateStartTime(day, timeOptions[index]);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Show end time picker
  void showEndTimePicker(String day) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppString.end_time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.minPositive,
          height: 300,
          child: ListView.builder(
            itemCount: timeOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(timeOptions[index]),
                onTap: () {
                  updateEndTime(day, timeOptions[index]);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Fetch schedules from API - FETCHES FOR NEXT 7 DAYS FROM SELECTED DATE
  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;

      // Get the selected date or use today
      DateTime baseDate = selectedDay.value ?? DateTime.now();

      // Normalize to start of day
      DateTime startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

      // Format start date in UTC ISO format
      DateTime startDateUtc = DateTime.utc(startDate.year, startDate.month, startDate.day);
      String formattedDate = startDateUtc.toIso8601String();

      // Build URL with date query parameter
      String url = "${ApiEndPoint.scheduleProvider}?date=$formattedDate";

      print("📥 Fetching schedules starting from date: $formattedDate");
      print("🔗 URL: $url");

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          scheduleList.value = List<Map<String, dynamic>>.from(data['data']);

          print("✅ Fetched ${scheduleList.length} schedules");

          // Apply schedules to the next 7 days from selected date
          _applySchedulesToWeek();
        }
      } else {
        print("⚠️ Failed to fetch schedules. Status: ${response.statusCode}");
        // Reset UI when no schedules found
        _resetScheduleUI();
      }

    } catch (e) {
      print("❌ Error fetching schedules: $e");
      _resetScheduleUI();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset schedule UI when no data
  void _resetScheduleUI() {
    workingDays.updateAll((key, value) => false);
    workingTimes.updateAll((key, value) => {"start": "", "end": ""});
    workingDays.refresh();
    workingTimes.refresh();
  }


  // Helper: Format date for comparison (YYYY-MM-DD)


  // Helper: Get day name from weekday number
  String _getDayNameFromWeekday(int weekday) {
    const dayNames = {
      1: AppString.monday_text,
      2: AppString.tuesday_text,
      3: AppString.wednesday_text,
      4: AppString.thursday_text,
      5: AppString.friday_text,
      6: AppString.saturday_text,
      7: AppString.sunday_text,
    };
    return dayNames[weekday]!;
  }

  // Create Schedule API Call - WITH CORRECT DATE FOR EACH DAY
  Future<void> createSchedule(String day) async {
    // Validate that times are selected
    if (!workingTimes.containsKey(day)) {
      Get.snackbar(
        'Error',
        'Please select working times first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String startTime = workingTimes[day]!['start'] ?? "";
    String endTime = workingTimes[day]!['end'] ?? "";

    if (startTime.isEmpty || endTime.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select both start and end time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // GET THE CORRECT DATE FOR THIS SPECIFIC DAY (always in the future from selected date)
    DateTime scheduleDate = getDateForDay(day);

    // Parse time strings (HH:mm format)
    List<String> startParts = startTime.split(':');
    List<String> endParts = endTime.split(':');

    // Create DateTime objects in UTC directly to avoid timezone conversion issues
    DateTime startDateTime = DateTime.utc(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    DateTime endDateTime = DateTime.utc(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    // Prepare API body
    Map<String, dynamic> body = {
      "date": DateTime.utc(scheduleDate.year, scheduleDate.month, scheduleDate.day).toIso8601String(),
      "startTime": startDateTime.toIso8601String(),
      "endTime": endDateTime.toIso8601String(),
      "duration": 60,
    };

    try {
      isLoading.value = true;

      print("📅 Creating schedule for $day on date: ${scheduleDate.toString().split(' ')[0]}");
      print("⏰ Time: $startTime - $endTime");

      final response = await ApiService.post(
        ApiEndPoint.scheduleProvider,
        body: body,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if(response.statusCode == 200) {
        print("✅ Schedule created successfully!");
        Get.snackbar(
          'Success',
          'Schedule created for $day on ${scheduleDate.toString().split(' ')[0]}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh schedules after creating
        await fetchSchedules();

        workingTimes.refresh();
      } else {
        Get.snackbar(
          'Error',
          'Failed to create schedule. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar(
        'Error',
        'Failed to create schedule: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper: month number → month name
  String _monthName(int month) {
    const months = [
      AppString.january_text, AppString.february_text, AppString.march_text, AppString.april_text, AppString.may_text,
      AppString.june_text, AppString.july_text, AppString.august_text, AppString.september_text, AppString.october_text, AppString.november_text, AppString.december_text
    ];
    return months[month - 1];
  }

  // Helper: month name → month number
  int _monthIndex(String month) {
    const months = [
      AppString.january_text, AppString.february_text, AppString.march_text, AppString.april_text, AppString.may_text,
      AppString.june_text, AppString.july_text, AppString.august_text, AppString.september_text,
      AppString.october_text, AppString.november_text, AppString.december_text
    ];
    return months.indexOf(month) + 1;
  }
}