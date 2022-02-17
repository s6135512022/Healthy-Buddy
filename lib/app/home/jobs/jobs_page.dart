import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

class JobsPage extends StatelessWidget {
  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts'),
        centerTitle: true,
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Job> jobs = snapshot.data;
          return GridView.builder(
            padding: EdgeInsets.all(30.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 30.0,
            ),
            itemCount: jobs.length,
            itemBuilder: (ctx, idx) {
              return InkWell(
                onTap: () => JobEntriesPage.show(context, jobs[idx]),
                child: Card(
                  color: Color(0xFF201C3A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        jobs[idx].img,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        jobs[idx].name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }

        // return ListItemsBuilder<Job>(
        //   snapshot: snapshot,
        //   itemBuilder: (context, job) => JobListTile(
        //     job: job,
        //     onTap: () => JobEntriesPage.show(context, job),
        //   ),
        // );
      },
    );
  }
}
