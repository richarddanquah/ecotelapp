import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:ecotelunfiedapp/scr/commons.dart';
//import 'package:google_fonts/google_fonts.dart';

import '../../date_utils.dart';
import '../../user_shared_pref.dart';
import 'griddashboard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateUtils _dateUtils = DateUtils();
  UserSharedPref _userSharedPref = new UserSharedPref();
  var currentTime;
  Timer _timer;
  DateTime now;
  var userName;

  void getCurrentTimer(Timer timer) {
    var formatter = new DateFormat.jms("en_US");
    setState(() {
      now = DateTime.now();
      currentTime = formatter.format(now).toLowerCase();
    });
  }

  void getUserNames() async {
    _userSharedPref.getUserName().then((name) {
      setState(() {
        userName = name;
      });
    });
  }

//  void getConnectivityState() {
//    _streamSubscription =
//        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//      setState(() {
//        _connectionStatus = result.toString();
//        if (_connectionStatus == "ConnectivityResult.none") {
//          flushbarState = true;
//          flush = Flushbar<bool>(
//            icon: Icon(
//              Icons.info_outline,
//              color: Colors.white,
//            ),
//            padding: EdgeInsets.all(8.0),
//            borderRadius: 8.0,
//            message: 'Check your Internet Connection!',
//            flushbarPosition: FlushbarPosition.TOP,
//            flushbarStyle: FlushbarStyle.FLOATING,
//            reverseAnimationCurve: Curves.decelerate,
//            forwardAnimationCurve: Curves.elasticOut,
//            backgroundColor: Colors.red,
//          )..show(context);
//        } else {
//          if (flushbarState) {
//            flush.dismiss(true);
//          }
//        }
//      });
//    });
//  }

  @override
  initState() {
    setState(() {
      getUserNames();
      //getConnectivityState();
    });

    _timer = new Timer.periodic(const Duration(seconds: 1), getCurrentTimer);

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 70,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${_dateUtils.getGreetingOfDay()}",
                      style: TextStyle(
                        color: Color(0xff2AB351),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "$userName",
                      style: TextStyle(
                        color: Color(0xff2AB351),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "$currentTime",
                  style: TextStyle(
                    color: Color(0xff2AB351),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          GridDashboard(),
        ],
      ),
    );
  }
}
