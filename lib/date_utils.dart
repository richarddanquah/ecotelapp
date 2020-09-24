import 'dart:async';

import 'package:intl/intl.dart';

class DateUtils {
  String getGreetingOfDay() {
    var hourOfDay = DateTime.now().hour;
    if (hourOfDay >= 0 && hourOfDay < 12) {
      //morning
      return "Good Morning, ";
    } else if (hourOfDay >= 12 && hourOfDay < 17) {
      //afternoon
      return "Good Afternoon, ";
    } else if (hourOfDay >= 17 && hourOfDay < 24) {
      //evening

      return "Good Evening,";
    } else {
      //hello name
      return "Hello there, ";
    }
  }

  getCurrentTime() {
    var currentTime;
    Timer.periodic(Duration(seconds: 1), (timer) {
      var now = new DateTime.now();
      var formatter = new DateFormat.jms("en_US");
      currentTime = formatter.format(now).toUpperCase();
    });
    return currentTime;
  }

  String dateConvert(var mDate) {
    var formatter = new DateFormat.yMMMMd("en_US");
    return formatter.format(mDate);
  }

  String dateConvert2(var mDate) {
    var formatter = new DateFormat.yMMMM("en_US");
    return formatter.format(mDate);
  }

  String timeConvert(var mTime) {
    var formatter = new DateFormat.jm("en_US");
    return formatter.format(mTime);
  }
}
