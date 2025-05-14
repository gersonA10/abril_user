import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_user/functions/fect_data_firebase.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/trip%20screen/map_page.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool iniciarViaje = false;

class EstadosWidget extends StatefulWidget {
  const EstadosWidget({
    super.key,
    required this.media,
  });

  final Size media;

  @override
  State<EstadosWidget> createState() => _EstadosWidgetState();
}

class _EstadosWidgetState extends State<EstadosWidget> {
  StreamSubscription? _arrivedSub;
StreamSubscription? _startSub;
StreamSubscription? _completeSub;

  RequestService requestService = RequestService();
  bool llegueAlLugar = false;
  bool finalizoElViaje = false;
  // final requestID = userRequestData['id'];/z``
  String? requestID;

  final FlutterTts flutterTts = FlutterTts();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> messages = [];
  StreamSubscription? _messagesSubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // StreamSubscription? _listenIfDriverCancel;

  void _listenToMessages() {
    String messageContent = "";
    if (requestID == null) return;

    _messagesSubscription = _messagesRef
        .child('requests/$requestID/array_mensajes')
        .onValue
        .listen((event) async {
      if (!mounted) return;

      if (event.snapshot.value != null && event.snapshot.value is List) {
        List<dynamic> data = event.snapshot.value as List<dynamic>;

        // Filtrar solo mensajes válidos (para evitar nulos)
        List<Map<String, dynamic>> validMessages = data
            .where((msg) => msg != null)
            .map((msg) => Map<String, dynamic>.from(msg))
            .toList();

        if (validMessages.isNotEmpty) {
          // 🔥 Solo procesamos el ÚLTIMO mensaje
          Map<String, dynamic> lastMessage = validMessages.last;

          if (lastMessage["estado"] == "enviado" &&
              lastMessage["origen"] == "driver") {
            final String tipo = lastMessage['tipo'];
            if (tipo == "imagen" || tipo == "audio") {
              messageContent = "Tienes un nuevo mensaje: $tipo";
              //  messageContent = tipo == "auido" ? "Tienes un nuevo mensaje" : lastMessage['contenido'];
            } else {
              messageContent = lastMessage['contenido'];
            }
            //  messageContent = tipo == "auido" ? "Tienes un nuevo mensaje" : lastMessage['contenido'];

            // 📢 Enviar notificación
            await _showNotification(messageContent);

            // 🎙 Leer solo el último mensaje en voz alta
            flutterTts.setLanguage("es-ES");
            await flutterTts.speak(messageContent);
          }
        }

        setState(() {
          messages = validMessages;
        });
      }
    });
  }

  void _listenIfDriverCancelled() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('requests');
    ref.child('cancelled_by_driver').onValue.map((event) {
      return event.snapshot.value.toString();
    });
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel',
      'Mensajes de chat',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Nuevo mensaje',
      message,
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final prefs = await SharedPreferences.getInstance();
    requestID = prefs.getString('requestIDRIDE');

    if (requestID == null) return;

    _listenToMessages();
    _listenTripStatus();
  }

void _listenTripStatus() {
  _arrivedSub = requestService.getTripArrived(requestID!).listen((request) {
    if (request == '1' && mounted) {
      setState(() {
        llegueAlLugar = true;
      });
    }
  });

  _startSub = requestService.getTripStart(requestID!).listen((request) {
    if (request == '1' && mounted) {
      setState(() {
        iniciarViaje = true;
        llegueAlLugar = false;
      });
    }
  });

  _completeSub = requestService.getCompltedRide(requestID!).listen((request) {
    if (request == '1' && mounted) {
      setState(() {
        finalizoElViaje = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Maps()),
      );
    }
  });
}


@override
void dispose() {
  _messagesSubscription?.cancel();
  _arrivedSub?.cancel();
  _startSub?.cancel();
  _completeSub?.cancel();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    // getUserDetails(id: userRequestData['id']);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 500), // Duración de la animación
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Image.asset(
            (llegueAlLugar == true)
                ? "assets/images/estado2.png"
                : (iniciarViaje == true)
                    ? "assets/images/estado3.png"
                    : "assets/images/estado1.png",
            key: ValueKey<String>(
              (llegueAlLugar == true)
                  ? "estado2"
                  : (iniciarViaje)
                      ? "estado3"
                      : "estado1",
            ), // Es importante usar keys únicas para cada imagen
            width: widget.media.width * 0.7,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: MyText(
                text: (llegueAlLugar == true)
                    ? "¡El conductor ha llegado!"
                    : (iniciarViaje == true)
                        ? "¡Disfruta tu viaje!"
                        : "¡El conductor está en camino!",
                size: 18,
                color: theme,
                textAlign: TextAlign.center,
                fontweight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
