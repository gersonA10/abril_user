import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_user/firebase_options.dart';
import 'package:flutter_user/functions/providers/sign_in_provider.dart';
import 'package:flutter_user/providers/payment_provider.dart';
import 'package:flutter_user/providers/request_provider.dart';
import 'package:provider/provider.dart';
import 'functions/functions.dart';
import 'functions/notifications.dart';
import 'pages/splash screen/loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

  bool audioPlayed = false;


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification!.title!.contains('Su móvil') || message.notification!.title!.contains('Su móvil esta afuera')) {
    final player = AudioPlayer();
    player.play(AssetSource('audio/audio_taxi_afuera.mp3'));
  } else if (message.notification!.title!.contains('El viaje ha terminado') || message.notification!.body!.contains('El conductor ha finalizado el viaje')){
    final player = AudioPlayer();
    player.play(AssetSource('audio/fin_viaje_usuario.mp3'));
    audioPlayed = true;
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  checkInternetConnection();
  initMessaging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    platform = Theme.of(context).platform;
    return MultiProvider(
      providers: [
        Provider(create: (_) => SignInProvider()),
        ChangeNotifierProvider(create: (_)=> RequestProvider()),
         ChangeNotifierProvider(create: (_)=> PaymentProvider())
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: ValueListenableBuilder(
          valueListenable: valueNotifierBook.value,
          builder: (context, value, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Radiomóvil 15 de abril Tarija',
              theme: ThemeData( inputDecorationTheme: InputDecorationTheme(
                border: borderInput(),
                contentPadding: const EdgeInsets.all(15),
                fillColor: Colors.white,
                filled: true,
                hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
                enabledBorder: borderInput(),
                focusedErrorBorder: borderInput(),
                focusedBorder: borderInput(),
                errorBorder: borderInput(color: Colors.red),
              )),
              // home: const SingInPage(),
              home: const LoadingPage(),

              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                  // child: const SingInPage(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder borderInput({Color color = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}
