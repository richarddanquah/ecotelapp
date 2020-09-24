import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:ecotelunfiedapp/scr/screens/attendance_history.dart';
import 'package:ecotelunfiedapp/scr/screens/clock_in_out.dart';
import 'package:ecotelunfiedapp/scr/screens/leave_request.dart';
import 'package:ecotelunfiedapp/scr/screens/payslip.dart';
import 'package:ecotelunfiedapp/scr/screens/profile.dart';
import 'package:ecotelunfiedapp/scr/screens/setting.dart';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';

import '../commons.dart';

class GridDashboard extends StatelessWidget {
  Items item1 = new Items(title: "ClockIn/Out", img: "images/clocks.png");

  Items item2 = new Items(title: "Attendance Logs", img: "images/logs.png");

  Items item3 = new Items(title: "Payroll", img: "images/payslip.png");

  Items item4 = new Items(title: "Request Leave", img: "images/leave.png");

  Items item5 = new Items(title: "Profile", img: "images/profile.png");

  Items item6 = new Items(title: "Settings", img: "images/settings.png");

  ProgressDialog _progress = ProgressDialog();

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2, item3, item4, item5, item6];
    var color = 0xff2AB351;
    return Flexible(
        child: GridView.count(
      childAspectRatio: 1.3,
      padding: EdgeInsets.only(left: 10, right: 10),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: myList.map((data) {
        return GestureDetector(
          onTap: () {
            var index = myList.indexOf(data);
            debugPrint("index: $index");
            if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => AttendanceHistory())));
            } else if (index == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => Profile())));
            } else if (index == 5) {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => Setting())));
            } else if (index == 0) {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => ClockInOut())));
              _progress.showProgressDialog(context,
                  textToBeDisplayed: 'loading your status...');
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => PaySlip())));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => LeaveRequest())));
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: Color(color), borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  data.img,
                  width: 50,
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  data.title,
                  style: TextStyle(
                    color: white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }
}

class Items {
  String title;
  String img;
  Items({this.title, this.img});
}
