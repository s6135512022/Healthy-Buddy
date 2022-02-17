import 'package:cal_tracker1/app/home/models/profile.dart';
import 'package:cal_tracker1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/common_widgets/avatar.dart';
import 'package:cal_tracker1/common_widgets/show_alert_dialog.dart';
import 'package:cal_tracker1/services/auth.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie table'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SfPdfViewer.asset('assets/table.pdf'),
      ),
    );
  }
}
