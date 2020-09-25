import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../user_shared_pref.dart';
import '../commons.dart';
import 'home.dart';
//import 'package:http/io_client.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Constants _constants = Constants();
  ProgressDialog pr;
  bool _isLoading = false;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserSharedPref _userSharedPref = new UserSharedPref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/uni.png",
                  width: 150,
                  height: 240,
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "UserName",
                            icon: Icon(Icons.person)),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your UserName';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            icon: Icon(Icons.lock)),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your Password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : Color(0xff2AB351),
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 4, right: 4),
                  child: InkWell(
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        try {
                          await validate((userNameController.text).trim(),
                              (passwordController.text).trim(), context);
                        } catch (error) {
                          Fluttertoast.showToast(
                              msg: error,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "error, check your internet/data",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _isLoading ? "LogIn..." : "LogIn",
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
      ),
    );
  }

  // Validate user input
  Future validate(
      String username, String password, BuildContext context) async {
    debugPrint("username: $username");
    debugPrint("password: $password");

    setState(() {
      _isLoading = true;
    });

    bool trustSelfSigned = true;
//    HttpClient httpClient = new HttpClient()
//      ..badCertificateCallback =
//          ((X509Certificate cert, String host, int port) => trustSelfSigned);
//    IOClient ioClient = new IOClient(httpClient);

    //make https request to api
    var response = await http.post(Uri.parse(_constants.loginUrl),
        body: {'username': username, 'password': password});

    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      var data = dataConvertedToJSON['data']['user_data'];
      var token = dataConvertedToJSON['data']['access_token'];

      debugPrint(data['photo']);

      _userSharedPref.setUserFullName(data['full_name']);
      _userSharedPref.setUserName(data['username']);
      _userSharedPref.setUserEmail(data['email']);
      _userSharedPref.setUserId(data['id'].toString());
      _userSharedPref.setUserPhone(data['phone_number']);
      _userSharedPref.setUserToken(token);
      _userSharedPref.setUserPhoto(data['photo']);
      _userSharedPref
          .setUserCompanyBranch(data['company_branch_id'].toString());
      _userSharedPref.setUserGender(data['gender']);
      _userSharedPref.setUserAuth('true');

      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => Home())));
    } else if (response.statusCode == 401) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Cannot Login kindly check your internet/data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
