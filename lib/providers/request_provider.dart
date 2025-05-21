// providers/request_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_user/functions/fect_data_firebase.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/models/driver_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RequestStep { seleccionar, buscando, conductorAsignado }

class RequestProvider extends ChangeNotifier {
  RequestStep currentStep = RequestStep.seleccionar;
  RequestService requestService = RequestService();
  int searchTimeLeft = 120;
  Timer? _timer;
  DriverModel? assignedDriver;
  bool isLoading = true;
  int? _selectedVehicleIndex;
  int? get selectedVehicleIndex => _selectedVehicleIndex;
  bool isAccept = false;
  bool? _isLoading;

  bool? get isLoadingRideAccept => _isLoading;
  FlutterTts flutterTts = FlutterTts();

  set isLoadingRide(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  StreamSubscription<int?>? _messageCountSubscription;
  StreamSubscription<int?>? _statusRideSubscription;
  StreamSubscription<String?>? _cancelledByUserSubscription;
  StreamSubscription<String?>? _cancelledByUserBoolSubscription;
  StreamSubscription<String?>? _driverArrived;
  StreamSubscription<String?>? _cancelledByDriver;
  StreamSubscription<String?>? _completedRide;

  bool mostrardDibujadoDestino = false;

  // void showAlertAndPlaySound(BuildContext context, String requestId) {

  //   isAlertShowing = true;
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //   // final size = MediaQuery.of(context).size;

  //       return AlertDialog.adaptive(
  //         content: SizedBox(
  //           height: 160,
  //           child: Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 15.0),
  //                     child: Text(
  //                       'El conductor ha llegado!',
  //                       style: GoogleFonts.montserrat(
  //                         color: const Color.fromARGB(255, 184, 1, 1),
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 17,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 15.0, vertical: 20),
  //                 child: Text(
  //                   'El conductor está en su puerta',
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.montserrat(
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     isAlertShowing = false;
  //                     aceptarBocina(requestId);
  //                   },
  //                   child: Text(
  //                     'Aceptar',
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.montserrat(
  //                       color: Colors.black,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               // SizedBox(
  //               //   height: size.height * 0.025,
  //               // ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //   // Reproduce el sonido
  // }

  void Function(String requestId)? onDriverArrivedCallback;
  bool isAlertShowing = false;

  void playAudio() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/fin_viaje_usuario.mp3'));
  }
  void startListeningToRequestStreams(String requestID, BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();
    final ri = prefs.getString('requestIDRIDE');
    int previousMessageCount = 0;

    // Escucha el stream para contar los mensajes
    _messageCountSubscription = requestService.getMessageCountStream(requestID).listen((request) {
      print(previousMessageCount);
      if (previousMessageCount == 0) {
        previousMessageCount = request ?? 0;
      } else {
        if (request != null && request > previousMessageCount) {
          for (int i = previousMessageCount; i < request; i++) {
            if (isAlertShowing == false) {
               onDriverArrivedCallback?.call(ri!); 
              flutterTts.speak('Tu móvil te esta esperando');
               isAlertShowing = true;
               notifyListeners();
            }
          }
        }
        previousMessageCount = request!;
      }
    });

    // Escucha el estado del viaje
    _statusRideSubscription = requestService.getStatusRide(requestID).listen((request) async {
      if (request == 1) {
        final data = await requestService.getRequestData(requestID);
        // Future.delayed(const Duration(seconds: 4), () async {
        await getUserDetails();
        assignedDriver = DriverModel(
            name: data!['nombre_driver'],
            driverLicense: data['licencia'],
            photoDriver: data['foto_chofer'],
            rating: data['rating'],
            year: data['anio'].toString(),
            color: data['color'],
            photoVehicle: data['foto_movil'],
            brand: data['marca'],
            nroMovil: data['movil'],
            placa: data['placa'],
            driverId: data['driver_id']);
        flutterTts.speak('Tu móvil esta en camino');
        _timer?.cancel();
        goToStep(RequestStep.conductorAsignado);
        notifyListeners();
        // getUserDetails();
        isAccept = true;
        // });
      }
    });

    //si finalizo el viaje
    _completedRide = requestService.getCompltedRide(requestID).listen((isComplete) async {
      if (isComplete == '1') {
        getUserDetails();
        final prefs = await SharedPreferences.getInstance();
        assignedDriver = null;
        prefs.remove('assignedDriver');
        prefs.remove('requestIDRIDE');
        await prefs.setString('currentStep', RequestStep.seleccionar.name);
        playAudio();
        goToStep(RequestStep.seleccionar);
        notifyListeners();
      }
    });

    // Escucha si fue cancelado por el usuario
    _cancelledByUserSubscription = requestService.getCancelledByUser(requestID).listen((request) {
      if (request == "1") {
        mostrardDibujadoDestino = false;
        isAccept = false;
      }
    });

    // Escucha si fue cancelado por el usuario (booleano)
    _cancelledByUserBoolSubscription = requestService.getCancelledByUserBool(requestID).listen((request) {
      if (request == 'true') {
        mostrardDibujadoDestino = false;
        isAccept = false;
      }
    });

    _driverArrived = requestService.getTripArrived(requestID).listen((request) {
      if (request == '1') {
        flutterTts.speak('Tu móvil llegó al lugar');
      }
    });

    //cancelo el driver
    _cancelledByDriver = requestService.getCancelledByDriver(requestID).listen((request) {
      if (request == '1') {
        flutterTts.speak('El móvil ha cancelado el viaje');
        cancelSearch(requestID);
        mostrardDibujadoDestino = false;
        isAccept = false;
      }
    });
  }

  void selectVehicle(int index) {
    _selectedVehicleIndex = index;
    notifyListeners();
  }

  bool get isVehicleSelected => _selectedVehicleIndex != null;

  Future<void> fetchEtaData() async {
    isLoading = true;
    notifyListeners();

    final val = await etaRequest();
    if (val == 'logout') {
      // Manejo opcional fuera
    }

    isLoading = false;
    notifyListeners();
  }

  void goToStep(RequestStep step) async {
    currentStep = step;
    final prefs = await SharedPreferences.getInstance();

    // Solo guarda el driver si no es null
    if (assignedDriver != null) {
      prefs.setString('assignedDriver', jsonEncode(assignedDriver!.toJson()));
      prefs.setString('currentStep', RequestStep.conductorAsignado.name);
    } else {
      // Si no hay driver, vuelve al paso seleccionar y borra datos anteriores
      prefs.setString('currentStep', RequestStep.seleccionar.name);
      prefs.remove('assignedDriver');
    }

    notifyListeners();
  }

  void startSearch() {
    searchTimeLeft = 120;
    currentStep = RequestStep.buscando;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      searchTimeLeft--;
      notifyListeners();
      if (searchTimeLeft <= 0) {
        cancelSearch();
      }
    });
  }

  Future<void> restoreStateFromPrefs() async {
    
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getString('currentStep');

    if (savedStep != null) {
      currentStep = RequestStep.values.firstWhere((e) => e.name == savedStep);
    }

    if (currentStep == RequestStep.conductorAsignado) {
      final driverJson = prefs.getString('assignedDriver');
      if (driverJson != null) {
        assignedDriver = DriverModel.fromJson(jsonDecode(driverJson));
      }
    }

    notifyListeners();
  }

  void cancelSearch([String? requestID]) async {
    await cancelRequest(requestID);
    _timer?.cancel();
    searchTimeLeft = 120;
    assignedDriver = null;

    // Limpia el estado guardado y guarda paso "seleccionar"
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('assignedDriver');
    prefs.remove('requestIDRIDE');
    await prefs.setString('currentStep', RequestStep.seleccionar.name);

    goToStep(RequestStep.seleccionar);
  }
}
