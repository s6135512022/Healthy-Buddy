import 'dart:developer';

import 'package:meta/meta.dart';

class MapPosition {
  MapPosition({
    @required this.num,
    @required this.latitude,
    @required this.longitude,
  });
  final int num;
  final double latitude;
  final double longitude;

  factory MapPosition.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final int num = data['num'];
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    return MapPosition(num: num, latitude: latitude, longitude: longitude);
  }

  Map<String, dynamic> toMap() {
    return {
      'num': num,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
