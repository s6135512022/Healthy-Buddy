import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cal_tracker1/app/home/entries/daily_jobs_details.dart';
import 'package:cal_tracker1/app/home/entries/entries_list_tile.dart';
import 'package:cal_tracker1/app/home/entries/entry_job.dart';
import 'package:cal_tracker1/app/home/job_entries/format.dart';
import 'package:cal_tracker1/app/home/models/entry.dart';
import 'package:cal_tracker1/app/home/models/job.dart';
import 'package:cal_tracker1/services/database.dart';

class EntriesBloc {
  EntriesBloc({@required this.database});
  final Database database;

  /// combine List<Job>, List<Entry> into List<EntryJob>
  Stream<List<EntryJob>> get _allEntriesStream => Rx.combineLatest2(
        database.entriesStream(),
        database.jobsStream(),
        _entriesJobsCombiner,
      );

  static List<EntryJob> _entriesJobsCombiner(
      List<Entry> entries, List<Job> jobs) {
    return entries.map((entry) {
      final job = jobs.firstWhere(
        (job) => job.id == entry.jobId,
        orElse: () => null,
      );
      return EntryJob(entry, job);
    }).toList();
  }

  /// Output stream
  Stream<List<EntriesListTileModel>> get entriesTileModelStream =>
      _allEntriesStream.map(_createModels);

  static List<EntriesListTileModel> _createModels(List<EntryJob> allEntries) {
    if (allEntries.isEmpty) {
      return [];
    }
    final allDailyJobsDetails = DailyJobsDetails.all(allEntries);

    // total duration across all jobs
    final totalDuration = allDailyJobsDetails
        .map((dateJobsDuration) => dateJobsDuration.duration)
        .reduce((value, element) => value + element);

    // total pay across all jobs
    final totalPay = allDailyJobsDetails
        .map((dateJobsDuration) => dateJobsDuration.pay)
        .reduce((value, element) => value + element);

    return <EntriesListTileModel>[
      EntriesListTileModel(
        leadingText: 'All Workouts',
        // middleText: Format.currency(totalPay),

        middleText: totalPay.toStringAsFixed(0),
        trailingText: Format.hours(totalDuration),
      ),
      for (DailyJobsDetails dailyJobsDetails in allDailyJobsDetails) ...[
        EntriesListTileModel(
          isHeader: true,
          leadingText: Format.date(dailyJobsDetails.date),
          //*** PRJ-4 */
          // middleText: Format.currency(dailyJobsDetails.pay),
          middleText: dailyJobsDetails.pay.toStringAsFixed(0),
          trailingText: Format.hours(dailyJobsDetails.duration),
        ),
        for (JobDetails jobDuration in dailyJobsDetails.jobsDetails)
          EntriesListTileModel(
            leadingText: jobDuration.name,

            // middleText: Format.currency(jobDuration.pay),
            middleText: jobDuration.pay.toStringAsFixed(0),
            trailingText: Format.hours(jobDuration.durationInHours),
            img: jobDuration.name,
          ),
      ]
    ];
  }
}
