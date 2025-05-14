import 'package:flutter/material.dart';
import 'package:flutter_user/translations/translation.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../splash screen/loading.dart';
import '../noInternet/nointernet.dart';
import 'history.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;

class HistoryDetails extends StatefulWidget {
  const HistoryDetails({super.key});

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();
}

String complaintDesc = '';
int complaintType = 0;

class _HistoryDetailsState extends State<HistoryDetails> {
  String _error = '';

  @override
  void initState() {
    init();
    makecomplaint = 0;
    makecomplaintbool = false;
    _isLoading = false;
    _tripStops = myHistory[selectedHistory]['requestStops']['data'];
    getData();
    super.initState();
  }

  init() async {
    await initializeDateFormatting('es_ES', null);
  }

  List _tripStops = [];

  bool _showOptions = false;

  getData() async {
    setState(() {
      complaintType = 0;
      complaintDesc = '';
      generalComplaintList = [];
    });

    await getGeneralComplaint("request");
    setState(() {
      _isLoading = false;
      if (generalComplaintList.isNotEmpty) {
        complaintType = 0;
      }
    });
  }

  bool _cancelRide = false;
  var _cancelId = '';
  int? inti;
  int makecomplaint = 0;
  bool makecomplaintbool = false;
  bool _isLoading = false;
  TextEditingController complaintText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            SizedBox(
              height: media.height * 1,
              width: media.width * 1,
              // color: Colors.amber,
              //history details
              child: Column(
                children: [
                  // SizedBox(height: media.width * 0.05),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        media.width * 0.05,
                        media.width * 0.05 + MediaQuery.of(context).padding.top,
                        media.width * 0.05,
                        media.width * 0.05),
                    color: page,
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child:
                                Icon(Icons.arrow_back_ios, color: textColor)),
                        Expanded(
                          child: MyText(
                            textAlign: TextAlign.center,
                            text: languages[choosenLanguage]
                                ['text_tripsummary'],
                            size: media.width * twenty,
                            maxLines: 1,
                            fontweight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: media.width * 1,
                    color:page,
                    
                    padding: EdgeInsets.fromLTRB(
                        media.width * 0.04,
                        media.width * 0.02,
                        media.width * 0.04,
                        media.width * 0.02),
                    child: Container(
                      height: media.height * 0.65,
                      padding: EdgeInsets.all(media.width * 0.03),
                      decoration: BoxDecoration(
                          // color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0.0, 3.0)
                            )
                          ],
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(media.width * 0.02)),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // MyText(text: myHistory[selectedHistory][''], size: media.width * 0.05),
                                          (myHistory[selectedHistory]
                                                  ['completed_ride'])
                                              ? MyText(
                                                  text: 'COMPLETADO',
                                                  size: media.width * 0.035,
                                                  color: Colors.green,
                                                  fontweight: FontWeight.bold,
                                                )
                                              : MyText(
                                                  text: 'COMPLETADO',
                                                  size: media.width * 0.035,
                                                  color: theme,
                                                  fontweight: FontWeight.bold,
                                                ),
                                          MyText(
                                            text: (myHistory[selectedHistory]
                                                        ['later_ride'] ==
                                                    true)
                                                ? myHistory[selectedHistory]
                                                    ['trip_start_time']
                                                : (myHistory[selectedHistory][
                                                            'cancelled_ride'] ==
                                                        true)
                                                    ? myHistory[selectedHistory][
                                                        'converted_cancelled_at']
                                                    : (myHistory[selectedHistory]['completed_ride'] ==
                                                            true)
                                                        ? intl.DateFormat(
                                                                "d 'de' MMMM - hh:mm a", "es_ES")
                                                            .format(
                                                                intl.DateFormat("d'th' MMM hh:mm a")
                                                                    .parse(
                                                            myHistory[selectedHistory]
                                                                    [
                                                                    'converted_completed_at']
                                                                .toString(),
                                                          ))
                                                        // myHistory[selectedHistory]
                                                        //         [
                                                        //         'converted_completed_at']
                                                        //     .toString()
                                                        : myHistory[selectedHistory]
                                                                ['converted_created_at']
                                                            .toString(),
                                            size: media.width * fourteen,
                                            color: textColor.withOpacity(0.5),
                                          ),
                                          // Row(
                                          //   children: [
                                          //     MyText(
                                          //       text: (myHistory[
                                          //                       selectedHistory]
                                          //                   ['payment_opt'] ==
                                          //               '1')
                                          //           ? languages[
                                          //                   choosenLanguage]
                                          //               ['text_cash']
                                          //           : (myHistory[selectedHistory]
                                          //                       [
                                          //                       'payment_opt'] ==
                                          //                   '2')
                                          //               ? languages[
                                          //                       choosenLanguage]
                                          //                   ['text_wallet']
                                          //               : (myHistory[selectedHistory]
                                          //                           [
                                          //                           'payment_opt'] ==
                                          //                       '0')
                                          //                   ? languages[
                                          //                           choosenLanguage]
                                          //                       ['text_card']
                                          //                   : '',
                                          //       size: media.width * fourteen,
                                          //       color: textColor,
                                          //       fontweight: FontWeight.bold,
                                          //     ),
                                          //     SizedBox(
                                          //       width: media.width * 0.02,
                                          //     ),
                                          //     MyText(
                                          //         text: (myHistory[selectedHistory][
                                          //                     'is_bid_ride'] ==
                                          //                 1)
                                          //             ? myHistory[selectedHistory][
                                          //                     'requested_currency_symbol'] +
                                          //                 ' ' +
                                          //                 myHistory[selectedHistory]['accepted_ride_fare']
                                          //                     .toString()
                                          //             : (myHistory[selectedHistory]['is_completed'] ==
                                          //                     1)
                                          //                 ? myHistory[selectedHistory]['requestBill']
                                          //                             ['data'][
                                          //                         'requested_currency_symbol'] +
                                          //                     ' ' +
                                          //                     myHistory[selectedHistory]['requestBill']['data']['total_amount']
                                          //                         .toString()
                                          //                 : myHistory[selectedHistory]
                                          //                         ['requested_currency_symbol'] +
                                          //                     ' ' +
                                          //                     myHistory[selectedHistory]['request_eta_amount'].toString(),
                                          //         fontweight: FontWeight.bold,
                                          //         size: media.width * fourteen),
                                          //   ],
                                          // )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.width * 0.04,
                                  ),
                                  const MySeparator(),
                                  if (myHistory[selectedHistory]
                                          ['driverDetail'] !=
                                      null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: media.width * 0.04,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                        media.width * 0.13,
                                                    width: media.width * 0.13,
                                                    decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                myHistory[selectedHistory]
                                                                            [
                                                                            'driverDetail']
                                                                        [
                                                                        'data']
                                                                    [
                                                                    'profile_picture']),
                                                            fit: BoxFit
                                                                .cover)),
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.05,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      MyText(
                                                        text: myHistory[selectedHistory]
                                                                    [
                                                                    'driverDetail']
                                                                [
                                                                'data']['name']
                                                            .toString(),
                                                        size: media.width *
                                                            sixteen,
                                                        maxLines: 1,
                                                      ),
                                                      if (myHistory[
                                                                  selectedHistory]
                                                              [
                                                              'ride_user_rating'] !=
                                                          null)
                                                        Row(
                                                          children: [
                                                           
                                                            if (myHistory[
                                                                  selectedHistory]
                                                              [
                                                              'ride_user_rating'] !=
                                                          null)
                                                        Icon(
                                                          Icons.star,
                                                          size: media.width *
                                                              twenty,
                                                          color: Colors
                                                              .yellow[600],
                                                        ),
                                                            const SizedBox(width: 10,),
                            
                                                         MyText(
                                                              text: myHistory[
                                                                          selectedHistory]
                                                                      [
                                                                      'ride_user_rating']
                                                                  .toString(),
                                                              size: media.width *
                                                                  eighteen,
                                                              fontweight:
                                                                  FontWeight.w600,
                                                              color: textColor,
                                                            ),
                                                          ],
                                                        ),
                                                      
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: media.width * 0.04,
                                        ),
                                        const MySeparator()
                                      ],
                                    ),
                                  
                                  SizedBox(
                                    height: media.width * 0.04,
                                  ),
                                    Row(
                                                              children: [
                                                                Container(
                                                                  width: (myHistory[selectedHistory][ 'drop_address'] !=null) ? media.width * 0.7 : media.width * 0.8,
                                                                  padding: const EdgeInsets.all(10),
                                                                              // margin: const EdgeInsets.symmetric(horizontal: 0, vertical:10),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(20),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    blurRadius: 3,
                                                                                    offset: const Offset(0.0, 4.0),
                                                                                    color: Colors.black.withOpacity(0.1)
                                                                                  )
                                                                                ]
                                                                              ),
                                                                  
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        height: media
                                                                                .width *
                                                                            0.05,
                                                                        width: media
                                                                                .width *
                                                                            0.05,
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        decoration: BoxDecoration(
                                                                            shape: BoxShape
                                                                                .circle,
                                                                            color: Colors
                                                                                .green
                                                                                .withOpacity(
                                                                                    0.4)),
                                                                        child:
                                                                            Container(
                                                                          height: media
                                                                                  .width *
                                                                              0.025,
                                                                          width: media
                                                                                  .width *
                                                                              0.025,
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape
                                                                                  .circle,
                                                                              color: Colors
                                                                                  .green),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media
                                                                                .width *
                                                                            0.03,
                                                                      ),
                                                                      Expanded(
                                                                        child: MyText(
                                                                          text: myHistory[
                                                                                  selectedHistory][
                                                                              'pick_address'],
                                                                          maxLines: 1,
                                                                          size: media
                                                                                  .width *
                                                                              twelve,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10,),
                                                                (myHistory[selectedHistory][ 'drop_address'] !=null)
                                                                      ? Container(
                                                                              height: media.width * 0.09,
                                                                              width: media.width * 0.09,
                                                                              alignment: Alignment.center,
                                                                              decoration:  BoxDecoration(
                                                                                
                                                                                shape: BoxShape.circle, color: Colors.white,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black.withOpacity(0.2),
                                                                                    blurRadius: 5,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.location_on_rounded,
                                                                                color: theme,
                                                                                size: media.width * eighteen,
                                                                              ),
                                                                            )
                                                                      : Container(),
                                                              
                                                              ],
                                                            ),
                                  SizedBox(
                                    height: media.width * 0.02,
                                  ),
                                  Column(
                                    children: _tripStops
                                        .asMap()
                                        .map((i, value) {
                                          return MapEntry(
                                              i,
                                              (i < _tripStops.length - 1)
                                                  ? Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: media
                                                                      .width *
                                                                  0.06,
                                                              width: media
                                                                      .width *
                                                                  0.06,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          0.3)),
                                                              child: MyText(
                                                                text: (i + 1)
                                                                    .toString(),
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                                maxLines: 1,
                                                                color:
                                                                    verifyDeclined,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: media
                                                                      .width *
                                                                  0.05,
                                                            ),
                                                            Expanded(
                                                              child: MyText(
                                                                text: _tripStops[
                                                                        i][
                                                                    'address'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                                // maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              media.width *
                                                                  0.02,
                                                        ),
                                                      ],
                                                    )
                                                  : Container());
                                        })
                                        .values
                                        .toList(),
                                  ),
                                  // (myHistory[selectedHistory]
                                  //             ['drop_address'] !=
                                  //         null)
                                  //     ? Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.start,
                                  //         children: [
                                  //           Container(
                                  //             height: media.width * 0.06,
                                  //             width: media.width * 0.06,
                                  //             alignment: Alignment.center,
                                  //             child: Icon(
                                  //               Icons.location_on,
                                  //               color:
                                  //                   const Color(0xFFFF0000),
                                  //               size: media.width * eighteen,
                                  //             ),
                                  //           ),
                                  //           SizedBox(
                                  //             width: media.width * 0.05,
                                  //           ),
                                  //           Expanded(
                                  //             child: MyText(
                                  //               text:
                                  //                   myHistory[selectedHistory]
                                  //                       ['drop_address'],
                                  //               size: media.width * twelve,
                                  //               // maxLines: 1,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       )
                                  //     : Container(),
                                  SizedBox(
                                    height: media.width * 0.07,
                                  ),
                                  (myHistory[selectedHistory]
                                              ['is_completed'] ==
                                          1)
                                      ? Container(
                                          height: media.width * 0.2,
                                          width: media.width * 0.7,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(
                                              media.width * 0.03),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: hintColor),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.02)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_distance'],
                                                    size: media.width *
                                                        fourteen,
                                                        color: theme,
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text: myHistory[
                                                                selectedHistory]
                                                            [
                                                            'total_distance'] +
                                                        ' ' +
                                                        myHistory[
                                                                selectedHistory]
                                                            ['unit'],
                                                    size:
                                                        media.width * 0.035,
                                                    fontweight:
                                                        FontWeight.w700,
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: 1,
                                                height: media.width * 0.18,
                                                color: hintColor,
                                              ),
                                              Column(
                                                children: [
                                                  MyText(
                                                    color: theme,
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_duration'],
                                                    size: media.width *
                                                        fourteen,
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text:
                                                        '${myHistory[selectedHistory]['total_time']} ${languages[choosenLanguage]['text_mins']}',
                                                    size:
                                                        media.width * 0.035,
                                                    fontweight:
                                                        FontWeight.w700,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: media.width * 0.04,
                                  ),
                                  SizedBox(
                                    height: media.height * 0.02,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //make complaints
                          (myHistory[selectedHistory]['is_completed'] == 1)
                              ? Container(
                                  padding: EdgeInsets.fromLTRB(
                                      media.width * 0.03,
                                      media.width * 0.02,
                                      media.width * 0.03,
                                      media.width * 0.02),
                                  child: Button(
                                      onTap: () {
                                        setState(() {
                                          _error = '';
                  
                                          makecomplaintbool = true;
                                          makecomplaint = 1;
                                          complaintText.text = '';
                                        });
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_make_complaints']),
                                )
                              : (myHistory[selectedHistory]['is_later'] ==
                                          1 &&
                                      myHistory[selectedHistory]
                                              ['is_cancelled'] ==
                                          0)
                                  ? Container(
                                      padding: EdgeInsets.fromLTRB(
                                          media.width * 0.03,
                                          media.width * 0.02,
                                          media.width * 0.03,
                                          media.width * 0.02),
                                      child: Button(
                                          onTap: () {
                                            setState(() {
                                              _cancelRide = true;
                                              inti = selectedHistory;
                                              _cancelId =
                                                  myHistory[selectedHistory]
                                                      ['id'];
                                            });
                                          },
                                          text: languages[choosenLanguage]
                                              ['text_cancel_ride']),
                                    )
                                  : Container(),
                       
                       ],
                     
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (_cancelRide == true)
                ? Positioned(
                    child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: media.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    height: media.height * 0.1,
                                    width: media.width * 0.1,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: page),
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _cancelRide = false;
                                            _cancelId = '';
                                          });
                                        },
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          color: textColor,
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(media.width * 0.05),
                            width: media.width * 0.9,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: page),
                            child: Column(
                              children: [
                                MyText(
                                  text: languages[choosenLanguage]
                                      ['text_ridecancel'],
                                  size: media.width * eighteen,
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Button(
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var val =
                                          await cancelLaterRequest(_cancelId);
                                      if (val == 'success') {
                                        historyFiltter = '';
                                        await getHistory();
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      }

                                      setState(() {
                                        _cancelRide = false;
                                        _cancelId = '';
                                      });
                                    },
                                    text: languages[choosenLanguage]
                                        ['text_cancel_ride'])
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            (makecomplaintbool == true)
                ? Positioned(
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: media.height * 1,
                    width: media.width * 1,
                    color: Colors.transparent.withOpacity(0.6),
                    child: Column(
                      children: [
                        SizedBox(
                          height: media.height * 0.1,
                        ),
                        Container(
                          padding: EdgeInsets.all(media.width * 0.03),
                          height: media.width * 0.12,
                          width: media.width * 1,
                          decoration: BoxDecoration(color: topBar, boxShadow: [
                            BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 1,
                                color: Colors.grey.withOpacity(0.2))
                          ]),
                          // color: topBar,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    makecomplaintbool = false;
                                    makecomplaint = 1;
                                  });
                                },
                                child: (makecomplaint == 1)
                                    ? MyText(
                                        text: 'Cancel',
                                        size: media.width * fourteen,
                                        color: const Color(0xffFF0000),
                                      )
                                    : SizedBox(
                                        height: media.width * 0.06,
                                        width: media.width * 0.06,
                                        child: const Icon(
                                          Icons.close,
                                          // size: media.width * twentyfour,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: media.width * 0.25,
                              ),
                              MyText(
                                text: languages[choosenLanguage]
                                    ['text_make_complaints'],
                                size: media.width * sixteen,
                                color: (isDarkTheme == true)
                                    ? Colors.black
                                    : textColor,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                              width: media.width * 1,
                              padding: EdgeInsets.all(media.width * 0.04),
                              color: page,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: (makecomplaint == 1)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_why_report'],
                                                size: media.width * sixteen,
                                                fontweight: FontWeight.w700,
                                              ),
                                              SizedBox(
                                                height: media.width * 0.03,
                                              ),
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_we_apriciate'],
                                                size: media.width * fourteen,
                                                color:
                                                    textColor.withOpacity(0.3),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.03,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (_showOptions == false) {
                                                      _showOptions = true;
                                                    } else {
                                                      _showOptions = false;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: media.width * 0.05,
                                                      right:
                                                          media.width * 0.05),
                                                  height: media.width * 0.12,
                                                  width: media.width * 0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderLines,
                                                          width: 1.2)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      MyText(
                                                        text: generalComplaintList[
                                                                complaintType]
                                                            ['title'],
                                                        size: media.width *
                                                            fourteen,
                                                      ),
                                                      RotatedBox(
                                                        quarterTurns:
                                                            (_showOptions ==
                                                                    true)
                                                                ? 2
                                                                : 0,
                                                        child: Container(
                                                          height: media.width *
                                                              0.07,
                                                          width: media.width *
                                                              0.07,
                                                          decoration: const BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/chevron-down.png'),
                                                                  fit: BoxFit
                                                                      .contain)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              (_showOptions == true)
                                                  ? Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.02),
                                                      margin: EdgeInsets.only(
                                                          bottom: media.width *
                                                              0.05),
                                                      height: media.width * 0.3,
                                                      width: media.width * 0.9,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            width: 1.2,
                                                            color: borderLines),
                                                        color: page,
                                                      ),
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        child: Column(
                                                          children:
                                                              generalComplaintList
                                                                  .asMap()
                                                                  .map((i,
                                                                      value) {
                                                                    return MapEntry(
                                                                        i,
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              complaintType = i;
                                                                              _showOptions = false;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                media.width * 0.7,
                                                                            padding:
                                                                                EdgeInsets.only(top: media.width * 0.025, bottom: media.width * 0.025),
                                                                            decoration:
                                                                                BoxDecoration(border: Border(bottom: BorderSide(width: 1.1, color: (i == generalComplaintList.length - 1) ? Colors.transparent : borderLines))),
                                                                            child:
                                                                                MyText(
                                                                              text: generalComplaintList[i]['title'],
                                                                              size: media.width * fourteen,
                                                                            ),
                                                                          ),
                                                                        ));
                                                                  })
                                                                  .values
                                                                  .toList(),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.025),
                                                width: media.width * 0.9,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: (_error == '')
                                                            ? borderLines
                                                            : Colors.red,
                                                        width: 1.2)),
                                                child: MyTextField(
                                                  textController: complaintText,
                                                  hinttext: languages[
                                                              choosenLanguage]
                                                          ['text_complaint_2'] +
                                                      ' (' +
                                                      languages[choosenLanguage]
                                                          ['text_complaint_3'] +
                                                      ')',
                                                  maxline: 5,
                                                  onTap: (val) {
                                                    if (val.length >= 10 &&
                                                        _error != '') {
                                                      setState(() {
                                                        _error = '';
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              if (_error != '')
                                                Container(
                                                  width: media.width * 0.9,
                                                  padding: EdgeInsets.only(
                                                      top: media.width * 0.025,
                                                      bottom:
                                                          media.width * 0.025),
                                                  child: MyText(
                                                    text: _error,
                                                    size:
                                                        media.width * fourteen,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                            ],
                                          )
                                        : (makecomplaint == 2)
                                            ? Column(
                                                children: [
                                                  SizedBox(
                                                    height: media.width * 0.3,
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: media.width * 0.13,
                                                    width: media.width * 0.13,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: const Color(
                                                          0xffFF0000),
                                                      gradient: LinearGradient(
                                                          colors: <Color>[
                                                            const Color(
                                                                0xffFF0000),
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                          ],
                                                          begin:
                                                              FractionalOffset
                                                                  .topCenter,
                                                          end: FractionalOffset
                                                              .bottomCenter),
                                                    ),
                                                    child: Icon(
                                                      Icons.done,
                                                      size: media.width * 0.09,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.03,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_thanks_let'],
                                                    size: media.width * sixteen,
                                                    fontweight: FontWeight.w700,
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.03,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage][
                                                        'text_thanks_feedback'],
                                                    size:
                                                        media.width * fourteen,
                                                    color: textColor
                                                        .withOpacity(0.4),
                                                  )
                                                ],
                                              )
                                            : Container(),
                                  ),
                                  Button(
                                      onTap: () async {
                                        if (makecomplaint == 1) {
                                          if (complaintText.text.length >= 10) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            complaintDesc = complaintText.text;
                                            dynamic result;
                                            result =
                                                await makeRequestComplaint();
                                            if (result == 'success') {
                                              setState(() {
                                                makecomplaint = 2;
                                                _isLoading = false;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              _error = languages[
                                                      choosenLanguage]
                                                  ['text_complaint_text_error'];
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            makecomplaintbool = false;
                                            makecomplaint = 1;
                                          });
                                        }
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_continue'])
                                ],
                              )),
                        )
                      ],
                    ),
                  ))
                : Container(),
            (_isLoading == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),
            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        internetTrue();
                      },
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
