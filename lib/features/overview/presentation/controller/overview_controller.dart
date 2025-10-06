import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  // Working day toggles
  var workingDays = <String, bool>{
    AppString.saturday_text: false,
    AppString.sunday_text: false,
    AppString.monday_text: true,
    AppString.tuesday_text: false,
    AppString.wednesday_text: true,
    AppString.thursday_text: false,
    AppString.friday_text: false,
  }.obs;

  // Working times for each day
  var workingTimes = <String, Map<String, String>>{
    AppString.monday_text: {"start": "07:00", "end": "22:00"},
    AppString.tuesday_text: {"start": "07:00", "end": "22:00"},
    AppString.wednesday_text: {"start": "07:00", "end": "22:00"},
    AppString.thursday_text: {"start": "07:00", "end": "22:00"},
    AppString.friday_text: {"start": "07:00", "end": "22:00"},
    AppString.saturday_text: {"start": "07:00", "end": "22:00"},
    AppString.sunday_text: {"start": "07:00", "end": "22:00"},
  }.obs;

  // Statistics
  var successfulBooking = 50.obs;
  var canceledBooking = 16.obs;
  var totalMoneyEarned = 5000.obs;

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
  }

  // Tab change
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Day selected in TableCalendar
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    selectedDay.value = selectedDate;
    focusedDay.value = focusedDate;
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

  void toggleDay(String day, bool value) {
    workingDays[day] = value;
    // Force update the observable map
    workingDays.refresh();
  }

  // Get formatted working time for display
  String getWorkingTime(String day) {
    if (workingTimes.containsKey(day)) {
      final times = workingTimes[day]!;
      return "${times['start']} - ${times['end']}";
    }
    return "07:00 AM - 10:00 PM";
  }

  // Get start time for a specific day
  String getStartTime(String day) {
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['start'] ?? "Start Time";
    }
    return "Start Time";
  }

  // Get end time for a specific day
  String getEndTime(String day) {
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['end'] ?? "End Time";
    }
    return "End Time";
  }

  // Update start time for a specific day
  void updateStartTime(String day, String startTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00 AM", "end": "10:00 PM"};
    }
    workingTimes[day]!['start'] = startTime;
    workingTimes.refresh();
  }

  // Update end time for a specific day
  void updateEndTime(String day, String endTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00 AM", "end": "10:00 PM"};
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