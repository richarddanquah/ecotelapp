import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants.dart';
import '../../user_shared_pref.dart';
import '../commons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
//import 'package:http/io_client.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  Constants _constants = Constants();
  TextEditingController usernameController;
  TextEditingController userContactController;
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userPasswordConfirmController = TextEditingController();

  var uImage;
  String mId;
  String uName;
  String token;
  String contact;
  bool _isLoading = false;

  UserSharedPref _userSharedPref = new UserSharedPref();

  Future<void> getUserDetails() async {
    _userSharedPref.getUserPhoto().then((img) {
      setState(() {
        uImage = img;
      });

      _userSharedPref.getUserName().then((name) {
        setState(() {
          uName = name;
          usernameController = TextEditingController(text: name);
        });

        _userSharedPref.getUserPhone().then((phone) {
          setState(() {
            contact = phone;
            userContactController = TextEditingController(text: phone);
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
        title: Text("Edit Profile"),
        backgroundColor: Color(0xff2AB351),
      ),
      body: Builder(builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          curve: Curves.ease,
          child: ListView(
            children: <Widget>[
              Center(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xff2AB351), width: 2),
                      image: DecorationImage(
                          image: this.uImage == null
                              ? ExactAssetImage(
                                  "images/uni.png",
                                )
                              : NetworkImage(this.uImage),
                          fit: BoxFit.fill)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: TextFormField(
                            controller: usernameController,
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
                            controller: userContactController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "PhoneNumber",
                                icon: Icon(Icons.contacts)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your PhoneNumber';
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
                            controller: userPasswordController,
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: TextFormField(
                            controller: userPasswordConfirmController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            obscureText: true,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Confirmed Password",
                                icon: Icon(Icons.lock)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Confirmed Password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                        if (_isLoading
                            ? null
                            : _formKey.currentState.validate()) {
                          await validate(
                                  (usernameController.text).trim(),
                                  (userContactController.text).trim(),
                                  (userPasswordController.text).trim(),
                                  (userPasswordConfirmController.text).trim(),
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
                            _isLoading ? "Updating..." : "Update",
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
      }),
    );
  }

  // update user
  Future validate(String username, String phoneNumber, String password,
      String confirmedPassword, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    var names = this.uName;
    var ids = this.mId;
    var toking = this.token;

//    bool trustSelfSigned = true;
//    HttpClient httpClient = new HttpClient()
//      ..badCertificateCallback =
//          ((X509Certificate cert, String host, int port) => trustSelfSigned);
//    IOClient ioClient = new IOClient(httpClient);

    var url =
        '${_constants.apiUrl}/api/userInfo/$names/$password/$confirmedPassword/$ids';

    var response = await http.put(Uri.encodeFull(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $toking'
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
    } else if (response.statusCode == 500) {
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
    }
  }
}
