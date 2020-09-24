import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ecotelunfiedapp/scr/screens/home.dart';
import 'package:ecotelunfiedapp/scr/screens/leave_request.dart';
import '../../constants.dart';
import '../../user_shared_pref.dart';
import '../../date_utils.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import '../commons.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EditLeave extends StatefulWidget {
  String text1;
  String text2;
  String text3;
  String text4;
  String text5;
  int leaveId;
  EditLeave(
      {Key key,
      @required this.text1,
      @required this.text2,
      @required this.text3,
      @required this.text4,
      @required this.text5,
      @required this.leaveId})
      : super(key: key);

  @override
  _EditLeaveState createState() =>
      _EditLeaveState(text1, text2, text3, text4, text5, leaveId);
}

class _EditLeaveState extends State<EditLeave> {
  String text1;
  String text2;
  String text3;
  String text4;
  String text5;
  int leaveId;
  _EditLeaveState(
      this.text1, this.text2, this.text3, this.text4, this.text5, this.leaveId);

  final _formKey = GlobalKey<FormState>();
  Constants _constants = Constants();
  List<dynamic> leaveTypes = <dynamic>[];
  List<dynamic> relieverUsers = <dynamic>[];
  String uType;
  String selectedValue;
  final typesSelected = TextEditingController();

  var uImage;
  String mId;
  String uName;
  String token;
  String contact;
  bool _isLoading = false;

  UserSharedPref _userSharedPref = new UserSharedPref();
  DateTime selectedDate = DateTime.now();
  DateTime endSelectDate = DateTime.now();

  TextEditingController reasonController = TextEditingController();

  Future _endSelectDated(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: endSelectDate,
        firstDate: selectedDate,
        lastDate: DateTime(2030, 8),
        builder: (BuildContext contact, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColorDark: Theme.of(context).scaffoldBackgroundColor,
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              secondaryHeaderColor: Colors.green,
              primaryColor: Colors.green,
              accentColor: Colors.green,
            ),
            child: child,
          );
        });
    if (picked != null && picked != endSelectDate)
      setState(() {
        endSelectDate = picked;
        print(endSelectDate);
      });
  }

  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1700, 8),
        lastDate: DateTime(2030, 8),
        builder: (BuildContext contact, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColorDark: Theme.of(context).scaffoldBackgroundColor,
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              secondaryHeaderColor: Colors.green,
              primaryColor: Colors.green,
              accentColor: Colors.green,
            ),
            child: child,
          );
        });
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
      });
  }

  Future<void> getUserDetails() async {
    _userSharedPref.getUserPhoto().then((img) {
      setState(() {
        uImage = img;
      });

      _userSharedPref.getUserName().then((name) {
        setState(() {
          uName = name;
          //usernameController = TextEditingController(text: name);
        });

        _userSharedPref.getUserPhone().then((phone) {
          setState(() {
            contact = phone;
            //userContactController = TextEditingController(text: phone);
          });

          _userSharedPref.getUserId().then((ids) {
            setState(() {
              mId = ids;
            });

            _userSharedPref.getUserToken().then((tokens) {
              setState(() {
                token = tokens;
              });
            });
          });
        });
      });
    });
  }

  Future fetchLeaveTypes() async {
    var url = '${_constants.apiUrl}/api/app_leave_types';

    var response = await http
        .post(Uri.parse(url), body: {}).timeout(Duration(seconds: 60));

    //debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body types: ${response.body}');
    if (response.statusCode == 200) {
      //var dataConvertedToJSON = json.decode(response.body);
      Map body = json.decode(response.body);
      setState(() {
        leaveTypes = body['data'];
      });
    } else {
      debugPrint('error');
    }

    return 'success';
  }

  Future fetchUsers() async {
    var url = '${_constants.apiUrl}/api/app_relievers';
    var response = await http
        .post(Uri.parse(url), body: {}).timeout(Duration(seconds: 60));
    debugPrint('Response body users: ${response.body}');
    if (response.statusCode == 200) {
      Map body = json.decode(response.body);

      //debugPrint(body['data']);

      setState(() {
        relieverUsers = body['data'];
      });
    } else {
      debugPrint('error');
    }
    return 'success';
  }

  @override
  void initState() {
    setState(() {
      getUserDetails();
      fetchLeaveTypes();
      fetchUsers();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _formateDate = new DateFormat.yMMMd().format(selectedDate);
    String _endformateDate = new DateFormat.yMMMd().format(endSelectDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Edit Leave"),
        backgroundColor: Color(0xff2AB351),
      ),
      body: Builder(
        builder: (context) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16.0),
            curve: Curves.ease,
            child: ListView(
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Select Leave Type ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(15)),
                          child: DropdownButton(
                            value: text1,
                            items: leaveTypes
                                .map((code) => new DropdownMenuItem(
                                    value: code, child: new Text(code)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                text1 = value;
                                print(text1);
                              });
                            },
                            isExpanded: true,
                            underline: SizedBox(),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Select Leave Period ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Text("$_formateDate"),
                                  IconButton(
                                    icon: Icon(Icons.date_range),
                                    color: Colors.green,
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            Text(" -- "),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Text("$_endformateDate"),
                                  IconButton(
                                    icon: Icon(Icons.date_range),
                                    color: Colors.green,
                                    onPressed: () {
                                      _endSelectDated(context);
                                    },
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 35.0,
                        ),
                        Text(
                          "Select Reliever ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(15)),
                            child: SearchableDropdown.single(
                              items: relieverUsers
                                  .map((names) => new DropdownMenuItem(
                                      value: names, child: new Text(names)))
                                  .toList(),
                              value: text5,
                              searchHint: "Select reliever",
                              onChanged: (value) {
                                setState(() {
                                  text5 = value;
                                  print(text5);
                                });
                              },
                              isExpanded: true,
                            )),
                        SizedBox(
                          height: 35.0,
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            controller: reasonController,
                            maxLines: 6,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration.collapsed(
                                hintText: "Enter your leave reason"),
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Color(0xff2AB351),
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 4, right: 4),
                      child: InkWell(
                        onTap: () async {
                          if (_isLoading
                              ? null
                              : _formKey.currentState.validate()) {
                            await validate(
                                    text1,
                                    selectedDate.toString(),
                                    endSelectDate.toString(),
                                    (reasonController.text).trim(),
                                    text5,
                                    context)
                                .catchError((error) {
                              Fluttertoast.showToast(
                                  msg: "error",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _isLoading ? "Submiting..." : "Submit",
                              style: TextStyle(
                                color: white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future validate(String leaveTypes, String fromDate, String endDate,
      String reason, String selectedValues, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    var userId = this.mId;
    var ids = this.leaveId;
    debugPrint(userId);
    debugPrint(ids.toString());

    debugPrint('leavetypes $leaveTypes');
    debugPrint('fromdate $fromDate');
    debugPrint('enddate $endDate');
    debugPrint('reason $reason');
    debugPrint('Reliever $selectedValues');

    var url = '${_constants.apiUrl}/api/app_update_leaves';

    var response = await http.post(Uri.parse(url), body: {
      'id': ids.toString(),
      'leave_type': leaveTypes.toString(),
      'user_id': userId.toString(),
      'empleave_start_date': fromDate.toString(),
      'empleave_end_date': endDate.toString(),
      'reason': reason.toString(),
      'reliever': selectedValues.toString()
    }).timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => Home())));
    } else {
      debugPrint('error');

      Fluttertoast.showToast(
          msg: 'Leave request update failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        _isLoading = false;
      });
    }
  }
}
