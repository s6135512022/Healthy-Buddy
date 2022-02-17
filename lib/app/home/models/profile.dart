import 'package:flutter/foundation.dart';

class Profile {
  Profile({
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.goal,
    this.frequency,
  });

  int age = 0;
  String gender = '';
  int weight = 0;
  int height = 0;
  int goal = 0;
  int frequency = 0;

  int get bmr {
    if (this.age == 0 || this.weight == 0 || this.height == 0) {
      return 0;
    } else {
      if (this.gender.toLowerCase().compareTo('male') == 0) {
        return (66 +
                (13.7 * this.weight) +
                (5 * this.height) -
                (6.8 * this.age))
            .toInt();
      } else if (this.gender.toLowerCase().compareTo('female') == 0) {
        return (655 +
                (9.6 * this.weight) +
                (1.8 * this.height) -
                (4.7 * this.age))
            .toInt();
      } else {
        return 0;
      }
    }
  }

  double get tdee {
    if (this.frequency == null || this.frequency <= 0) {
      return this.bmr * 1.2;
    } else {
      if (this.frequency < 3) {
        return this.bmr * 1.375;
      } else if (this.frequency < 6) {
        return this.bmr * 1.55;
      } else if (this.frequency < 8) {
        return this.bmr * 1.725;
      } else {
        return this.bmr * 1.9;
      }
    }
  }

  int reduce = 0;
  double get recommend {
    return this.tdee - 500;
  }

  factory Profile.fromMap(Map<dynamic, dynamic> value, String id) {
    return Profile(
      age: value['age'],
      gender: value['gender'],
      weight: value['weight'],
      height: value['height'],
      goal: value['goal'],
      frequency: value['frequency'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'goal': goal,
      'frequency': frequency,
    };
  }
}
