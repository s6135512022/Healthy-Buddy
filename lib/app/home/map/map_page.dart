import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cal_tracker1/app/home/home_page.dart';
import 'package:cal_tracker1/app/home/map/trip_list.dart';
import 'package:cal_tracker1/app/home/models/entry.dart';
import 'package:cal_tracker1/app/home/models/food.dart';
import 'package:cal_tracker1/app/home/models/profile.dart';
import 'package:cal_tracker1/app/home/models/recipe.dart';
import 'package:cal_tracker1/app/home/models/tracking.dart';
import 'package:cal_tracker1/services/database.dart';
import 'package:cal_tracker1/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/common_widgets/avatar.dart';
import 'package:cal_tracker1/common_widgets/show_alert_dialog.dart';
import 'package:cal_tracker1/services/auth.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {

  bool isWalking = true;
  bool isTracking = false;
  bool isNewRoute = false;
  int trackNumber = 0;
  String trackingID = '';
  final Duration TRACKING_TICK = Duration(seconds: 3);
  Timer timer;

  @override
  State<MapPage> createState() => _MapPageState();
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _googleMapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  BitmapDescriptor _locationPin;
  Position _location;

  DateTime _date1, _date2;

  @override
  void initState() {
    super.initState();
    final _database = Provider.of<Database>(context, listen: false);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/icons/current_location.png')
        .then((onValue) {
      _locationPin = onValue;
    });

    //*** PRJ-4.1 */
    if (widget.timer != null) {
      widget.timer.cancel();
    }
    widget.timer = Timer.periodic(widget.TRACKING_TICK, (t) async {
      if (widget.isTracking) {
        try {
          _location = await _determinePosition();
          if (widget.isNewRoute) {
            _date1 = DateTime.now();
            log('set New Route');
            widget.isNewRoute = false;
            widget.trackingID = documentIdFromCurrentDate();
            _database.trackingDocument(
              widget.trackingID,
              widget.isWalking,
            ); //need document detail for query back
          }
          widget.trackNumber += 1;
          final tracking = Tracking(
            id: widget.trackingID,
            num: widget.trackNumber,
            latitude: _location.latitude,
            longitude: _location.longitude,
            time: DateTime.now().toIso8601String(),
          );
          await _database.addTracking(tracking);
          log('trackNumber:${widget.trackNumber} tracking:${_location.latitude}');
        } catch (err) {
          log('err: $err');
        }
        setState(() {});
      } else {
        widget.isNewRoute = true;
        widget.trackNumber = 0;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final _database = Provider.of<Database>(context, listen: false);
    var _size = MediaQuery.of(context).size;

    if (Platform.isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }

    // Profile _profile = Profile();
    return StreamBuilder<Profile>(
      stream: _database.getProfile(),
      builder: (context, snapshot) {
        // log('snapshot : $snapshot');
        if (snapshot.hasData) {
          // log('snapshot.hasData');
          // _profile = snapshot.data;
          return FutureBuilder<Position>(
            future: _determinePosition(),
            builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
              if (snapshot.hasData) {
                _location = snapshot.data;
                _markers[MarkerId('current')] = Marker(
                  markerId: MarkerId('current'),
                  icon: _locationPin,
                  position: LatLng(
                    _location.latitude,
                    _location.longitude,
                  ),
                );
                if (_googleMapController != null && _location != null) {
                  _googleMapController.moveCamera(CameraUpdate.newLatLng(
                      LatLng(_location.latitude, _location.longitude)));
                }
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Tracker'),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        onPressed: () async {
                          await Navigator.of(context, rootNavigator: false)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => TripListPage(),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.list,
                        ),
                      ),
                    ],
                  ),

                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: _size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    widget.isWalking = false;
                                  });
                                },
                                child: Text(
                                  'Running',
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: widget.isWalking
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    widget.isWalking = true;
                                  });
                                },
                                child: Text(
                                  'Walking',
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: widget.isWalking
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: _size.height * 0.6,
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            onCameraMove: (position) {
                              log('onCameraMove');
                            },
                            onMapCreated: (controller) {
                              _googleMapController = controller;
                              _controller.complete(controller);
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _location.latitude,
                                _location.longitude,
                              ),
                              zoom: 17.5,
                            ),
                            markers: Set<Marker>.of(
                              _markers.values,
                            ),
                          ),
                        ),
                        Container(
                          height: _size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: !widget.isTracking,
                                child: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      widget.isTracking = true;
                                    });
                                    log('widget.isTracking = true;');
                                  },
                                  alignment: Alignment.center,
                                  iconSize: 76.0,
                                  icon: Icon(
                                    Icons.play_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.isTracking,
                                child: IconButton(
                                  onPressed: () async {

                                    if (_date1 != null) {
                                      Entry entry = Entry(
                                        id: documentIdFromCurrentDate(),
                                        jobId: widget.isWalking
                                            ? 'walking'
                                            : 'running',
                                        start: _date1,
                                        end: DateTime.now(),
                                        comment: '',
                                      );
                                      _database.setEntry(entry);
                                    }
                                    _date1 = null;
                                    _date2 = null;
                                    setState(() {
                                      widget.isTracking = false;
                                    });
                                    log('widget.isTracking = false;');
                                  },
                                  alignment: Alignment.center,
                                  iconSize: 76.0,
                                  icon: Icon(
                                    Icons.stop_circle_outlined,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
