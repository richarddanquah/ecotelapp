import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:ecotelunfiedapp/scr/screens/login.dart';
import 'package:ecotelunfiedapp/scr/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import '../../constants.dart';
import '../../user_shared_pref.dart';
//import 'package:http/io_client.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  UserSharedPref _userSharedPref = new UserSharedPref();
  Constants _constants = Constants();
  String token;
  String mId;

  Future<void> getUserDetails() async {
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
  }

  @override
  void initState() {
    setState(() {
      getUserDetails();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Settings"),
        backgroundColor: Color(0xff2AB351),
      ),
      body: Builder(
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) => Profile())));
                  },
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      color: Color(0xff2AB351),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: PlatformWidget(
                    android: (_) => Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    ios: (_) => Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/privacypolicy');
                  },
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xff2AB351),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: PlatformWidget(
                    android: (_) => Icon(
                      Icons.business_center,
                      color: Colors.black,
                    ),
                    ios: (_) => Icon(
                      Icons.business_center,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/termscondition');
                  },
                  title: Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: Color(0xff2AB351),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: PlatformWidget(
                    android: (_) => Icon(
                      Icons.business,
                      color: Colors.black,
                    ),
                    ios: (_) => Icon(
                      Icons.business,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
                ListTile(
                  title: Text(
                    'version 1.0',
                    style: TextStyle(
                      color: Color(0xff2AB351),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: PlatformWidget(
                    android: (_) => Icon(
                      Icons.view_stream,
                      color: Colors.black,
                    ),
                    ios: (_) => Icon(
                      Icons.view_stream,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
                ListTile(
                  title: Text(
                    'Log me out',
                    style: TextStyle(
                      color: Color(0xff2AB351),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: PlatformWidget(
                    android: (_) => Icon(
                      Icons.screen_lock_portrait,
                      color: Colors.black,
                    ),
                    ios: (_) => Icon(
                      Icons.screen_lock_portrait,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'ALERT',
                          style: TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        content: Wrap(
                          children: <Widget>[
                            Container(
                                child: Center(
                                    child: Text(
                              'Are you sure you want to Log out?',
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
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          FlatButton(
                            onPressed: () {
                              userLogout().then((value) {
                                if (value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => Login())));
                                } else {
                                  //error

                                }
                              });
                            },
                            child: Text('Yes',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> userLogout() async {
//    bool trustSelfSigned = true;
//    HttpClient httpClient = new HttpClient()
//      ..badCertificateCallback =
//          ((X509Certificate cert, String host, int port) => trustSelfSigned);
//    IOClient ioClient = new IOClient(httpClient);

    var url = '${_constants.apiUrl}/api/logout';
    var toking = this.token;

    var response = await http.post(Uri.encodeFull(url), headers: {
      'Authorization': 'Bearer $toking'
    }).timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      _userSharedPref.removeSavedDetails();

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
