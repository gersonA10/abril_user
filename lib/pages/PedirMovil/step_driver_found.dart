import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/models/driver_model.dart';
import 'package:flutter_user/pages/chat/chat_page.dart';
import 'package:flutter_user/pages/chat/image_view_screen.dart';
import 'package:flutter_user/pages/splash%20screen/loading.dart';
import 'package:flutter_user/providers/request_provider.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/estados_widget.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:latlong2/latlong.dart';

class StepDriverFound extends StatefulWidget {
  final DriverModel driver;
  final VoidCallback onMyLocationPressed;
  final VoidCallback onDriverLocationPressed;
  final Function(LatLng) onUpdateDriverLocation;

  const StepDriverFound({
    required this.driver,
    required this.onMyLocationPressed,
    required this.onDriverLocationPressed,
    required this.onUpdateDriverLocation,
  });

  @override
  State<StepDriverFound> createState() => _StepDriverFoundState();
}

class _StepDriverFoundState extends State<StepDriverFound> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _buttonOffset = 0.18;
  StreamSubscription? _driverLocationSubscription;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cancellingUser = false;
    _sheetController.addListener(_updateOffset);
    _listenToDriverLocation(widget.driver.driverId.toString());
    final requestProvider =
        Provider.of<RequestProvider>(context, listen: false);

    requestProvider.onDriverArrivedCallback = (requestId) {
      print('MOSTRANDO ALERT PARA: $requestId'); // <- Asegúrate que esto sale

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog.adaptive(
          content: SizedBox(
            height: 160,
            child: Column(
              children: [
                Text(
                  'El conductor ha llegado!',
                  style: GoogleFonts.montserrat(
                    color: const Color.fromARGB(255, 184, 1, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'El conductor está en su puerta',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    requestProvider.isAlertShowing = false;
                    aceptarBocina(requestId);
                  },
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }

  void _listenToDriverLocation(String driverId) async {
    await _driverLocationSubscription?.cancel();

    final driverRef = FirebaseDatabase.instance.ref('drivers/driver_$driverId');
    _driverLocationSubscription = driverRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final List<dynamic> location =
              data['l'] as List<dynamic>? ?? [0.0, 0.0];
          final lat = location[0] as double;
          final lng = location[1] as double;

          widget.onUpdateDriverLocation(LatLng(lat, lng));
        } catch (e) {
          print("Error parsing driver location: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _driverLocationSubscription?.cancel();
    _sheetController.removeListener(_updateOffset);
    _sheetController.dispose();
    super.dispose();
  }

  void _updateOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _buttonOffset = _sheetController.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final screenHeight = MediaQuery.of(context).size.height;
    final requestProvider = Provider.of<RequestProvider>(context);

    return Stack(
      children: [
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.18,
          minChildSize: 0.18,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: page,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kElevationToShadow[1],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Movil'.toString(),
                              style: GoogleFonts.montserrat(
                                  height: 0, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                widget.driver.nroMovil,
                                style: GoogleFonts.montserrat(
                                  color: textColor,
                                  fontSize: media.width * 0.085,
                                  fontWeight: FontWeight.w900,
                                  height: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // car_model_name
                                Text(
                                  "Licencia: ",
                                  style: GoogleFonts.montserrat(height: 0),
                                ),
                                SizedBox(
                                  width: media.width * 0.25,
                                  child: Text(
                                    widget.driver.driverLicense,
                                    style: GoogleFonts.montserrat(
                                        height: 0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Marca: ",
                                  style: GoogleFonts.montserrat(height: 0),
                                ),
                                SizedBox(
                                  width: media.width * 0.25,
                                  child: Text(
                                    widget.driver.brand,
                                    style: GoogleFonts.montserrat(
                                        height: 0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Color: ",
                                  style: GoogleFonts.montserrat(height: 0),
                                ),
                                SizedBox(
                                  width: media.width * 0.25,
                                  child: Text(
                                    widget.driver.color,
                                    style: GoogleFonts.montserrat(
                                        height: 0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // car_model_name
                                Text(
                                  "Placa: ",
                                  style: GoogleFonts.montserrat(height: 0),
                                ),
                                SizedBox(
                                  width: media.width * 0.25,
                                  child: Text(
                                    widget.driver.placa,
                                    style: GoogleFonts.montserrat(
                                        height: 0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Año: ",
                                  style: GoogleFonts.montserrat(height: 0),
                                ),
                                SizedBox(
                                  width: media.width * 0.25,
                                  child: Text(
                                    widget.driver.year,
                                    style: GoogleFonts.montserrat(
                                        height: 0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewScreen(
                                    imageUrl: widget.driver.photoVehicle),
                              ),
                            );
                          },
                          child: Image.network(
                            widget.driver.photoVehicle,
                            width: media.width * 0.2,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  EstadosWidget(media: media),
                  SecondInfoDriver(
                    media: media,
                    widget: widget,
                    onTapChat: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final ri = prefs.getString('requestIDRIDE');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    driver: widget.driver,
                                    requestId: ri,
                                  )));
                    }, onTapCancell:  () async {
        
                                        setState(() {
                                        cancelling = true;
                                        isLoading = true;
                                          
                                        });
                                        var reason = await cancelReasons(0);
                                        if (reason == true) {
                                          setState(() {
                                            cancellingError = '';
                                            cancelReason = '';
                                            cancelling = true;
        
                                          });
                                        }
                                          setState(() {
                                        cancelling = true;
                                        isLoading = false;
                                          
                                        });
                                      },
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: screenHeight * (_buttonOffset) + 20,
          right: 16,
          child: FloatingActionButton(
            onPressed: widget.onMyLocationPressed,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
        Positioned(
          bottom: screenHeight * (_buttonOffset) - 20,
          right: media.height * 0.20,
          child: Container(
              width: media.width *0.12,
              height: media.width *0.02,
              decoration: BoxDecoration(
              color: const Color.fromARGB(255, 198, 198, 198),
                borderRadius: BorderRadius.circular(20)
              ),
            )
        ),
        Positioned(
          bottom: screenHeight * (_buttonOffset) + 20,
          left: 16,
          child: Row(
            children: [
              FloatingActionButton(
                onPressed: widget.onDriverLocationPressed,
                backgroundColor: Colors.white,
                child: Icon(Icons.drive_eta_rounded,
                    color: theme, size: media.width * 0.068),
              ),
              const SizedBox(
                width: 8,
              ),
              FloatingActionButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final ri = prefs.getString('requestIDRIDE');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                                driver: widget.driver,
                                requestId: ri,
                              )));
                },
                backgroundColor: Colors.white,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: theme,
                  child: SizedBox(
                    height: media.width * 0.1,
                    width: media.width * 0.1,
                    child: Icon(Icons.chat,
                        color: theme, size: media.width * 0.068),
                  ),
                ),
              ),
            ],
          ),
        ),
        (cancelling == true)
            ? Positioned(
                child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        width: media.width * 0.9,
                        decoration: BoxDecoration(
                            color: page,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          MyText(
                            text: "Cancelar llamada",
                            size: 16,
                            fontweight: FontWeight.bold,
                            color: theme,
                          ),
                          Column(
                            children: cancelReasonsList
                                .asMap()
                                .map((i, value) {
                                  return MapEntry(
                                      i,
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            cancelReason =  cancelReasonsList[i]['reason'];
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.01),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: media.height * 0.05,
                                                width: media.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: theme,
                                                        width: 1.2)),
                                                alignment: Alignment.center,
                                                child: (cancelReason ==
                                                        cancelReasonsList[i]
                                                            ['reason'])
                                                    ? Container(
                                                        height:
                                                            media.width * 0.03,
                                                        width:
                                                            media.width * 0.03,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: theme,
                                                        ),
                                                      )
                                                    : Container(),
                                              ),
                                              SizedBox(
                                                width: media.width * 0.05,
                                              ),
                                              SizedBox(
                                                  width: media.width * 0.65,
                                                  child: MyText(
                                                    text: cancelReasonsList[i]
                                                        ['reason'],
                                                    size: media.width * twelve,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ));
                                })
                                .values
                                .toList(),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                cancelReason = 'others';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(media.width * 0.01),
                              child: Row(
                                children: [
                                  Container(
                                    height: media.height * 0.05,
                                    width: media.width * 0.05,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: theme, width: 1.2)),
                                    alignment: Alignment.center,
                                    child: (cancelReason == 'others')
                                        ? Container(
                                            height: media.width * 0.03,
                                            width: media.width * 0.03,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: theme,
                                            ),
                                          )
                                        : Container(),
                                  ),
                                  SizedBox(
                                    width: media.width * 0.05,
                                  ),
                                  MyText(
                                    text: languages[choosenLanguage]
                                        ['text_others'],
                                    size: media.width * twelve,
                                  )
                                ],
                              ),
                            ),
                          ),
                          (cancelReason == 'others')
                              ? Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 20),

                                  // height: media.width*0.2,
                                  width: media.width * 0.9,

                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: languages[choosenLanguage]
                                            ['text_cancelRideReason'],
                                        hintStyle: GoogleFonts.notoSans(
                                            color: textColor.withOpacity(0.4),
                                            fontSize: media.width * twelve)),
                                    style:
                                        GoogleFonts.notoSans(color: textColor),
                                    maxLines: 4,
                                    minLines: 2,
                                    onChanged: (val) {
                                      setState(() {
                                        cancelCustomReason = val;
                                      });
                                    },
                                  ),
                                )
                              : Container(),
                          (cancellingError != '')
                              ? Container(
                                  padding: EdgeInsets.only(
                                      top: media.width * 0.02,
                                      bottom: media.width * 0.02),
                                  width: media.width * 0.9,
                                  child: Text(cancellingError,
                                      style: GoogleFonts.notoSans(
                                          fontSize: media.width * twelve,
                                          color: Colors.red)))
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Button(
                                  borcolor: inputFillColorGrey,
                                  color: inputFillColorGrey,
                                  width: media.width * 0.39,
                                  onTap: () {
                                    setState(() {
                                      cancelling = false;
                                    });
                                  },
                                  text: languages[choosenLanguage]
                                      ['tex_dontcancel']),
                              Button(
                                  textcolor: buttonColor,
                                  width: media.width * 0.39,
                                  onTap: () async {

                                    if (cancelReason != '') {
                                      if (cancelReason == 'others') {
                                        if (cancelCustomReason != '' &&
                                            cancelCustomReason.isNotEmpty) {
                                          cancellingError = '';
                                          var val = await cancelRequestWithReason(cancelCustomReason);
                                          if (val == 'success') {
                                            requestProvider.cancelSearch();
                                            
                                          }
                                          setState(() {
                                            cancelling = false;
                                          });
                                        } else {
                                          setState(() {
                                          cancellingError =
                                                languages[choosenLanguage]
                                                    ['text_add_cancel_reason'];
                                          });
                                        }
                                      } else {
                                        var val = await cancelRequestWithReason(cancelReason);
                                        if (val == 'success') {
                                            requestProvider.cancelSearch();
                                            
                                          }
                                        cancelling = false;

                                      }
                                    } else {}
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_confirm']),
                            ],
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
        (isLoading == true)
        ? const Loading()
        : Container()
      ],
    );
  }
}

class SecondInfoDriver extends StatefulWidget {
   SecondInfoDriver({
    super.key,
    required this.media,
    required this.widget,
    required this.onTapChat,
    required this.onTapCancell,
  });

  final Size media;
  final StepDriverFound widget;
  final Function()? onTapChat;
  final Function()? onTapCancell;

  @override
  State<SecondInfoDriver> createState() => _SecondInfoDriverState();
}

class _SecondInfoDriverState extends State<SecondInfoDriver> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context);
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: EdgeInsets.all(widget.media.width * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: widget.media.width * 0.02,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                  imageUrl: widget.widget.driver.photoDriver),
                            ),
                          );
                        },
                        child: Container(
                          height: widget.media.width * 0.15,
                          width: widget.media.width * 0.15,
                          margin: const EdgeInsets.only(right: 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(widget.widget.driver.photoDriver),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: widget.widget.driver.name,
                              size: widget.media.width * sixteen,
                              fontweight: FontWeight.w700,
                              color: textColor,
                            ),
                            SizedBox(
                              height: widget.media.width * 0.01,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: startColor,
                                  size: widget.media.width * 0.05,
                                ),
                                SizedBox(
                                  width: widget.media.width * 0.005,
                                ),
                                Expanded(
                                  child: MyText(
                                    color: greyText,
                                    text: widget.widget.driver.rating.toString(),
                                    size: widget.media.width * fourteen,
                                    fontweight: FontWeight.w600,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            MyText(
                              text: 'Conductor Asignado',
                              size: widget.media.width * 0.03,
                              fontweight: FontWeight.w700,
                              color: textColor,
                            ),
                          ],
                        ),
                      ),
                      // if (userRequestData['is_trip_start'] == 0)
                      Row(
                        children: [
                          InkWell(
                            onTap: widget.onTapChat,
                            child: Stack(
                              alignment: const Alignment(1, -0.9),
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff484848)),
                                    width: widget.media.width * 0.14,
                                    child:
                                        Image.asset('assets/images/chat-alt.png')),
                                if (chatList
                                    .where((element) =>
                                        element['from_type'] == 2 &&
                                        element['seen'] == 0)
                                    .isNotEmpty)
                                  Container(
                                    height: widget.media.width * 0.02,
                                    width: widget.media.width * 0.02,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: verifyDeclined),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                   Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (userRequestData['is_trip_start'] != 1)
                                  ? InkWell(
                                      onTap: widget.onTapCancell,
                                      // () async {
        
                                      //   setState(() {
                                      //   cancelling = true;
                                      //   isLoading = true;
                                          
                                      //   });
                                      //   var reason = await cancelReasons(0);
                                      //   if (reason == true) {
                                      //     setState(() {
                                      //       cancellingError = '';
                                      //       cancelReason = '';
                                      //       cancelling = true;
        
                                      //     });
                                      //   }
                                      //     setState(() {
                                      //   cancelling = true;
                                      //   isLoading = false;
                                          
                                      //   });
                                      // },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                                'assets/images/cancel_mobile.png',
                                                width: 32),
                                            MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_cancel_booking'],
                                              size: 16,
                                              fontweight: FontWeight.w600,
                                              color: textColorGrey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      )
                ],
              ),
            ],
          ),
        ),
        // (isLoading == true)
        // ? const Loading()
        // : Container(),
      ],
    );
  }
}
