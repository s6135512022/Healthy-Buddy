import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cal_tracker1/app/home/home_page.dart';
import 'package:cal_tracker1/app/home/map/trip_list.dart';
import 'package:cal_tracker1/app/home/models/food.dart';
import 'package:cal_tracker1/app/home/models/position.dart';
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

class TripMapPage extends StatefulWidget {
  final String tripName;
  const TripMapPage({Key key, this.tripName}) : super(key: key);

  @override
  State<TripMapPage> createState() => _TripMapPageState();
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _TripMapPageState extends State<TripMapPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _googleMapController;
  List<Marker> _markers = [];
  List<Polyline> _polyline = [];
  List<LatLng> _points = [];
  BitmapDescriptor _locationPin;
  BitmapDescriptor _finishPin;
  Position _location = Position(
    longitude: 100,
    latitude: 13,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
  );

  @override
  void initState() {
    super.initState();
    final _database = Provider.of<Database>(context, listen: false);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/icons/current_location.png')
        .then((onValue) {
      _locationPin = onValue; //ไอคอนเริ่ม
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/icons/finish_location.png')
        .then((onValue) {
      _finishPin = onValue; //ไอคอนสิ้นสุด
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

    return StreamBuilder<List<MapPosition>>(
      stream: _database.tripList(widget.tripName),
      builder: (context1, snapshot1) {
        if (snapshot1.hasData) {
          List<MapPosition> data = snapshot1.data; //ตำแหน่งทั้งหมด
          data.sort((a, b) => a.num.compareTo(b.num)); //เรียงลำดับ น้อย-มาก

          _points.clear();
          data.forEach(
            //ตำแหน่ง
            (element) {
              log('${element.toMap()}');
              _points.add(LatLng(element.latitude, element.longitude));
            },
          );

          _polyline.clear();
          _polyline.add(
            //เส้นทาง
            Polyline(
              polylineId: PolylineId(widget.tripName),
              color: Colors.blue,
              visible: true,
              width: 5,
              points: _points,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          _location = Position(
            //เลื่อนแผนที่
            longitude: data[0].longitude,
            latitude: data[0].latitude,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
          );

          _markers.clear();
          _markers.add(
            //มาร์คเริ่ม
            Marker(
              markerId: MarkerId(
                '1',
              ),
              icon: _locationPin,
              position: _points.first,
            ),
          );
          _markers.add(
            //มาร์คสิ้นสุด
            Marker(
              markerId: MarkerId(
                '2',
              ),
              icon: _finishPin,
              position: _points.last,
            ),
          );

          // Profile _profile = Profile();
          if (_googleMapController != null && _location != null) {
            _googleMapController.moveCamera(CameraUpdate.newLatLng(
                LatLng(_location.latitude, _location.longitude)));
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Trip Map'),
              centerTitle: true,
            ),
            //*** PRJ-4.2 */
            body: SafeArea(
              child: GoogleMap(
                polylines: Set.from(_polyline),
                markers: Set.from(_markers),
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
                  zoom: 17,
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
