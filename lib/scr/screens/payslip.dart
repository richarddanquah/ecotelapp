import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../date_utils.dart';
import '../../user_shared_pref.dart';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class PaySlip extends StatefulWidget {
  @override
  _PaySlipState createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  Constants _constants = Constants();
  UserSharedPref _userSharedPref = new UserSharedPref();
  DateUtils _dateUtils = DateUtils();
  List payroll = List();
  var userId;
  var token;
  var empDate;
  String urlPDFPath = "";
  String serverURl = "";
  ProgressDialog _progress = ProgressDialog();
  String perStatus;
  //Permission permission;
  var formatter = new DateFormat('EEE, d MMM. yyyy hh:mm a', "en_US");

  Future<void> getUserToken() async {
    _userSharedPref.getUserToken().then((tokens) {
      token = tokens;

      _userSharedPref.getUserId().then((ids) {
        userId = ids;
        fetchUserPayroll(ids);
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

  Future fetchUserPayroll(String id) async {
    var url = '${_constants.apiUrl}/api/app-payroll_employee';

    _progress.showProgressDialog(context,
        textToBeDisplayed: 'loading user payroll...');

    var response = await http.post(Uri.parse(url),
        body: {'user_id': id.toString()}).timeout(Duration(seconds: 60));

    //debugPrint('Response status: ${response.statusCode}');
    //debugPrint('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      _progress.dismissProgressDialog(context);
      setState(() {
        payroll = dataConvertedToJSON['data'];

        payroll.map((data) {
          var index = payroll.indexOf(data);
          debugPrint("index: $index");

          _userSharedPref.setUserDate(payroll[index]['process_date']);

          debugPrint(payroll[index]['process_date']);
        }).toList();
      });
    } else {
      debugPrint('error');
    }

    return 'success';
  }

  Future<http.Response> employeePayroll(var dates) async {
    debugPrint("fetching pdf url from server");

    var ids = this.userId;
    var date = dates;
    var url = '${_constants.apiUrl}/api/app_payroll_pdf';
    debugPrint("userIds: $ids");
    debugPrint("url: $url");
    debugPrint("date: $date");

//    _progress.showProgressDialog(context,
//        textToBeDisplayed: 'loading payslip...');

    var response = await http.post(Uri.parse(url), body: {
      'user_id': ids.toString(),
      'date': date.toString()
    }).timeout(Duration(seconds: 60));

    debugPrint('pdf url Response status: ${response.statusCode}');

    return response;
  }

  Future<File> getPdfFromUrl(String url) async {
    Completer<File> completer = Completer();

    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/payrollPdf.pdf");
      File urlFile = await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
      return urlFile;
    } catch (e) {
      throw Exception("error opening asset file");
    }
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
          title: Text("Payroll"),
          backgroundColor: Color(0xff2AB351),
        ),
        extendBody: true,
        body: payroll.length == 0
            ? emptyLabelWidget()
            : notEmptyLabelWidget(payroll));
  }

  Widget emptyLabelWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error, color: Color(0xff2AB351), size: 50.0),
          Text(
            'No Payroll found!',
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
                                  'Full Name: ${payroll[index]['user']['full_name']}' ==
                                          'null'
                                      ? 'No Employee Name'
                                      : 'Full Name: ${payroll[index]['user']['full_name']}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Gross Salary: GHC ${payroll[index]['gross_salary'].toString()}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : 'Gross Salary: GHC ${payroll[index]['gross_salary'].toString()}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Net Pay: GHC ${payroll[index]['net_pay'].toString()}' ==
                                          'null'
                                      ? 'Data Not Available'
                                      : 'Net Pay: GHC ${payroll[index]['net_pay'].toString()}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Process Date: ${payroll[index]['process_date'].toString()}' ==
                                          'null'
                                      ? 'Date Not Available'
                                      : 'Process Date: ${_dateUtils.dateConvert2(DateTime.parse(payroll[index]['process_date'].toString()))}',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 4, right: 4),

                          child: IconButton(
                            icon: Icon(Icons.picture_as_pdf),
                            color: Colors.green,
                            onPressed: () {
                              _progress.showProgressDialog(context,
                                  textToBeDisplayed: 'loading pdf...');

                              employeePayroll(payroll[index]['process_date'])
                                  .then((response) {
                                if (response.statusCode == 200) {
                                  var dataConvertedToJSON =
                                      json.decode(response.body);

                                  setState(() {
                                    var serverURls =
                                        dataConvertedToJSON['data'];
                                    debugPrint('$serverURls url');

                                    getPdfFromUrl(serverURls).then((f) {
                                      setState(() {
                                        urlPDFPath = f.path;
                                        debugPrint("urlPdfPath: $urlPDFPath");

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(
                                                        path: urlPDFPath)));

                                        debugPrint(
                                            "urlPDFPath button: $urlPDFPath");
                                      });
                                    });
                                  });

                                  _progress.dismissProgressDialog(context);
                                }
                              });

                              // Either the permission was already granted before or the user just granted it.
//                              if (urlPDFPath != null) {
//                              Timer(Duration(seconds: 30), () {
//                                debugPrint("urlPDFPath button: $urlPDFPath");

//                              });

//                              }
                            },
                          ),
//
                        ),
                      ],
                    ),
                  ),
                ),
              )),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    int _totalPages = 0;
    int _currentPage = 0;
    bool pdfReady = false;
    PDFViewController _pdfViewController;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pdf"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            onError: (e) {
              debugPrint("pdf error: $e");
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
//          !pdfReady
//              ? Center(
//                  child: CircularProgressIndicator(),
//                )
//              : Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  label: Text("Go to ${_currentPage - 1}"),
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
          _currentPage < _totalPages
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  label: Text("Go to ${_currentPage + 1}"),
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
        ],
      ),
    );
  }
}
