import 'dart:async';
import 'dart:developer';

import 'package:cal_tracker1/app/home/models/food.dart';
import 'package:cal_tracker1/app/home/models/profile.dart';
import 'package:cal_tracker1/app/home/models/recipe.dart';
import 'package:cal_tracker1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/common_widgets/avatar.dart';
import 'package:cal_tracker1/common_widgets/show_alert_dialog.dart';
import 'package:cal_tracker1/services/auth.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RecipesPage extends StatefulWidget {
  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _RecipesPageState extends State<RecipesPage> {
  TextEditingController _txtName = TextEditingController();
  TextEditingController _txtCalorie = TextEditingController();
  int _timeRecipe = 0;
  DateTime _selectDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _txtName.text = '';
    _txtCalorie.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final _database = Provider.of<Database>(context, listen: false);
    var _size = MediaQuery.of(context).size;
    Profile _profile = Profile();
    List<Food> _foodList = [];
    List<Recipe> _recipeList = [];
    int _totalKcal = 0;
    int _maxKcal = 0;
    return StreamBuilder<Profile>(
      stream: _database.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _profile = snapshot.data;
        }
        try {
          //*** PRJ-2.1 */
          return StreamBuilder<List<Food>>(
            stream: _database.foodsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _foodList = snapshot.data;
                // log('foodList : ${_foodList.length}');
              }
              //*** PRJ-2.2 */
              return StreamBuilder<List<Recipe>>(
                stream: _database.recipesStream(
                    DateFormat("yyyy-MM-dd").format(_selectDate)),
                builder: (context, snapshot) {
                  Recipe food1, food2, food3;
                  if (snapshot.hasData) {
                    _recipeList = snapshot.data;
                    log('recipeList : ${_recipeList.length}');
                    _recipeList.forEach((e) {
                      log('e : ${e.name} - ${e.time}');
                    });
                    //ดึงอาหารมื้อต่างๆ ในวันนั้น
                    food1 = _recipeList.firstWhere((e) => e.time == 1,
                        orElse: () => null);
                    food2 = _recipeList.firstWhere((e) => e.time == 2,
                        orElse: () => null);
                    food3 = _recipeList.firstWhere((e) => e.time == 3,
                        orElse: () => null);

                    _totalKcal = 0;
                    if (food1 != null) {
                      _totalKcal += food1.calorie;
                    }
                    if (food2 != null) {
                      _totalKcal += food2.calorie;
                    }
                    if (food3 != null) {
                      _totalKcal += food3.calorie;
                    }
                  }

                  // log('food1 : $food1');

                  var _tdee = 0.0;
                  try {
                    // if (_profile != null && _profile.recommend > 0) {
                    // setState(() {
                    _tdee = _profile.recommend;
                    // });
                    // }
                  } catch (e) {}

                  return Scaffold(
                    appBar: AppBar(
                      title: Text('Recipes'),
                      centerTitle: true,
                    ),
                    body: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 15.0),
                            Center(
                              child: Container(
                                width: _size.width * 0.9,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: _size.width * 0.43,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE4F2E8),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'Total kcal: $_totalKcal',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Container(
                                      width: _size.width * 0.43,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF59CAF),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'Max Per Day: ${_tdee.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              width: _size.width * 0.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.chevron_left,
                                      size: 48.0,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectDate =
                                            _selectDate.add(Duration(days: -1));
                                      });
                                    },
                                  ),
                                  Text(
                                    '${DateFormat(' MMM d, yyyy').format(_selectDate)}',
                                    style: TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.chevron_right,
                                      size: 48.0,
                                    ),
                                    onPressed: () {
                                      //เกินวันปัจจุบันไม่ได้
                                      if (!_selectDate
                                          .isSameDate(DateTime.now())) {
                                        setState(() {
                                          _selectDate = _selectDate
                                              .add(Duration(days: 1));
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 30.0,
                              indent: 35.0,
                              endIndent: 35.0,
                              thickness: 2.0,
                            ),
                            Container(
                              width: _size.width * 0.9,
                              // height: 180.0,
                              child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 10.0, 15.0, 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Breakfast',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Total ${food1 != null ? food1.calorie : '-'}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 20.0, 0.0, 25.0),
                                      child: food1 != null
                                          ? Text(
                                              '${food1.name}',
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Color(0xFFCE3554),
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        45.0, 15.0, 45.0, 15.0),
                                                child: Text(
                                                  'Add food',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                await addFoodRecipe(
                                                  context: context,
                                                  timeRecipe: 1,
                                                  database: _database,
                                                  foodList: _foodList,
                                                ).then((value) {
                                                  // log('addFood ret : $value');
                                                });
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              width: _size.width * 0.9,
                              // height: 180.0,
                              child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 10.0, 15.0, 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lunch',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Total ${food2 != null ? food2.calorie : '-'}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 20.0, 0.0, 25.0),
                                      child: food2 != null
                                          ? Text(
                                              '${food2.name}',
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Color(0xFFCE3554),
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        45.0, 15.0, 45.0, 15.0),
                                                child: Text(
                                                  'Add food',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                await addFoodRecipe(
                                                  context: context,
                                                  timeRecipe: 2,
                                                  database: _database,
                                                  foodList: _foodList,
                                                ).then((value) {
                                                  // log('addFood ret : $value');
                                                });
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              width: _size.width * 0.9,
                              // height: 180.0,
                              child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 10.0, 15.0, 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Dinner',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Total ${food3 != null ? food3.calorie : '-'}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 20.0, 0.0, 25.0),
                                      child: food3 != null
                                          ? Text(
                                              '${food3.name}',
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Color(0xFFCE3554),
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        45.0, 15.0, 45.0, 15.0),
                                                child: Text(
                                                  'Add food',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                await addFoodRecipe(
                                                  context: context,
                                                  timeRecipe: 3,
                                                  database: _database,
                                                  foodList: _foodList,
                                                ).then((value) {
                                                  // log('addFood ret : $value');
                                                });
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        } catch (e) {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<int> addFoodRecipe({
    @required BuildContext context,
    @required int timeRecipe,
    @required Database database,
    @required List<Food> foodList,
  }) async {
    if (timeRecipe <= 0) {
      return -1; //มืออาหารผิด
    }
    // log('finished');
    return await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          height: 700,
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 48,
                      ),
                    ),
                    Text(
                      'Add food',
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 48.0),
                  ],
                ),
                Divider(
                  height: 30.0,
                  indent: 20.0,
                  endIndent: 20.0,
                  // thickness: 2,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Food',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.import_contacts),
                            onPressed: () async {
                              //*** PRJ-2.1 */
                              SelectDialog.showModal<Food>(context,
                                  label: 'Food List',
                                  items: foodList,
                                  //*** PRJ-4 */
                                  onFind: (text) async => foodList
                                      .where((e) => e.name.contains(text))
                                      .toList(),
                                  itemBuilder: (context, item, isSelected) {
                                    return ListTile(
                                      title: Text(
                                          '${item.name} (${item.calorie})'),
                                      selected: isSelected,
                                    );
                                  },
                                  onChange: (value) {
                                    _txtName.text = value.name;
                                    _txtCalorie.text = value.calorie.toString();
                                  });
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: _txtName,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Calorie',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _txtCalorie,
                      ),
                      SizedBox(height: 30.0),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFFCE3554),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                45.0, 15.0, 45.0, 15.0),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) async {
      // log('dialog val : $value');
      //*** PRJ-2.2 */
      if (_txtName.text.isNotEmpty && _txtCalorie.text.isNotEmpty) {
        try {
          Recipe recipe = Recipe(
            id: documentIdFromCurrentDate(),
            name: _txtName.text,
            weight: 0,
            calorie: int.parse(_txtCalorie.text),
            time: timeRecipe,
            date: DateFormat('yyyy-MM-dd').format(_selectDate),
          );
          await database.setRecipe(recipe);
        } on Exception catch (e) {
          log('err : $e');
        }

        //*** PRJ-2.1 */
        log('add food : ${_txtName.text} : ${_txtCalorie.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('add food : ${_txtName.text} : ${_txtCalorie.text}'),
          ),
        );
        _timeRecipe = 0;
        _txtName.text = '';
        _txtCalorie.text = '';
        return 1;
      } else {
        _timeRecipe = 0;
        _txtName.text = '';
        _txtCalorie.text = '';
        return -2;
      }
    }).onError((error, stackTrace) {
      return -9;
    });
  }
}
