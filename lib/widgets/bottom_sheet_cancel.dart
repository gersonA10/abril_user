// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_user/functions/functions.dart';
// import 'package:flutter_user/pages/onTripPage/booking_confirmation.dart';
// import 'package:flutter_user/styles/styles.dart';
// import 'package:flutter_user/translations/translation.dart';
// import 'package:flutter_user/widgets/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;

// class BottomSheetCancel extends StatefulWidget {
//   const BottomSheetCancel({super.key});

//   @override
//   State<BottomSheetCancel> createState() => _BottomSheetCancelState();
// }

// class _BottomSheetCancelState extends State<BottomSheetCancel> {
//     late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   void startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           if (timing > 0) {
//             timing--;
//           } else {
//             _timer.cancel();
//           }
//         });
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//     return Positioned(
//       bottom: 0,
//       child: Container(
//         width: media.width * 1,
//         height: media.height * 0.6,
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//           color: page,
//         ),
//         padding: EdgeInsets.all(media.width * 0.05),
//         child: Column(
//           children: [
//             SizedBox(
//               width: media.width * 0.9,
//               child: MyText(
//                 textAlign: TextAlign.center,
//                 text: languages[choosenLanguage]['text_search_captain'],
//                 size: media.width * fourteen,
//                 fontweight: FontWeight.bold,
//                 color: theme,
//               ),
//             ),
//             SizedBox(
//               height: media.height * 0.02,
//             ),
//             MyText(
//               text: languages[choosenLanguage]['text_finddriverdesc'],
//               size: media.width * fourteen,
//               // textAlign: TextAlign.center,
//             ),
//             SizedBox(
//               height: media.width * 0.5,
//               child: Image.asset(
//                 'assets/images/await_mobile.gif',
//                 fit: BoxFit.contain,
//               ),
//             ),
//             SizedBox(
//               height: media.height * 0.02,
//             ),
//              Container(
//               height: media.width * 0.048,
//               width: media.width * 0.9,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(media.width * 0.024),
//                 color: hintColor,
//               ),
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 height: media.width * 0.048,
//                 width: (media.width *
//                     0.9 *
//                     (timing /
//                         userDetails[
//                             'maximum_time_for_find_drivers_for_regular_ride'])),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(media.width * 0.024),
//                     color: const Color(0xFFE16E6E)),
//               ),
//             ),
//             SizedBox(
//               height: media.height * 0.02,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 (timing != null)
//                     ? Text(
//                         '${Duration(seconds: timing).toString().substring(3, 7)} mins',
//                         style: GoogleFonts.notoSans(
//                             fontSize: media.width * ten,
//                             color: textColor.withOpacity(0.4)),
//                       )
//                     : Container()
//               ],
//             ),
//             SizedBox(
//               height: media.height * 0.02,
//             ),
//             Button(
//               width: media.width * 0.5,
//               onTap: () async {
//                 await cancelRequestData();
//                 // setState(() {
//                 //   widget.userData = {};
//                 // });
//               },
//               text: languages[choosenLanguage]['text_cancel'],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> cancelRequestData() async {
//     final response = await http.post(
//       Uri.parse('${url}api/v1/request/cancel'),
//       headers: {
//         'Authorization': 'Bearer ${bearerToken[0].token}',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(
//         {'request_id': userRequestData['id']},
//       ),
//     );

//     if (response.statusCode == 200) {
//       FirebaseDatabase.instance
//           .ref('requests')
//           .child(userRequestData['id'])
//           .update({'cancelled_by_user': true},
//       );
//       setState(() {
//        userRequestData = {};
//       });
//     }
//   }
// }
