import 'package:meta/meta.dart';

class Recipe {
  Recipe({
    @required this.id,
    @required this.name,
    @required this.calorie,
    @required this.time,
    @required this.date,
    this.weight,
  });
  final String id;
  final String name;
  final int calorie;
  final int time;
  final String date;
  final int weight;

  factory Recipe.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final int calorie = data['calorie'];
    final int time = data['time'];
    final String date = data['date'];
    final int weight = data['weight'];
    return Recipe(
      id: documentId,
      name: name,
      calorie: calorie,
      time: time,
      date: date,
      weight: weight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calorie': calorie,
      'time': time,
      'date': date,
      'weight': weight,
    };
  }
}
