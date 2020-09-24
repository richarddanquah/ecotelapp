import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:ecotelunfiedapp/scr/screens/clock_in.dart';
import 'package:ecotelunfiedapp/scr/screens/clock_out.dart';

class AttendanceHistory extends StatefulWidget {
  @override
  _AttendanceHistoryState createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollViewController;

  TabController _tabController;
  final List<Tab> tabs = <Tab>[
    Tab(
      text: "Clock In",
    ),
    Tab(
      text: "Clock Out",
    ),
  ];

  @override
  void initState() {
    _tabController =
        TabController(length: tabs.length, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Color(0xff2AB351),
              title: Text('Attendance Logs'),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                tabs: tabs,
                indicatorColor: Colors.white,
                isScrollable: true,
                unselectedLabelColor: Colors.amber,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(fontSize: 20.0),
                indicator: BubbleTabIndicator(
                    indicatorHeight: 30.0,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                    indicatorRadius: 35.0,
                    padding: EdgeInsets.all(10),
                    indicatorColor: Colors.amber),
                controller: _tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ClockIn(),
            ClockOut(),
          ],
        ),
      ),
    );
  }
}
