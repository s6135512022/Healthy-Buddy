import 'dart:developer';

import 'package:cal_tracker1/app/home/map/trip_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/app/home/job_entries/job_entries_page.dart';
import 'package:cal_tracker1/app/home/jobs/edit_job_page.dart';
import 'package:cal_tracker1/app/home/jobs/empty_content.dart';
import 'package:cal_tracker1/app/home/jobs/job_list_tile.dart';
import 'package:cal_tracker1/app/home/jobs/list_items_builder.dart';
import 'package:cal_tracker1/app/home/models/job.dart';
import 'package:cal_tracker1/common_widgets/show_alert_dialog.dart';
import 'package:cal_tracker1/common_widgets/show_exception_alert_dialog.dart';
import 'package:cal_tracker1/services/auth.dart';
import 'package:cal_tracker1/services/database.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final _database = Provider.of<Database>(context, listen: false);
    var _size = MediaQuery.of(context).size;

    return StreamBuilder<List<String>>(
      stream: _database.trackingList(),
      builder: (context1, snapshot1) {
        if (snapshot1.hasData) {
          // log('snapshot1.hasData : ${snapshot1.data}');
          List<String> data = snapshot1.data;
          data.sort((a, b) =>
              DateTime.parse(b).compareTo(DateTime.parse(a))); //เรียงล่าสุด
          data.forEach((element) {
            // log('$element');
          });
          return Scaffold(
            appBar: AppBar(
              title: Text('Trip list'),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: data.length,
              itemBuilder: (ctx, idx) {
                var item = data[idx];
                var dateShow = DateFormat.yMMMMd()
                    .add_Hm()
                    .format(DateTime.parse(item)); //แสดงรูปแบบวันที่
                return ListTile(
                  title: Text(
                    '$dateShow',
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(
                          builder: (context) => TripMapPage(
                            tripName: item,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
