import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/PedirMovil/seleccionar%20auto/select_vehicle.dart';
import 'package:flutter_user/pages/PedirMovil/step_driver_found.dart';
import 'package:flutter_user/pages/PedirMovil/step_search_driver.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/providers/request_provider.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestRideScreen extends StatefulWidget {
  final LatLng? customPickup;
  final String? nameAdress;
  final bool? showDriverStep;
  const RequestRideScreen({super.key, this.customPickup, this.nameAdress, this.showDriverStep});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  bool _followDriver = true;
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  LatLng? driverPosition;

  bool _mapReady = false;

void moveToCurrentLocation() {
  _followDriver = false;

  if (currentLocation != null && _mapReady) {
    _mapController.move(currentLocation!, _mapController.camera.zoom);
  }
}


void moveToDriverLocation() {
  _followDriver = true;

  if (driverPosition != null && _mapReady) {
    _mapController.move(driverPosition!, _mapController.camera.zoom);
  }
}


void updateDriverPosition(LatLng position) {
  setState(() {
    driverPosition = position;
  });

  if (_mapReady && _followDriver) {
    _mapController.move(position, _mapController.camera.zoom);
  }
}


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RequestProvider>(context, listen: false);
      provider.restoreStateFromPrefs();
      provider.fetchEtaData();

      if (widget.showDriverStep == true ) {
        provider. goToStep(RequestStep.conductorAsignado);
      }
    });
  }
void _getCurrentLocation() async {
  if (widget.customPickup != null) {
    setState(() {
      currentLocation = widget.customPickup;
    });
    return;
  }

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Puedes mostrar un dialog para decirle al usuario que active la ubicación
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  } catch (e) {
    debugPrint("Error al obtener ubicación: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: currentLocation == null
          ? Container(color: Colors.white)
          : Stack(
              children: [
                /// Mapa
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
                    initialZoom: 19.0,
                    onMapReady: () {
                      setState(() {
                        _mapReady = true;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marcador del punto de recogida (pickup)
                        Marker(
                          rotate: true,
                          height: size.height * 0.10,
                          width: size.width * 0.10,
                          point: currentLocation!,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/pick_icon.png'),
                              ),
                            ),
                          ),
                        ),

                        // Marcador del conductor (si hay posición)
                        if (driverPosition != null)
                          Marker(
                            rotate: true,
                            height: size.height * 0.10,
                            width: size.width * 0.10,
                            point: driverPosition!,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/top-taxi.png'), // Usa tu ícono aquí
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                /// Contenido dinámico
                Consumer<RequestProvider>(
                  builder: (_, provider, __) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    switch (provider.currentStep) {
                      case RequestStep.seleccionar:
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: StepSelectVehicle(
                            customPickup: widget.customPickup,
                            nameAdress: widget.nameAdress,
                          ),
                        );
                      case RequestStep.buscando:
                        return const Align(
                          alignment: Alignment.bottomCenter,
                          child: StepSearchingDriver(),
                        );
                      case RequestStep.conductorAsignado:
                        return StepDriverFound(
                          driver: provider.assignedDriver!,
                          onMyLocationPressed: moveToCurrentLocation,
                          onDriverLocationPressed: moveToDriverLocation,
                          onUpdateDriverLocation: updateDriverPosition,
                        );
                    }
                  },
                ),
              ],
            ),
    );
  }
}
