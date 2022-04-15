import 'dart:developer';

import 'package:cal_tracker1/app/home/models/food.dart';
import 'package:cal_tracker1/app/home/models/position.dart';
import 'package:cal_tracker1/app/home/models/profile.dart';
import 'package:cal_tracker1/app/home/models/recipe.dart';
import 'package:cal_tracker1/app/home/models/tracking.dart';
import 'package:meta/meta.dart';
import 'package:cal_tracker1/app/home/models/entry.dart';
import 'package:cal_tracker1/app/home/models/job.dart';
import 'package:cal_tracker1/services/api_path.dart';
import 'package:cal_tracker1/services/firestore_service.dart';

abstract class Database {
  Future<void> setJob(Job job);
  Future<void> deleteJob(Job job);
  Stream<List<Job>> jobsStream();
  Stream<Job> jobStream({@required String jobId});

  Future<void> setEntry(Entry entry);
  Future<void> deleteEntry(Entry entry);
  Stream<List<Entry>> entriesStream({Job job});

  //*** PRJ-1 */
  Stream<Profile> getProfile();
  Future<void> setProfile(Profile profile);

  //*** PRJ-2.1 */
  Stream<List<Food>> foodsStream();

  //*** PRJ-2.2 */
  Future<void> setRecipe(Recipe recipe);
  Future<void> deleteRecipe(Recipe recipe);
  Stream<List<Recipe>> recipesStream(String date);

  //*** PRJ-4.1 */
  Stream<List<String>> trackingList();
  Future<void> trackingDocument(String docID, bool isWalking);
  Future<void> addTracking(Tracking tracking);

  //*** PRJ-4.2 */
  Stream<List<MapPosition>> tripList(String tripName);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _service = FirestoreService.instance;

  @override
  Stream<List<String>> trackingList() {
    return _service.collectionStream<String>(
        path: APIPath.trackingList(uid),
        builder: (data, documentId) {
          return documentId;
        });
  }

  @override
  Stream<List<MapPosition>> tripList(String tripName) {
    return _service.collectionStream<MapPosition>(
        path: APIPath.tripList(uid, tripName),
        builder: (data, documentId) {
          // log('documentId:$documentId  data:$data');
          return MapPosition.fromMap(data, documentId);
        });
  }

  @override
  Future<void> trackingDocument(String docID, bool isWalking) =>
      _service.setData(
        path: '${APIPath.trackingList(uid)}/$docID',
        data: {'isWalking': isWalking},
      );

  @override
  Future<void> addTracking(Tracking tracking) => _service.setData(
        path: APIPath.tracking(uid, tracking.id, tracking.num),
        data: tracking.toMap(),
      );

  @override
  Future<void> setJob(Job job) => _service.setData(
        path: APIPath.job(uid, job.id),
        data: job.toMap(),
      );

  @override
  Future<void> deleteJob(Job job) async {
    // delete where entry.jobId == job.jobId
    final allEntries = await entriesStream(job: job).first;
    for (Entry entry in allEntries) {
      if (entry.jobId == job.id) {
        await deleteEntry(entry);
      }
    }
    // delete job
    await _service.deleteData(path: APIPath.job(uid, job.id));
  }

  @override
  Stream<Job> jobStream({@required String jobId}) => _service.documentStream(
        path: APIPath.jobGet(jobId), //*** PRJ-1 */
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );

  @override
  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: APIPath.jobsList(), //*** PRJ-1 */
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );

  @override //*** PRJ-1 */
  Future<void> setProfile(Profile profile) => _service.setData(
        path: APIPath.profile(uid),
        data: profile.toMap(),
      );

  @override //*** PRJ-1 */
  Stream<Profile> getProfile() => _service.documentStream(
        path: APIPath.profile(uid),
        builder: (data, documentId) {
          log('profile : $documentId');
          return Profile.fromMap(data, documentId);
        },
      );

  @override //*** PRJ-2.1 */
  Stream<List<Food>> foodsStream() => _service.collectionStream(
        path: APIPath.foodsList(),
        builder: (data, documentId) => Food.fromMap(data, documentId),
      );

  //*** PRJ-2.2 */
  @override //model ใช้อันเดียวกับ food
  Future<void> setRecipe(Recipe recipe) => _service.setData(
        path: APIPath.recipe(uid, recipe.id),
        data: recipe.toMap(),
      );

  @override
  Future<void> deleteRecipe(Recipe recipe) => _service.deleteData(
        path: APIPath.recipe(uid, recipe.id),
      );

  @override
  Stream<List<Recipe>> recipesStream(String date) =>
      _service.collectionStream<Recipe>(
        path: APIPath.recipes(uid),
        queryBuilder: date != null
            ? (query) => query.where('date', isEqualTo: date)
            : null,
        builder: (data, documentID) => Recipe.fromMap(data, documentID),
      );

  @override
  Future<void> setEntry(Entry entry) => _service.setData(
        path: APIPath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  @override
  Future<void> deleteEntry(Entry entry) => _service.deleteData(
        path: APIPath.entry(uid, entry.id),
      );

  @override
  Stream<List<Entry>> entriesStream({Job job}) =>
      _service.collectionStream<Entry>(
        path: APIPath.entries(uid),
        queryBuilder: job != null
            ? (query) => query.where('jobId', isEqualTo: job.id)
            : null,
        builder: (data, documentID) => Entry.fromMap(data, documentID),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );
}
