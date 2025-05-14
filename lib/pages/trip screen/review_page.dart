import 'package:flutter/material.dart';
import 'package:flutter_user/widgets/estados_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../splash screen/loading.dart';
import '../login/login.dart';
import 'map_page.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

double review = 0.0;
int active = 0;
String feedback = '';
String feedbackTag = '';

class _ReviewState extends State<Review> {
  bool _loading = false;

  @override
  void initState() {
    review = 0.0;
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

  //navigate
  navigate() {
    dropStopList.clear();
    addressList.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Maps()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      padding: EdgeInsets.all(media.width * 0.05),
                      color: page,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            Column(
                              children: [
                                (userRequestData.isNotEmpty)
                                    ? Container(
                                        height: media.width * 0.25,
                                        width: media.width * 0.25,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    userRequestData[
                                                                'driverDetail']
                                                            ['data']
                                                        ['profile_picture']),
                                                fit: BoxFit.cover)),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: media.height * 0.03,
                                ),
                                MyText(
                                  text: (userRequestData.isNotEmpty)
                                      ? userRequestData['driverDetail']
                                          ['data']['name']
                                      : '',
                                  size: 18,
                                  fontweight: FontWeight.bold,
                                ),
                                SizedBox(
                                  height: media.height * 0.02,
                                ),
                                Divider(
                                  color: borderColor,
                                ),
                                SizedBox(
                                  height: media.height * 0.02,
                                ),
                              
                                //stars
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            review = 1.0;
                                          });
                                        },
                                        child: Icon(
                                          Icons.star,
                                          size: 45,
                                          color: (review >= 1)
                                              // ? buttonColor
                                              ? startColor
                                              : Colors.grey,
                                        )),
                                    SizedBox(
                                      width: media.width * 0.02,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            review = 2.0;
                                          });
                                        },
                                        child: Icon(
                                          Icons.star,
                                          size: 45,
                                          color: (review >= 2)
                                              // ? buttonColor
                                              ? startColor
                                              : Colors.grey,
                                        )),
                                    SizedBox(
                                      width: media.width * 0.02,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            review = 3.0;
                                          });
                                        },
                                        child: Icon(
                                          Icons.star,
                                          size: 45,
                                          color: (review >= 3)
                                              // ? buttonColor
                                              ? startColor
                                              : Colors.grey,
                                        )),
                                    SizedBox(
                                      width: media.width * 0.02,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            review = 4.0;
                                          });
                                        },
                                        child: Icon(
                                          Icons.star,
                                          size: 45,
                                          color: (review >= 4)
                                              // ? buttonColor
                                              ? startColor
                                              : Colors.grey,
                                        )),
                                    SizedBox(
                                      width: media.width * 0.02,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            review = 5.0;
                                          });
                                        },
                                        child: Icon(
                                          Icons.star,
                                          size: 45,
                                          color: (review == 5)
                                              // ? buttonColor
                                              ? startColor
                                              : Colors.grey,
                                        ))
                                  ],
                                ),
                              
                                SizedBox(
                                  height: media.height * 0.05,
                                ),
                              
                                Wrap(
                                  runAlignment: WrapAlignment.start,
                                  alignment: WrapAlignment.start,
                                  children: [
                                    TagWidget(
                                      label: "Muy Amable",
                                      active: (active == 5),
                                      onPressed: () {
                                        setState(() {
                                          feedbackTag = "Muy Amable";
                                          active = 5;
                                        });
                                      },
                                    ),
                                    TagWidget(
                                      label: "Es puntual",
                                      active: (active == 4),
                                      onPressed: () {
                                        setState(() {
                                          feedbackTag = "Es puntual";
                                          active = 4;
                                        });
                                      },
                                    ),
                                    TagWidget(
                                      label: "Su vehículo es limpio",
                                      active: (active == 3),
                                      onPressed: () {
                                        setState(() {
                                          feedbackTag =
                                              "Su vehículo es limpio";
                                          active = 3;
                                        });
                                      },
                                    ),
                                    TagWidget(
                                      label: "Asientos incómodos",
                                      active: (active == 2),
                                      onPressed: () {
                                        setState(() {
                                          feedbackTag = "Asientos incómodos";
                                          active = 2;
                                        });
                                      },
                                    ),
                                    TagWidget(
                                      label: "Satisfactorio",
                                      active: (active == 1),
                                      onPressed: () {
                                        setState(() {
                                          feedbackTag = "Satisfactorio";
                                          active = 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                //feedback text
                                Container(
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1.5,
                                          color: isDarkTheme == true
                                              ? Colors.grey
                                              : Colors.grey
                                                  .withOpacity(0.1))),
                                  child: TextField(
                                    maxLines: 4,
                                    onChanged: (val) {
                                      setState(() {
                                        feedback = val;
                                      });
                                    },
                                    style: GoogleFonts.notoSans(
                                        color: textColor),
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                        hintText: languages[choosenLanguage]
                                            ['text_feedback'],
                                        hintStyle: GoogleFonts.notoSans(
                                            color: isDarkTheme == true
                                                ? textColor.withOpacity(0.4)
                                                : Colors.grey
                                                    .withOpacity(0.6)),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: media.height * 0.05,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.height * 0.1,
                            ),
                            Button(
                              onTap: () async {
                                setState(() {
                                iniciarViaje = false;
                                });
                              
                                if (review >= 1.0) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  var result = await userRating();
                              
                                  if (result == true) {
                                    navigate();
                                    _loading = false;
                                  } else if (result == 'logout') {
                                    navigateLogout();
                                  } else {
                                    setState(() {
                                      _loading = false;
                                    });
                                  }
                                }
                              },
                              text: 'Confirmar',
                              color: (review >= 1.0) ? theme : Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ),
                    //loader
                    (_loading == true)
                        ? const Positioned(child: Loading())
                        : Container()
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final bool active;
  final String label;
  final void Function()? onPressed;
  const TagWidget(
      {super.key,
      required this.active,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: (active) ? theme.withOpacity(0.2) : page,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: (active) ? theme : borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(0)),
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: TextStyle(color: (active) ? theme : textColor),
          ),
        ),
      ),
    );
  }
}
