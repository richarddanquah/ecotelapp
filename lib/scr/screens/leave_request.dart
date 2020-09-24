import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ecotelunfiedapp/scr/screens/addleave.dart';
import 'package:ecotelunfiedapp/scr/screens/editleave.dart';
import 'package:ecotelunfiedapp/scr/screens/home.dart';
import '../../constants.dart';
import '../../user_shared_pref.dart';
import '../../date_utils.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';

class LeaveRequest extends StatefulWidget {
  @override
  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  Constants _constants = Constants();
  DateUtils _dateUtils = DateUtils();
  List leaveData = List();
  UserSharedPref _userSharedPref = new UserSharedPref();
  var userId;
  var token;
  ProgressDialog _progress = ProgressDialog();

  Future<void> getUserToken() async {
    _userSharedPref.getUserToken().then((tokens) {
      token = tokens;
      _userSharedPref.getUserId().then((ids) {
        userId = ids;
        fetchLeave(ids);
      });
    });
  }

  @override
  void initState() {
    setState(() {
      getUserToken();
    });

    super.initState();
  }

  Future fetchLeave(String id) async {
    _progress.showProgressDialog(context,
        textToBeDisplayed: 'loading leave...');

    var url = '${_constants.apiUrl}/api/app_leave_log';

    var response = await http.post(Uri.parse(url),
        body: {'user_id': id.toString()}).timeout(Duration(seconds: 60));

    //debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      setState(() {
        leaveData = dataConvertedToJSON['data'];
      });
    } else {
      debugPrint('error');
    }

    _progress.dismissProgressDialog(context);
    return 'success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Employee's Leave"),
          backgroundColor: Color(0xff2AB351),
          actions: <Widget>[
            Container(
              width: 45,
              height: 35,
              margin: const EdgeInsets.fromLTRB(0, 3, 15, 3),
              child: IconButton(
                icon: Icon(Icons.add_circle),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => AddLeave())));
                  _progress.showProgressDialog(context,
                      textToBeDisplayed: 'loading leave types...');
                },
              ),
            )
          ],
        ),
        extendBody: true,
        body: leaveData.length == 0
            ? emptyLabelWidget()
            : notEmptyLabelWidget(leaveData));
  }

  Widget emptyLabelWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error, color: Color(0xff2AB351), size: 50.0),
          Text(
            'No Leave found!',
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
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
                              width: 15.0,
                              height: 25.0,
                              color: Colors.white,
                              child: Text(
                                '${index + 1}.',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 2.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'LEAVE TYPE:   ${leaveData[index]['leave']['leave_type']}' ==
                                          'null'
                                      ? 'No leave type'
                                      : 'LEAVE TYPE:   ${leaveData[index]['leave']['leave_type']}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'START DATE:   ${leaveData[index]['from_date']}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : 'START DATE:   ${_dateUtils.dateConvert(DateTime.parse(leaveData[index]['from_date'].toString()))}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'END DATE:   ${leaveData[index]['to_date']}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : 'END DATE:   ${_dateUtils.dateConvert(DateTime.parse(leaveData[index]['to_date'].toString()))}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'LEAVE DAYS:   ${leaveData[index]['employee_leave_days'].toString()}' ==
                                          'null'
                                      ? 'Date Not Available'
                                      : 'LEAVE DAYS:   ${leaveData[index]['employee_leave_days'].toString()}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'RELIEVER:   ${leaveData[index]['reliever'].toString()}' ==
                                          'null'
                                      ? 'Date Not Available'
                                      : 'RELIEVER:   ${leaveData[index]['reliever'].toString()}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  'STATUS:   ${leaveData[index]['status']}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : 'STATUS:   ${leaveData[index]['status']}',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            leaveData[index]['status'] == 'pending'
                                ? Container(
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.green,
                                      onPressed: () {
                                        _progress.showProgressDialog(context,
                                            textToBeDisplayed:
                                                'loading leave types...');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    EditLeave(
                                                        text1: leaveData[index]
                                                                ['leave']
                                                            ['leave_type'],
                                                        text2: leaveData[index]
                                                            ['from_date'],
                                                        text3: leaveData[index]
                                                            ['to_date'],
                                                        text4: leaveData[index]
                                                            ['reason'],
                                                        leaveId:
                                                            leaveData[index]
                                                                ['id']))));
                                      },
                                    ),
                                  )
                                : Container(),
                            SizedBox(width: 4.0),
                            leaveData[index]['status'] == 'pending'
                                ? Container(
                                    child: IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'ALERT',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.0),
                                            ),
                                            content: Wrap(
                                              children: <Widget>[
                                                Container(
                                                    child: Center(
                                                        child: Text(
                                                  'Are you sure you want to delete leave request?',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )))
                                              ],
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('No',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  userDeleteRequest(
                                                          leaveData[index]
                                                              ['id'])
                                                      .then((value) {
                                                    if (value) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  ((context) =>
                                                                      Home())));
                                                    } else {
                                                      //error

                                                    }
                                                  });
                                                },
                                                child: Text('Yes',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
    );
  }

  Future<bool> userDeleteRequest(int ids) async {
    var url = '${_constants.apiUrl}/api/app_leave_delete';
    debugPrint('request ids: $ids');

    var response = await http.post(Uri.parse(url),
        body: {'id': ids.toString()}).timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      return true;
    } else {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }
}
