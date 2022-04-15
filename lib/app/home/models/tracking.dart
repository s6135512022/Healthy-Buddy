import 'package:meta/meta.dart';

class Tracking {
  Tracking({
    @required this.id,
    @required this.num,
    @required this.latitude,
    @required this.longitude,
    @required this.time,
  });
  final String id;
  final int num;
  final double latitude;
  final double longitude;
  final String time;

  factory Tracking.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final int num = data['num'];
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    final String time = data['time'];
    return Tracking(
        id: documentId,
        num: num,
        latitude: latitude,
        longitude: longitude,
        time: time);
  }

  Map<String, dynamic> toMap() {
    return {
      'num': num,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    };
  }
}
