// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
// import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_user/functions/models/code_whats_app.dart';
// import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/functions/providers/sign_in_provider.dart';
import 'package:flutter_user/pages/splash%20screen/loading.dart';
import 'package:flutter_user/pages/login/login_with_number.dart';
import 'package:flutter_user/pages/login/modal_confirm.dart';
// import 'package:flutter_user/pages/login/verify_code.dart';
import 'package:flutter_user/pages/trip%20screen/invoice.dart';
import 'package:flutter_user/pages/trip%20screen/map_page.dart';
// import 'package:flutter_user/pages/referralcode/referral_code.dart';
// import 'package:flutter_user/translations/translation.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
// import '../loadingPage/loading.dart';
// import 'agreement.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

//code as int for getting phone dial code of choosen country
String phnumber = ''; // phone number as string entered in input field
// String phone = '';
List pages = [1, 2, 3, 4];
List images = [];
int currentPage = 0;

var values = 0;
bool isfromomobile = true;

dynamic proImageFile1;
ImagePicker picker = ImagePicker();
bool pickImage = false;
bool isverifyemail = false;
String email = ''; // email of user
String password = '';
String name = ''; //name of user
PhoneNumber? phone;

late StreamController profilepicturecontroller;
StreamSink get profilepicturesink => profilepicturecontroller.sink;
Stream get profilepicturestream => profilepicturecontroller.stream;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  TextEditingController nombre = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // final TextEditingController _mobile = TextEditingController();
  // final TextEditingController _email = TextEditingController();
  // final TextEditingController _password = TextEditingController();
  // final TextEditingController _name = TextEditingController();
  // final TextEditingController _otp = TextEditingController();
  // final TextEditingController _newPassword = TextEditingController();
  final TextEditingController resCode = TextEditingController();
  bool loginLoading = true;
  // final ScrollController _scroll = ScrollController();
  // final _pinPutController2 = TextEditingController();
  dynamic aController;
  // ignore: unused_field
  String _error = '';
  bool showSignin = false;
  // bool _resend = false;
  int signIn = 0;
  var searchVal = '';
  bool isLoginemail = true;
  bool withOtp = false;
  bool showPassword = false;
  bool showNewPassword = false;
  bool otpSent = false;
  // ignore: unused_field
  bool _resend = false;
  int resendTimer = 60;
  bool mobileVerified = false;
  dynamic resendTime;
  bool forgotPassword = false;
  bool newPassword = false;

  /// nuevas variables implementadas
  bool loaginGoogle = false;

  /// 1: googel auth; 2: send code: 3 verify Code; 4: register user;
  int stepAuth = 0;

  User? user;

  bool loadingSend = false;
  bool loadingRegister = false;
  int stepCode = 0;
  String number = '';
  CodeWhatsApp? code;
  bool active = false;

  resend() {
    resendTime?.cancel();
    resendTime = null;

    resendTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          _resend = true;
          resendTime?.cancel();
          timer.cancel();
          resendTime = null;
        }
      });
    });
  }

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true; //terms and conditions true or false

  @override
  void initState() {
    currentPage = 0;
    controller.text = '';
    proImageFile1 = null;
    gender = '';
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    countryCode();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    nombre.dispose();
    resCode.dispose();
    super.dispose();
  }

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

  navigate(verify) {
    if (verify == true) {
      if (userRequestData.isNotEmpty && userRequestData['is_completed'] == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Invoice()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
            (route) => false);
      }
    } else if (verify == false) {
      setState(() {
        _error =
            'User Doesn\'t exists with this number, please Signup to continue';
      });
    } else {
      _error = verify.toString();
    }
    loginLoading = false;
    valueNotifierLogin.incrementNotifier();
  }

  countryCode() async {
    isverifyemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (loginImages.isNotEmpty) {
      images.clear();
      for (var e in loginImages) {
        images.add(Image.network(
          e['onboarding_image'],
          gaplessPlayback: true,
          fit: BoxFit.cover,
        ));
      }
    }
    if (result == 'success') {
      setState(() {
        loginLoading = false;
      });
    } else {
      setState(() {
        loginLoading = false;
      });
    }
  }

  List landings = [
    {
      'heading': 'ASSURANCE',
      'text':
          'Customer safety first,Always and forever our pledge,Your well-being, our priority,With you every step, edge to edge.'
    },
    {
      'heading': 'CLARITY',
      'text':
          'Fair pricing, crystal clear, Your trust, our promise sincere. With us, you\'ll find no hidden fee, Transparency is our guarantee.'
    },
    {
      'heading': 'INTUTIVE',
      'text':
          'Seamless journeys, Just a tap away, Explore hassle-free, Every step of the way.'
    },
    {
      'heading': 'SUPPORT',
      'text':
          'Embark on your journey with confidence, knowing that our commitment to your satisfaction is unwavering'
    },
  ];

  var verifyEmailError = '';
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    if (stepAuth == 0) onboarding(media),
                    if (stepAuth == 1) FadeInUp(child: sendWhatsApp()),
                    (loginLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                );
              })),
    );
  }

  SizedBox onboarding(Size media) {
    return SizedBox(
      height: media.height,
      child: (loginImages.isNotEmpty)
          ? Column(
              children: [
                SizedBox(
                  height: media.height * 0.5,
                  width: media.width,
                  child: ClipPath(
                    // clipper: ShapePainter(),
                    child: images[currentPage],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: media.height * 0.18,
                  child: PageView(
                    onPageChanged: (v) {
                      setState(() {
                        currentPage = v;
                      });
                    },
                    children: loginImages
                        .asMap()
                        .map((k, value) => MapEntry(
                              k,
                              Column(
                                children: [
                                  MyText(
                                    text: loginImages[k]['title'],
                                    size: media.height * 0.02,
                                    fontweight: FontWeight.w600,
                                  ),
                                  SizedBox(
                                    height: media.height * 0.02,
                                  ),
                                  SizedBox(
                                    width: media.width * 0.6,
                                    child: MyText(
                                      text: loginImages[k]['description'],
                                      size: media.height * 0.015,
                                      maxLines: 4,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .values
                        .toList(),
                  ),
                ),
                SizedBox(
                  width: media.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loginImages
                        .asMap()
                        .map((k, value) => MapEntry(
                              k,
                              Container(
                                margin: EdgeInsets.only(
                                  right: (k < loginImages.length - 1)
                                      ? media.width * 0.025
                                      : 0,
                                ),
                                height: media.height * 0.01,
                                width: media.height * 0.01,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (currentPage == k)
                                        ? const Color(0xffFFD302)
                                        : Colors.grey),
                              ),
                            ))
                        .values
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                if (loaginGoogle)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/images/google-icon.png',
                            width: 26,
                          ),
                          onPressed: () async {
                            setState(() {
                              loaginGoogle = true;
                            });
                            var res = await SignInProvider().googleAuth();

                            if (res != null) {
                              var exist = await existsUser(res.email ?? "");
                              if (exist) {
                                setState(() {
                                  loaginGoogle = false;
                                  user = res;
                                });
                                navigateMap();
                                return;
                              } else {
                                setState(() {
                                  user = res;
                                  // print(user?.displayName);
                                  stepAuth = 1;
                                  loaginGoogle = false;
                                  nombre.text =
                                      user?.displayName ?? " Usuario Anónimo";
                                });
                                return;
                              }
                            }
                            setState(() {
                              loaginGoogle = false;
                            });
                          },
                          label: Text(
                            'Iniciar sesión con Google',
                            style: TextStyle(color: textColor),
                          )),
                      const SizedBox(height: 10),
                    ],
                  ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      icon: Image.asset(
                            'assets/images/whatsapp.png',
                            width: 32,
                          ),
                        onPressed: () async {
                          //  sendWhatsApp();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginWithNumber(),
                            ),
                          );
                        },
                        label: Text(
                          'Iniciar sesión con Whatsapp',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            )
          : Container(),
    );
  }

  TextStyle textStyle() {
    return TextStyle(color: textColorwhite, fontWeight: FontWeight.w500);
  }

  InputDecoration inputDecoration(
      {String hintText = "_ _ _ _", double fontSize = 35}) {
    return InputDecoration(
      counter: const SizedBox(),
      contentPadding: const EdgeInsets.only(top: 5, bottom: 5),
      hintText: hintText,
      errorBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      focusedErrorBorder: outlineInputBorder,
      disabledBorder: outlineInputBorder,
      enabledBorder: outlineInputBorder,
      border: outlineInputBorder,
      errorStyle: TextStyle(color: textColorwhite),
      // hintStyle: TextStyle(color: textColorwhite),
      hintStyle: TextStyle(color: textColorwhite, fontSize: fontSize),
      fillColor: Colors.white.withOpacity(0.3),
      filled: true,
    );
  }

  final outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: borderColorWhite),
  );

  /// Metodo para le header tap del login, inicio de sesión y registro
  // AnimatedContainer headerTap(Size media) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 100),
  //     height: media.height * 0.2,
  //     width: media.width,
  //     child: ClipPath(
  //       clipper: ShapePainterBottom(),
  //       child: GestureDetector(
  //         onTap: () {
  //           setState(() {
  //             if (showSignin == false) {
  //               showSignin = true;
  //             }
  //           });
  //         },
  //         onVerticalDragStart: (v) {
  //           setState(() {
  //             if (showSignin == false) {
  //               showSignin = true;
  //             }
  //           });
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             border: Border.all(color: theme, width: 0),
  //             color: theme,
  //           ),
  //           child: (showSignin == false)
  //               ? Column(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     MyText(
  //                       text: languages[choosenLanguage]['text_sign_in'],
  //                       size: media.width * sixteen,
  //                       color: Colors.white,
  //                       fontweight: FontWeight.w600,
  //                     ),
  //                     SizedBox(
  //                       height: media.height * 0.01,
  //                     ),
  //                     Icon(
  //                       Icons.keyboard_double_arrow_up_rounded,
  //                       size: media.width * 0.07,
  //                       color: Colors.white,
  //                     ),
  //                     SizedBox(
  //                       height: media.height * 0.01,
  //                     ),
  //                   ],
  //                 )
  //               : Column(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     SizedBox(
  //                       width: media.width * 0.7,
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           InkWell(
  //                               onTap: () {
  //                                 if (signIn == 1) {
  //                                   setState(() {
  //                                     forgotPassword = false;
  //                                     newPassword = false;
  //                                     otpSent = false;
  //                                     withOtp = false;
  //                                     isLoginemail = true;
  //                                     _error = '';
  //                                     _email.clear();
  //                                     _password.clear();
  //                                     _name.clear();
  //                                     _mobile.clear();
  //                                     signIn = 0;
  //                                   });
  //                                 }
  //                               },
  //                               child: MyText(
  //                                 text: languages[choosenLanguage]
  //                                     ['text_sign_in'],
  //                                 size: media.width * sixteen,
  //                                 color: (signIn == 0)
  //                                     ? Colors.white
  //                                     : Colors.white.withOpacity(0.5),
  //                                 fontweight: FontWeight.w600,
  //                               )),
  //                           InkWell(
  //                               onTap: () {
  //                                 if (signIn == 0) {
  //                                   setState(() {
  //                                     forgotPassword = false;
  //                                     otpSent = false;
  //                                     newPassword = false;
  //                                     proImageFile1 = null;
  //                                     isLoginemail = true;
  //                                     withOtp = false;
  //                                     _error = '';
  //                                     _email.clear();
  //                                     _password.clear();
  //                                     _name.clear();
  //                                     _mobile.clear();
  //                                     signIn = 1;
  //                                   });
  //                                 }
  //                               },
  //                               child: MyText(
  //                                 text: languages[choosenLanguage]
  //                                     ['text_sign_up'],
  //                                 size: media.width * sixteen,
  //                                 color: (signIn == 1)
  //                                     ? Colors.white
  //                                     : Colors.white.withOpacity(0.5),
  //                                 fontweight: FontWeight.w600,
  //                               )),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: media.height * 0.05,
  //                     ),
  //                   ],
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget sendWhatsApp() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme,
      ),
      backgroundColor: theme,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          // padding: EdgeInsets.all(20),
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/logo15abril.svg',
                width: 90,
              ),
            ),
            const SizedBox(height: 60),
            if (stepCode == 0) sendCode(),
            if (stepCode == 1) FadeInRight(child: verifyCode()),
            if (stepCode == 2) ZoomIn(child: inputName()),
          ],
        ),
      ),
    );
  }

  navigateMap() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Maps()));
  }

  Widget inputName() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                "Último paso",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColorwhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: textColorwhite, width: 5)),
            child: Icon(
              Icons.person,
              color: textColorwhite,
              size: 90,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: nombre,
              style: TextStyle(
                fontSize: 16,
                color: textColorwhite,
                fontWeight: FontWeight.bold,
              ),
              // initialValue: user?.displayName ?? "",
              textAlign: TextAlign.center,
              validator: (value) {
                if ((value ?? "").isEmpty) {
                  return "El nombre es requerido";
                }
                return null;
              },
              decoration:
                  inputDecoration(hintText: 'Ingresa tu nombre', fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          if (loadingRegister)
            Center(
              child: CircularProgressIndicator(
                color: textColorwhite,
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColorWhite,
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.8, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                'Iniciar',
                style: TextStyle(color: theme, fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (formKey.currentState!.validate()) {
                  setState(() {
                    loadingRegister = true;
                  });
                  name = nombre.text;
                  email = (user?.email ?? "");
                  password = (user?.email ?? "");
                  phnumber = number;
                  valueNotifierLogin.incrementNotifier();
                  var register = await registerUser();
                  if (register == 'true') {
                    //referral page
                    setState(() {
                      loadingSend = false;
                    });
                    navigateMap();
                    return;
                  } else {
                    setState(() {
                      loadingSend = false;
                    });
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(register)));
                  }
                }
              },
            ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  'Bienvenido a Radio Móvil 15 de abril\n¡TU DESTINO TE ESPERA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColorwhite, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column verifyCode() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "Confirma el código enviado a tu Whatsapp",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColorwhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            style: TextStyle(
              fontSize: 25,
              color: textColorwhite,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLength: 4,
            controller: resCode,
            keyboardType: TextInputType.number,
            decoration: inputDecoration(),
            onChanged: (value) {
              if (value.length == 4) {
                setState(() {
                  active = true;
                });
              } else if (value.length < 4 && active) {
                setState(() {
                  active = false;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: buttonColorWhite,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: (active)
              ? () {
                  if (resCode.text == code?.codigo.toString()) {
                    setState(() {
                      stepCode = 2;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código Verificado")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("El código es incorrecto")));
                  }
                }
              : null,
          child: Text(
            'Verificar',
            style: TextStyle(
                color: (active) ? theme : Colors.grey,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
        if (loadingSend)
          Center(
            child: CircularProgressIndicator(
              color: textColorwhite,
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextButton(
                  child: Text(
                    'Cambiar número',
                    style: TextStyle(
                      color: textColorwhite,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          textColorwhite, // Cambia el color del subrayado
                      decorationThickness: 2.0,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      stepCode = 0;
                      number = '';
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  child: Text(
                    'Reenviar código',
                    style: TextStyle(
                      color: textColorwhite,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          textColorwhite, // Cambia el color del subrayado
                      decorationThickness: 2.0,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      loadingSend = true;
                    });
                    var confirm = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => ModalConfirm(number: number));
                    if (confirm == false || confirm == null) {
                      setState(() {
                        loadingSend = false;
                      });
                      return;
                    }
                    var res = await SignInProvider().sendCodeWhatsApp(
                        number: phone?.number ?? "",
                        code: phone?.countryCode ?? "");
                    if (res != null) {
                      if (res.codigo == 0) {
                        setState(() {
                          loadingSend = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(res.message)));
                        return;
                      }
                      setState(() {
                        stepCode = 1;
                        loadingSend = false;
                        code = res;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Código enviado")));
                    } else {
                      setState(() {
                        loadingSend = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Algo salió mal, revice el número e intente nuevamente.")));
                    }
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Te enviamos un código de confirmación al número $number',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColorwhite, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column sendCode() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "Para continuar ingresa tú número de teléfono",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColorwhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: IntlPhoneField(
            dropdownTextStyle: textStyle(),
            style: textStyle(),
            disableLengthCheck: true,
            autovalidateMode: null,
            flagsButtonPadding: const EdgeInsets.all(10),
            invalidNumberMessage: "Número no válido",
            pickerDialogStyle: PickerDialogStyle(
                backgroundColor: backgroundColor,
                searchFieldInputDecoration: const InputDecoration(
                  hintText: 'Buscar País',
                )),
            dropdownIcon:
                const Icon(Icons.arrow_drop_down, color: Colors.white),
            decoration:
                inputDecoration(hintText: 'Número de teléfono', fontSize: 14),
            initialCountryCode: 'BO',
            onChanged: (numero) {
              // contact.phone = phone;
              number = numero.completeNumber;
              debugPrint(numero.completeNumber);
              phone = numero;
            },
          ),
        ),
        const SizedBox(height: 10),
        if (loadingSend)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: buttonColorWhite,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(
              'Enviar código',
              style: TextStyle(color: theme, fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              setState(() {
                loadingSend = true;
              });
              var confirm = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ModalConfirm(number: number));
              if (confirm == false || confirm == null) {
                setState(() {
                  loadingSend = false;
                });
                return;
              }
              var res = await SignInProvider().sendCodeWhatsApp(
                  number: phone?.number ?? "", code: phone?.countryCode ?? "");
              if (res != null) {
                if (res.codigo == 0) {
                  /// ocurio un error
                  setState(() {
                    loadingSend = false;
                  });
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(res.message)));
                  return;
                }
                setState(() {
                  stepCode = 1;
                  loadingSend = false;
                  code = res;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Código enviado")));
              } else {
                setState(() {
                  loadingSend = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "Algo salió mal, revice el número e intente nuevamente.")));
              }
            },
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SvgPicture.asset('assets/images/whatsapp.svg', width: 24),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Recibirás un código de confirmación en tu Whatsapp',
                style: TextStyle(color: textColorwhite, fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        Text(
          "Has iniciado sesión con:\n ${(user?.email ?? '')}",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12, color: textColorwhite, fontWeight: FontWeight.w400),
        ),
        TextButton(
            onPressed: () {
              SignInProvider().logOut();
              setState(() {
                stepAuth = 0;
              });
              return;
            },
            child: Text(
              "Cambiar cuenta",
              style: TextStyle(
                  color: textColorwhite,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      textColorwhite, // Cambia el color del subrayado
                  decorationThickness: 2.0,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ))
      ],
    );
  }

  OutlineInputBorder borderInput({Color color = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class ShapePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.9,
        size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ShapePainterBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.25,
        size.width * 0.8, size.height * 0.25);
    path.lineTo(size.width * 0.2, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.25, 0, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
