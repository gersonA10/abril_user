// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_user/functions/functions.dart';
// import 'package:http/http.dart' as http;

// String url = 'https://15deabril.macrobyte.site/';
// List<BearerClass> bearerToken = <BearerClass>[];

// class CancelRequestProvider extends ChangeNotifier {
//   cancelRequest() async {
//     dynamic result;
//     try {
//       var response = await http.post(Uri.parse('${url}api/v1/request/cancel'),
//           headers: {
//             'Authorization': 'Bearer ${bearerToken[0].token}',
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({'request_id': userRequestData['id']}));
//       if (response.statusCode == 200) {
//         userRequestData = {};
//         // userCancelled = true;
//         if (userRequestData['is_bid_ride'] == 1) {
//           FirebaseDatabase.instance
//               .ref('bid-meta/${userRequestData["id"]}')
//               .remove();
//         }
//         FirebaseDatabase.instance
//             .ref('requests')
//             .child(userRequestData['id'])
//             .update({'cancelled_by_user': true});
//         userRequestData = {};
//         notifyListeners();
//         if (requestStreamStart?.isPaused == false ||
//             requestStreamEnd?.isPaused == false) {
//           requestStreamStart?.cancel();
//           requestStreamEnd?.cancel();
//           requestStreamStart = null;
//           requestStreamEnd = null;
//         }
//         result = 'success';
//         valueNotifierBook.incrementNotifier();
//       } else if (response.statusCode == 401) {
//         result = 'logout';
//       } else {
//         debugPrint(response.body);
//         result = 'failed';
//       }
//     } catch (e) {
//       if (e is SocketException) {
//         internet = false;
//       }
//     }
//     return result;
//   }
// }
