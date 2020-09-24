import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../date_utils.dart';
import '../../user_shared_pref.dart';
//import 'package:http/io_client.dart';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';

class ClockIn extends StatefulWidget {
  @override
  _ClockInState createState() => _ClockInState();
}

class _ClockInState extends State<ClockIn> {
  Constants _constants = Constants();
  DateUtils _dateUtils = DateUtils();
  List clockInData = List();
  IconData clockInDevice;
  UserSharedPref _userSharedPref = new UserSharedPref();
  var userId;
  var token;
  ProgressDialog _progress = ProgressDialog();

  Future<void> getUserToken() async {
    _userSharedPref.getUserToken().then((tokens) {
      token = tokens;
      _userSharedPref.getUserId().then((ids) {
        userId = ids;
        fetchClockIn(ids, tokens);
      });
    });
  }

  @override
  void initState() {
    setState(() {
      getUserToken();

      clockInDevice = Icons.error_outline;
    });

    super.initState();
  }

  Future fetchClockIn(String id, String toking) async {
    var url = '${_constants.apiUrl}/api/attendance/$id';

    _progress.showProgressDialog(context,
        textToBeDisplayed: 'loading clock in logs...');

    var response = await http.get(Uri.encodeFull(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $toking'
    }).timeout(Duration(seconds: 60));

    //debugPrint('Response status: ${response.statusCode}');
    //debugPrint('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      setState(() {
        clockInData = dataConvertedToJSON['data'];
      });
    } else {
      debugPrint('error');
    }

    return 'success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: clockInData.length == 0
            ? emptyLabelWidget()
            : notEmptyLabelWidget(clockInData));
  }

  Widget emptyLabelWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error, color: Color(0xff2AB351), size: 50.0),
          Text(
            'No ClockIn Logs found!',
            softWrap: true,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget notEmptyLabelWidget(clockInData) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: ListView.builder(
          itemCount: clockInData == null ? 0 : clockInData.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 55.0,
                              height: 55.0,
                              color: Colors.white,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.white,
                                child: Icon(
                                  Icons.phone_android,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${clockInData[index]['clock_in_location_name']}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : '${clockInData[index]['clock_in_location_name']}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${clockInData[index]['clock_in_time'].toString()}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : '${_dateUtils.dateConvert(DateTime.parse(clockInData[index]['clock_in_time'].toString()))}',
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Text(
                            '${clockInData[index]['clock_in_time'].toString()}' ==
                                    'null'
                                ? 'Data Not Available'
                                : '${_dateUtils.timeConvert(DateTime.parse(clockInData[index]['clock_in_time'].toString()))}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
    );
  }
}
