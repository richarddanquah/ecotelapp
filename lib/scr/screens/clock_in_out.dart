import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'package:ecotelunfiedapp/scr/models/aws_rekognition_model.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../constants.dart';
import '../../user_shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

import 'package:custom_progress_dialog/custom_progress_dialog.dart';

import 'package:aws_ai/src/RekognitionHandler.dart';

class ClockInOut extends StatefulWidget {
  @override
  _ClockInOutState createState() => _ClockInOutState();
}

class _ClockInOutState extends State<ClockInOut> {
  //PermissionStatus _status;
  Position _position;
  StreamSubscription<Position> _streamSubscription;
  Address _address;

  final _formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  Constants _constants = Constants();

  var uImage;
  String mId;
  String uName;
  String token;
  String contact;
  String mStatus;
  String branch;
  String comment;
  bool _isLoading = false;
  File urlFiles;

  var isEnabled;
  File _image;

  UserSharedPref _userSharedPref = new UserSharedPref();
  ProgressDialog _progress = ProgressDialog();

  Location location = new Location();
  LocationData _locationData;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  Position position;

  Future getUserDetails() async {
    _userSharedPref.getUserPhoto().then((img) {
      uImage = img;
      //getImageUrl(uImage);

      _userSharedPref.getUserName().then((name) {
        uName = name;

        _userSharedPref.getUserPhone().then((phone) {
          contact = phone;

          _userSharedPref.getUserId().then((ids) {
            mId = ids;

            _userSharedPref.getUserToken().then((tokens) {
              token = tokens;

              _userSharedPref.getUserComment().then((comments) {
                comment = comments;

                _userSharedPref.getUserCompanyBranch().then((branching) {
                  branch = branching;
                  getClockStatus(ids, tokens);
                });
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
      extendBody: true,
      appBar: AppBar(
        elevation: 4,
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Clock In / Out",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.green,
        actions: <Widget>[],
        bottom: PreferredSize(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${this.mStatus}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: this.mStatus == 'clockIn'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: IgnorePointer(
        ignoring: this.isEnabled == true ? true : false,
        ignoringSemantics: this.isEnabled == true ? true : false,
        child: AvatarGlow(
          glowColor: Colors.amber,
          endRadius: 200.0,
          repeat: true,
          showTwoGlows: true,
          child: Material(
            elevation: 8,
            shape: CircleBorder(),
            child: InkWell(
              onTap: () async {
                if (!_isLoading) {
                  _progress.showProgressDialog(context,
                      textToBeDisplayed:
                          'Please wait checking your location...');

                  checkLocation().then((response) {
                    if (response == 200) {
                      _progress.dismissProgressDialog(context);
                      showAlertDialog(context);
                      setState(() {
                        _isLoading = true;
                      });
                    } else if (response == 401) {
                      _progress.dismissProgressDialog(context);
                      _commentDialog(context);
                      setState(() {
                        _isLoading = true;
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "location error!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  });
                }

                setState(() {
                  _isLoading = true;
                });
              },
              child: CircleAvatar(
                radius: 120,
                backgroundColor:
                    this.mStatus == 'clockIn' ? Colors.green : Colors.red,
                child:
                    Text(this.mStatus == 'clockIn' ? 'CLOCK IN' : 'CLOCK OUT',
                        style: TextStyle(
                          color: _isLoading ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ////// ClockInOut function ///////////////////////////

  Future getClockStatus(mId, token) async {
    var ids = this.mId;
    var toking = this.token;

    debugPrint(" ids is $ids");
    debugPrint(" toking is $toking");

    var url = '${_constants.apiUrl}/api/clockinStatus/$ids';
    debugPrint(" url is $url");

    var response = await http.get(Uri.encodeFull(url), headers: {
      'Authorization': 'Bearer $toking'
    }).timeout(Duration(seconds: 60));

    //debugPrint("----clock response is-------- $response");

    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      var mState = dataConvertedToJSON['data'];
      debugPrint('status of clock in and out.....................$mState');
      setState(() {
        this.mStatus = mState;
        debugPrint("status $mStatus");
      });
    } else {
      debugPrint("---------error--------");
      throw response.reasonPhrase;
    }
  }

  ////// ClockInOut function ///////////////////////////

//////////CHECK LOCATION //////////////////////////////////

  Future<int> checkLocation() async {
    debugPrint("Checking Location");

    var branchId = this.branch;

    debugPrint('branchId: $branchId');

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return 401;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return 401;
      }
    }
    _locationData = await location.getLocation();
    print("hello ${_locationData.latitude} ${_locationData.longitude}");
    var url = '${_constants.apiUrl}/api/check_user_location_app';
    debugPrint('url: $url');
    var response = await http.post(Uri.parse(url), body: {
      'branch_id': branchId.toUpperCase(),
      'lng': _locationData.latitude.toString(),
      'lat': _locationData.longitude.toString()
    });

    debugPrint('Check Location Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return 200;
    } else if (response.statusCode == 401) {
      return 401;
    }
  }

//// END OF CHECK LOCATION ////////////////////////////////

///// GET IMAGE //////////////////////////
  Future getImage() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = imageFile;
    });

    if (imageFile == null) {
      Fluttertoast.showToast(
          msg: 'Action Cancelled',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        _isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Please wait...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 80,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0);

      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      int rand = new Math.Random().nextInt(100000);
      Img.Image image = Img.decodeImage(_image.readAsBytesSync());
      Img.Image smallerImg = Img.copyResize(image, width: 500, height: 500);

      var compressedImg = new File('$path/image_$rand.jpg')
        ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));

      debugPrint('compressedImg path: $compressedImg');

      ///////// this part is not working /////////
      File file = new File('$path/images_$rand.jpg');
      http.Response response = await http.get(this.uImage);
      File profileImageFile = await file.writeAsBytes(response.bodyBytes);

//      print(file);
//      print(response.body);
//      print(response.bodyBytes);
      print(profileImageFile);
      print(this.uImage);
      /////////// this part is giving the error ////////

      /////////PROCESSING IMAGE/////////////
      process(compressedImg).then((response) {
        if (response.statusCode == 200) {
          var dataConvertedToJSON = json.decode(response.body);
          String data = dataConvertedToJSON['imageUrl'];
          var imageUrl = data.replaceAll("\\/", "");
          debugPrint("ImageUrl is $imageUrl");

          Fluttertoast.showToast(
              msg: 'Please wait...',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 80,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 14.0);

          //// SENDING IMAGE TO AMAZON FACIAL RECOGNITION/////////
          imageProcessor(profileImageFile, compressedImg).then((value) {
            Fluttertoast.showToast(
                msg: 'Please wait...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 80,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 14.0);

            debugPrint(
                '----------------aws labelArray----------------------------');
            //print(value);

            if (value) {
              Fluttertoast.showToast(
                  msg: 'Authenticated Successfully..',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              //sendAttendanceData();
              if (this.mStatus == 'clockIn') {
                sendAttendanceClockInData();
                setState(() {
                  _isLoading = true;
                });
              } else {
                sendAttendanceClockOutData();
                setState(() {
                  _isLoading = true;
                });
              }
            } else {
              Fluttertoast.showToast(
                  msg: 'Sorry, faces do not match!!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);

              setState(() {
                _isLoading = false;
              });
            }
          });

          ////// END OF AMAZON FACIAL RECOGNITION //////////////////
        } else {
          Fluttertoast.showToast(
              msg: 'Image verification from Rocksters failed. Contact Admin!!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

          setState(() {
            _isLoading = false;
          });
        }
      });
      //// END OF PROCESSING IMAGE ///////////
    }
  }

  ///// END GET IMAGE //////////////////////////

  //// PROCESS IMAGE //////////////////////////
  //upload file to server///

  Future<http.Response> process(File file) async {
    Fluttertoast.showToast(
        msg: 'Please wait...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 80,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0);

    var userId = this.mId;
    var toking = this.token;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    var url = '${_constants.apiUrl}/api/verify_image/$userId';
    debugPrint('image verify url: $url');
    debugPrint('image verify file: $file');

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $toking',
    };

    final multipartRequest = new http.MultipartRequest('POST', Uri.parse(url));
    multipartRequest.headers.addAll(headers);

    multipartRequest.files.add(
      await http.MultipartFile.fromPath('photo', file.path,
          filename: basename(file.path),
          contentType: new MediaType("image", "jpg")),
    );

    http.Response response =
        await http.Response.fromStream(await multipartRequest.send())
            .timeout(Duration(seconds: 120));

    debugPrint('Response status: ${response.statusCode}');

    return response;
  }

  ///// END OF PROCESS IMAGE /////////////////

  ////// IMAGE PROCESSOR //////////////////////

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getClockStatus(this.mId, this.token);
      debugPrint('on resumed');
    } else if (state == AppLifecycleState.inactive) {
      getClockStatus(this.mId, this.token);
      debugPrint('inactive');
    } else if (state == AppLifecycleState.paused) {
      getClockStatus(this.mId, this.token);
      debugPrint('paused');
    }
  }

  Future<bool> imageProcessor(var savedImg, var compressedImg) async {
    debugPrint('----------------aws----------------------------');
    debugPrint('----------------aws----------------------------');
    debugPrint('----------------aws----------------------------');

    //debugPrint(savedImg);

    Fluttertoast.showToast(
        msg: 'Please wait...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 80,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0);

    RekognitionHandler rekognition = new RekognitionHandler(
        _constants.apiKey, _constants.apiSecret, _constants.region);
    Future<String> labelsArray =
        rekognition.compareFaces(savedImg, compressedImg);

    String labels = await labelsArray;
    //print(labels);

    Map labelJson = json.decode(labels);
    if (labelJson.containsKey('__type')) {
      return false;
    }

    AwsRekognitionModel awsRekognitionModel =
        AwsRekognitionModel.fromJson(json.decode(labels));
    if (awsRekognitionModel.faceMatches.isEmpty) {
      return false;
    }
    if (awsRekognitionModel.faceMatches.first.similarity >= 80) {
      return true;
    }
  }

  //// END OF IMAGE PROCESSOR /////////////////////

////////////  SHOW ALERT DIALOG /////////////
  Future showAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'ALERT',
          style: TextStyle(
            color: Colors.green,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          this.mStatus == 'clockIn'
              ? 'Do you want to Clock In?'
              : 'Do you want to Clock Out?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: () {
              getImage();
              Navigator.of(context).pop();

              setState(() {
                _isLoading = true;
              });
            },
          )
        ],
      ),
    );
  }

//////// END OF SHOW ALERT DIALOG //////////

/////// SHOW COMMENT DIALOG ///////////////
  Future<String> _commentDialog(BuildContext context) async {
    String reason = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'You are seeing this because you are clocking from unspecified Location.',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Provide Reason', hintText: 'eg. at site'),
                onChanged: (value) {
                  reason = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Send',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                debugPrint("reason is $reason");
                setState(() {
                  _userSharedPref.setUserComment(reason);
                  getImage();
                  Navigator.of(context).pop();

                  _isLoading = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

//////// END OF COMMENT DIALOG //////////////

//////// SEND sendAttendanceClockInData/////////////////
  // sendAttendanceData

  Future sendAttendanceClockInData() async {
    debugPrint("sending attendance data");

    Fluttertoast.showToast(
        msg: 'Please wait for response......',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 90,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    var userId = this.mId;
    var toking = this.token;
    var status = this.mStatus;
    var comments = this.comment;
    debugPrint('userId: $userId');
    debugPrint('status: $status');
    debugPrint('comments: $comments');

    var url = '${_constants.apiUrl}/api/attendancelogs';

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return 401;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return 401;
      }
    }
    _locationData = await location.getLocation();
    print("hello ${_locationData.latitude} ${_locationData.longitude}");

    var locationName = '';

    var clockInLatitude = _locationData.latitude;
    var clockInLongitude = _locationData.longitude;
    var clockInLocationName = locationName;
    var clockInComment = comments;
    var clockInDevice = "Phone";

    Fluttertoast.showToast(
        msg: 'Please wait for response......',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    Map<String, String> headers = {'Authorization': 'Bearer $toking'};
    http.Response response = await http
        .post(url,
            body: {
              "clock_in_latitude": clockInLatitude.toString(),
              "clock_in_longitude": clockInLongitude.toString(),
              "clock_in_comment": clockInComment,
              "clock_in_device": clockInDevice,
              "clock_in_location_name": clockInLocationName,
              "clock_in_time": DateTime.now().toIso8601String(),
              "user_id": userId,
              "status": status
            },
            headers: headers)
        .timeout(Duration(seconds: 60));

    //debugPrint('response in.............................${response.body}');
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        getClockStatus(userId, toking);
        _isLoading = false;
      });
    } else if (response.statusCode == 501) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        getClockStatus(userId, toking);
        _isLoading = false;
      });
    }
  }

//////// SEND sendAttendanceClockOutData/////////////////
  //SendAttendanceClockOutData
//////// SEND sendAttendanceClockOutData/////////////////
  Future sendAttendanceClockOutData() async {
    debugPrint("sending attendance data");

    Fluttertoast.showToast(
        msg: 'Please wait for response......',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 80,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    var userId = this.mId;
    var toking = this.token;
    var comments = this.comment;
    var status = this.mStatus;
    debugPrint('userId: $userId');
    debugPrint('status: $status');
    debugPrint('comments: $comments');

    var url = '${_constants.apiUrl}/api/attendancelogs';

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return 401;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return 401;
      }
    }
    _locationData = await location.getLocation();
    print("hello ${_locationData.latitude} ${_locationData.longitude}");

    var locationName = '';

    var clockOutLatitude = _locationData.latitude;
    var clockOutLongitude = _locationData.longitude;
    var clockOutLocationName = locationName;
    var clockOutComment = comments;
    var clockOutDevice = "Phone";

    Fluttertoast.showToast(
        msg: 'Please wait for response......',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    Map<String, String> headers = {'Authorization': 'Bearer $toking'};
    http.Response response = await http
        .post(url,
            body: {
              "clock_out_latitude": clockOutLatitude.toString(),
              "clock_out_longitude": clockOutLongitude.toString(),
              "clock_out_comment": clockOutComment,
              "clock_out_device": clockOutDevice,
              "clock_out_location_name": clockOutLocationName,
              "clock_in_time": DateTime.now().toIso8601String(),
              "user_id": userId,
              "status": status
            },
            headers: headers)
        .timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        getClockStatus(userId, toking);
        _isLoading = false;
      });
    } else if (response.statusCode == 501) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        getClockStatus(userId, toking);
        _isLoading = false;
      });
    }
  }
//////// SEND sendAttendanceClockOutData/////////////////

}
