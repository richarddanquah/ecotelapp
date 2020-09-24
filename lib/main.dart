import 'package:flutter/material.dart';
import 'package:ecotelunfiedapp/scr/screens/home.dart';
import 'package:ecotelunfiedapp/scr/screens/login.dart';
import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ecotelunfiedapp/user_shared_pref.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  bool isAuth = false;
  UserSharedPref _userSharedPref = new UserSharedPref();

  Future<bool> getAuthStatus() async {
    _userSharedPref.getUserAuth().then((res) {
      if (res == 'true') {
        setState(() {
          isAuth = true;
        });
      }
    });
    return isAuth;
  }

  void initState() {
    getAuthStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unified Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: isAuth ? Home() : Login(),
      routes: <String, WidgetBuilder>{
        '/privacypolicy': (_) => new WebviewScaffold(
              url:
                  "https://docs.google.com/document/d/1px_YnRlVtbA8yrnEF12sdMk2-HfzBl3KiKRsAqFWok0/edit?usp=sharing",
              appBar: new AppBar(
                title: const Text('Our Privacy Policies'),
              ),
              withZoom: false,
              withLocalStorage: true,
            ),
        '/termscondition': (_) => new WebviewScaffold(
              url:
                  "https://docs.google.com/document/d/1l6raiFoOnr0k-aSH5U8KW-Y4-FuuZ0SViXJMJPkgHJI/edit?usp=sharing",
              appBar: new AppBar(
                title: const Text('Terms & Condtions of Service'),
              ),
              withZoom: false,
              withLocalStorage: true,
            ),
      },
    );
  }
}
