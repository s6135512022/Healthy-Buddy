import 'dart:developer';

import 'package:cal_tracker1/app/home/models/profile.dart';
import 'package:cal_tracker1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/common_widgets/avatar.dart';
import 'package:cal_tracker1/common_widgets/show_alert_dialog.dart';
import 'package:cal_tracker1/services/auth.dart';
import 'package:select_dialog/select_dialog.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Profile _profile;

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  Future<String> _showTextDialog(BuildContext context, String title) async {
    String ret = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            decoration: InputDecoration(hintText: title),
            onChanged: (val) {
              ret = val;
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: _buildUserInfo(auth.currentUser),
        ),
      ),
      body: _buildUserProfile(context, auth.currentUser),
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      children: <Widget>[
        Avatar(
          photoUrl: user.photoURL,
          radius: 50,
        ),
        SizedBox(height: 8),
        if (user.displayName != null)
          Text(
            user.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    final _database = Provider.of<Database>(context, listen: false);
    var _size = MediaQuery.of(context).size;
    return StreamBuilder<Profile>(
      stream: _database.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _profile = snapshot.data;
        } else {
          //*** PRJ-2.1 */
          //แก้ไขหน้าผู้ใช้หมุนตลอด
          _profile = Profile()
            ..age = 0
            ..gender = ''
            ..goal = 0
            ..height = 0
            ..weight = 0
            ..frequency = 0;
          // _database.setProfile(_profile);		//*** PRJ-2.2 */
        }
        log("profile : ${_profile.age}");
        try {
          return SafeArea(
            child: SingleChildScrollView(
                child: Column(
              children: [
                // SizedBox(height: 10),
                // Container(
                //   width: _size.width * 0.3,
                //   height: 50,
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(10.0),
                //   ),
                //   child: Text(
                //     'คำนวณ BMR',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 14.0,
                //       fontWeight: FontWeight.w500,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                SizedBox(height: 10),
                Container(
                  width: _size.width * 0.9,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: _size.width * 0.43,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFE4F2E8),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'BMR(kcal): ${_profile.bmr}',
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
                          color: Color(0xFFE4F2E8),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'TDEE(kcal): ${_profile.tdee.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 10),
                // Container(
                //   width: _size.width * 0.9,
                //   height: 100,
                //   padding: EdgeInsets.all(10.0),
                //   decoration: BoxDecoration(
                //     color: Color(0xFFF69FB0),
                //     borderRadius: BorderRadius.circular(10.0),
                //   ),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       Text(
                //         'ปริมาณพลังงานที่ต้องลดต่อวัน',
                //         textAlign: TextAlign.left,
                //         style: TextStyle(
                //           color: Colors.black,
                //           fontSize: 16.0,
                //         ),
                //       ),
                //       Container(
                //         width: _size.width * 0.3,
                //         height: 35,
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           color: Color(0xFFE4F2E8),
                //           borderRadius: BorderRadius.circular(30.0),
                //         ),
                //         child: Text(
                //           '#### (kcal)',
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontSize: 14.0,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 10),
                Container(
                  width: _size.width * 0.9,
                  height: 100,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFC3D6F1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'ปริมาณพลังงานที่แนะนำต่อวัน',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      Container(
                        width: _size.width * 0.3,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFE4F2E8),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          '${_profile.recommend.toStringAsFixed(0)} (kcal)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Text('Age : '),
                        title: Text(
                          '${_profile.age ?? '-'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await _showTextDialog(context, 'Age').then((value) {
                              if (value.isNotEmpty) {
                                _profile.age = int.parse(value);
                                _database.setProfile(_profile);
                              }
                            });
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Gender : '),
                        title: Text(
                          '${_profile.gender ?? '-'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () async {
                            //*** PRJ-2.2 */
                            SelectDialog.showModal<String>(context,
                                showSearchBox: false,
                                label: 'Gender',
                                items: ['male', 'female'],
                                itemBuilder: (context, item, isSelected) {
                              return ListTile(
                                title: Text('$item'),
                                selected: isSelected,
                              );
                            }, onChange: (value) {
                              if (value.isNotEmpty) {
                                _profile.gender = value;
                                _database.setProfile(_profile);
                              }
                            });
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Weight (kg) : '),
                        title: Text(
                          '${_profile.weight ?? '-'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await _showTextDialog(context, 'Weight')
                                .then((value) {
                              if (value.isNotEmpty) {
                                _profile.weight = int.parse(value);
                                _database.setProfile(_profile);
                              }
                            });
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Height (cm) : '),
                        title: Text(
                          '${_profile.height ?? '-'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await _showTextDialog(context, 'Height')
                                .then((value) {
                              if (value.isNotEmpty) {
                                _profile.height = int.parse(value);
                                _database.setProfile(_profile);
                              }
                            });
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Frequency : '),
                        title: Text(
                          '${_profile.frequency ?? '-'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () async {
                            //*** PRJ-2.2 */
                            SelectDialog.showModal<Map<String, dynamic>>(
                                context,
                                showSearchBox: false,
                                label: 'Frequency',
                                items: [
                                  {
                                    'txt': 'ไม่ออกกำลังกายหรือทำงานนั่งโต๊ะ',
                                    'val': 0,
                                  },
                                  {
                                    'txt': 'ออกกำลังกาย 1-2 ครั้งต่อสัปดาห์',
                                    'val': 1,
                                  },
                                  {
                                    'txt': 'ออกกำลังกาย 3-5 ครั้งต่อสัปดาห์',
                                    'val': 3,
                                  },
                                  {
                                    'txt': 'ออกกำลังกาย 6-7 ครั้งต่อสัปดาห์',
                                    'val': 6,
                                  },
                                  {
                                    'txt': 'ออกกำลังกายทุกวัน วันละ 2 เวลา',
                                    'val': 8,
                                  },
                                ], itemBuilder: (context, item, isSelected) {
                              return ListTile(
                                title: Text('${item['txt']}'),
                                selected: isSelected,
                              );
                            }, onChange: (value) {
                              if (value['val'] >= 0) {
                                _profile.frequency = value['val'];
                                _database.setProfile(_profile);
                              }
                            });
                          },
                        ),
                      ),
                      // Divider(),
                      // ListTile(
                      //   leading: Text('Weight Goal : '),
                      //   title: Text(
                      //     '${_profile.goal ?? '-'}',
                      //   ),
                      //   trailing: IconButton(
                      //     icon: Icon(Icons.edit_outlined),
                      //     onPressed: () async {
                      //       await _showTextDialog(context, 'Goal')
                      //           .then((value) {
                      //         if (value.isNotEmpty) {
                      //           _profile.goal = int.parse(value);
                      //           _database.setProfile(_profile);
                      //         }
                      //       });
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            )),
          );
        } catch (e) {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
