import 'package:meta/meta.dart';

class Food {
  Food(
      {@required this.id,
      @required this.name,
      @required this.weight,
      this.calorie});
  final String id;
  final String name;
  final int weight;
  final int calorie;

  factory Food.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final int weight = data['weight'];
    final int calorie = data['calorie'];
    return Food(id: documentId, name: name, weight: weight, calorie: calorie);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'calorie': calorie,
    };
  }
}
