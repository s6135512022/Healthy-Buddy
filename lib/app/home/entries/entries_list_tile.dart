import 'dart:developer';

import 'package:cal_tracker1/app/home/models/job.dart';
import 'package:cal_tracker1/services/api_path.dart';
import 'package:cal_tracker1/services/database.dart';
import 'package:cal_tracker1/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntriesListTileModel {
  const EntriesListTileModel({
    @required this.leadingText,
    @required this.trailingText,
    this.middleText,
    this.isHeader = false,
    this.img = '',
  });
  final String leadingText;
  final String trailingText;
  final String middleText;
  final bool isHeader;
  final String img;
}

class EntriesListTile extends StatefulWidget {
  const EntriesListTile({@required this.model});
  final EntriesListTileModel model;

  @override
  State<EntriesListTile> createState() => _EntriesListTileState();
}

class _EntriesListTileState extends State<EntriesListTile> {
  var db = FirestoreService.instance;
  var img;

  @override
  void initState() {
    super.initState();
    if (widget.model.img.isNotEmpty) {
      // Future.delayed(Duration.zero, () async {
      //   img = await db
      //       .documentStream(
      //           path: APIPath.jobGet(
      //               widget.model.img.toLowerCase().replaceAll(' ', '')),
      //           builder: (data, documentID) {
      //             log('img : ${data['img']}');
      //             return data['img'];
      //           })
      //       .single;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    const fontSize = 16.0;
    var _size = MediaQuery.of(context).size;
    return Container(
      // color: model.isHeader ? Colors.indigo[100] : null,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //*** PRJ-2.2 */
      child: widget.model.isHeader
          ? Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  Text('${widget.model.leadingText}'),
                  Expanded(
                    child: Divider(
                      indent: 20.0,
                      thickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : widget.model.leadingText.compareTo('All Workouts') == 0
              ? SizedBox(height: 0) //All Workouts
              : Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8.0),
                  height: _size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1, 3),
                      ),
                    ],
                  ),
                  // margin: EdgeInsets.all(10),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      0: FixedColumnWidth(_size.width * 0.2),
                      1: FixedColumnWidth(_size.width * 0.1),
                      2: FixedColumnWidth(_size.width * 0.3),
                      3: FixedColumnWidth(_size.width * 0.5),
                    },
                    children: [
                      TableRow(
                        children: [
                          widget.model.img.isEmpty
                              ? Text(
                                  '${widget.model.leadingText}',
                                )
                              : FutureBuilder(
                                  future: db
                                      .documentStream(
                                          path: APIPath.jobGet(widget.model.img
                                              .toLowerCase()
                                              .replaceAll(' ', '')),
                                          builder: (data, documentID) {
                                            // log('img : ${data['img']}');
                                            return data['img'];
                                          })
                                      .first,
                                  builder: (ctx, snapshot) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: [
                                          Image.network(
                                            snapshot.data,
                                            height: _size.height * 0.05,
                                          ),
                                          Text(
                                            '${widget.model.leadingText}',
                                          ),
                                        ],
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                          VerticalDivider(
                            thickness: 1,
                            color: Colors.red,
                          ),
                          Text(
                            '${widget.model.trailingText}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${widget.model.middleText}cal.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

      // child: Row(
      //   children: <Widget>[
      //     Text(model.leadingText, style: TextStyle(fontSize: fontSize)),
      //     Expanded(child: Container()),
      //     if (model.middleText != null)
      //       Text(
      //         model.middleText,
      //         style: TextStyle(color: Colors.green[700], fontSize: fontSize),
      //         textAlign: TextAlign.right,
      //       ),
      //     SizedBox(
      //       width: 60.0,
      //       child: Text(
      //         model.trailingText,
      //         style: TextStyle(fontSize: fontSize),
      //         textAlign: TextAlign.right,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
