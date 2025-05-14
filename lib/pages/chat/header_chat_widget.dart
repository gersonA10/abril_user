// import 'package:flutter/material.dart';
// import 'package:flutter_user/styles/styles.dart';
// import 'package:flutter_user/widgets/widgets.dart';

// class HeaderChatWidget extends StatelessWidget {
//   const HeaderChatWidget({
//     super.key,
//     required this.driverName,
//     required this.carDetail,
//   });

  // final String driverName;
  // final String carDetail;

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.sizeOf(context);

//     return Row(
//       children: [
//         IconButton(
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//         Expanded(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               MyText(
//                 text: driverName,
//                 size: media.width * sixteen,
//                 fontweight: FontWeight.bold,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(
//                 height: media.width * 0.025,
//               ),
//               MyText(
//                 text: carDetail,
//                 size: media.width * fourteen,
//                 maxLines: 1,
//                 textAlign: TextAlign.center,
//                 color: const Color(0xff8A8A8A),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderChatWidget extends StatelessWidget {
  const HeaderChatWidget(
      {super.key, required this.driverName, required this.carDetail, required this.profilePicture});

  final String driverName;
  final String carDetail;
  final String profilePicture;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return Container(
      margin: EdgeInsets.only(top: media.height * 0.055),
      height: media.height * 0.07,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.c,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicture),
            radius: 24,
          ),
          SizedBox(
            width: 10,
          ),
           Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    driverName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    carDetail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      // fontWeight: FontWeight,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
    //  Stack(
    //   children: [
    //     Container(
    //       height: media.height * 0.14,
    //     ),
    //     Positioned(
    //       left: 16,
    //       top: 60,
    //       child: Row(
    //         children: [
    //           GestureDetector(
    //             onTap: () {
    //               Navigator.pop(context);
    //             },
    //             child: const Icon(
    //               Icons.arrow_back,
    //               color: Colors.white,
    //             ),
    //           ),
    //           CircleAvatar(
    //             backgroundImage: NetworkImage(profilePicture),
    //             radius: 24,
    //           ),
    //           const SizedBox(width: 10),
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 driverName,
    //                 style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               Text(
    //                 carDetail,
    //                 style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontSize: 18,
    //                   // fontWeight: FontWeight,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}
