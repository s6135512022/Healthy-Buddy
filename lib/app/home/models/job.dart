import 'package:meta/meta.dart';

class Job {
  Job(
      {@required this.id,
      @required this.name,
      @required this.ratePerHour,
      this.img});
  final String id;
  final String name;
  final int ratePerHour;
  final String img;

  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final int ratePerHour = data['ratePerHour'];
    final String img = data['img'];
    return Job(id: documentId, name: name, ratePerHour: ratePerHour, img: img);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ratePerHour': ratePerHour,
      'img': img,
    };
  }
}
