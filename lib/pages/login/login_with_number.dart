import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/functions/models/code_whats_app.dart';
import 'package:flutter_user/functions/providers/sign_in_provider.dart';
import 'package:flutter_user/pages/login/modal_confirm.dart';
import 'package:flutter_user/pages/trip%20screen/map_page.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class LoginWithNumber extends StatefulWidget {
  const LoginWithNumber({super.key});

  @override
  State<LoginWithNumber> createState() => _LoginWithNumberState();
}

class _LoginWithNumberState extends State<LoginWithNumber> {
  int stepCode = 0;
  String number = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loadingSend = false;
  CodeWhatsApp? code;
  PhoneNumber? phone;
  User? user;
  String email = ''; // email of user
  String password = '';
  String phnumber = ''; // phone number as string entered in input field
  String name = ''; //name of user
  bool active = false;
  bool _isLoading = false;
  TextEditingController nombre = TextEditingController();
  final TextEditingController resCode = TextEditingController();
  bool loadingRegister = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      backgroundColor: theme,
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            _isLoading == true
                ? SizedBox(
                    height: size.height * 1,
                    width: size.width * 1,
                    // color: Colors.black.withOpacity(0.5),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.7,
                        ),
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                : Container(),
            Column(
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
          ],
        ),
      ),
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
              ? () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (resCode.text == code?.codigo.toString()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código Verificado")));
                    //Consumir servicio
                    bool response =  await loginWithWhatsapp(phone?.number ?? "");
                    if (response) {
                      //Entra a la aplicacion
                      await userLogin(phone?.number, 0, phone?.number, false);
                      await getUserDetails();
                      // setState(() {
                      _isLoading = false;
                      // });
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const Maps(),
                      //   ),
                      // );
                      Navigator.pushAndRemoveUntil(
                        context, MaterialPageRoute(
                          builder: (context)=> Maps()
                        ),
                       (Route<dynamic> route)=> false
                       );
                    } else {
                      //Registrar al usuario
                      setState(() {
                        stepCode = 2;
                      });
                    }
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
                  // valueNotifierLogin.incrementNotifier();
                  var register =
                      await registerUserWithNumber(name, phnumber, coCode);
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
              setState(() {
                coCode = numero.countryCode;
              });
              number = numero.number;
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
                  
              coCode = phone!.countryCode;
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
      ],
    );
  }
}
