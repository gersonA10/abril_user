import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class CustomAlertDialog extends StatelessWidget {
  final Function()? onPressed;
  final Function()? onPressedIcon;
  const CustomAlertDialog({super.key, required this.onPressed, required this.onPressedIcon});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de cierre en la esquina superior derecha
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(onTap: onPressedIcon, child: Image.asset('assets/images/exit.png')),
          ),
          // Imagen de la caja con el texto "PRÓXIMAMENTE"
          Image.asset(
            'assets/images/prox.png', // Reemplaza con la ruta de tu imagen
            height: 200,
          ),
          const SizedBox(height: 16),
          // Título del mensaje
          Text(
            '¡Próximamente en 15 de Abril!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Descripción
          const Text(
            'Servicio de delivery para toda la ciudad de Tarija.',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Botón de Aceptar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: onPressed,
            // onPressed: () {
            //   widget.isRentalRide = false;
            //   if (widget.choosenTransportType != 0) {
            //     setState(() {
            //       widget.choosenTransportType = 0;
            //       // isRentalRide = false;
            //       widget.myMarkers.clear();
            //     });
            //   }
            //   Navigator.of(context).pop();
            // },
            child: const Text('Aceptar', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Para mostrar el diálogo en cualquier parte de tu aplicación:


// --- WIDGET PRINCIPAL (Tu página) ---
// Ahora es mucho más simple. Solo se encarga de cargar el mapa.
class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  String? mbtilesPath;

  @override
  void initState() {
    super.initState();
    loadMbtiles();
  }

  Future<void> loadMbtiles() async {
    final path = await copyMbtilesToLocal();
    if (mounted) {
      setState(() {
        mbtilesPath = path;
      });
    }
  }

  Future<String> copyMbtilesToLocal() async {
    final byteData =
        await rootBundle.load('assets/bolivia-shortbread-1.0.mbtiles');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/bolivia-shortbread-1.0.mbtiles');
    if (!await file.exists()) {
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    if (mbtilesPath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Cargando Mapa...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Una vez cargado, simplemente llamamos al widget del mapa interactivo
    return MapaInteractivo(mbtilesPath: mbtilesPath!);
  }
}

// --- WIDGET DEL MAPA REUTILIZABLE ---
// Contiene toda la lógica compleja del mapa.
class MapaInteractivo extends StatefulWidget {
  final String mbtilesPath;

  const MapaInteractivo({super.key, required this.mbtilesPath});

  @override
  State<MapaInteractivo> createState() => _MapaInteractivoState();
}

class _MapaInteractivoState extends State<MapaInteractivo> {
  late final MapController _fmController;
  bool _isMapReady = false;

  // --- DEBES MOVER TUS VARIABLES DE ESTADO AQUÍ ---
  // Ejemplo de las variables que necesitas definir o importar
  List<dynamic> addressList = []; // Reemplaza 'dynamic' con tu clase AddressList
  Map<String, dynamic> userDetails = {'name': 'Gerson', 'mobile': '12345'};
  LatLng _centerLocation = LatLng(-16.5, -64.0);
  LatLng _lastCenter = LatLng(-16.5, -64.0);
  LatLng _centerLocationStatic = LatLng(-16.5, -64.0);
  List<Marker> myMarkers = []; // Reemplaza con tu tipo de Marker si es diferente
  bool ischanged = false;

  // Debes implementar o importar esta función
  Future<String> geoCoding(double lat, double lng) async {
    // Lógica para convertir coordenadas a dirección
    return "Dirección de ejemplo";
  }
  // --- FIN DE VARIABLES DE EJEMPLO ---


  @override
  void initState() {
    super.initState();
    _fmController = MapController();
    // Damos tiempo al mapa para que se cargue antes de permitir interacciones
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // Coordenadas para Bolivia
    final LatLng esquinaSuroeste = LatLng(-22.9, -69.6);
    final LatLng esquinaNoreste = LatLng(-9.6, -57.4);

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Interactivo")),
      body:FlutterMap(
        mapController: _fmController,
        options:MapOptions(
          initialCenter: LatLng(-16.5, -64.0),
          initialZoom: 5.5,
          minZoom: 5,
          maxZoom: 18,
          onMapEvent: (v) async {
            if (!_isMapReady) return;
            // Tu lógica de onMapEvent aquí...
          },
          onPositionChanged: (p, hasGesture) async {
            if (!_isMapReady || hasGesture == false) return;
            _centerLocation = p.center!;
            var val = await geoCoding(_centerLocation.latitude, _centerLocation.longitude);
            // Tu lógica de onPositionChanged aquí...
            setState(() {
              // ...
            });
          },
        ),
        children: [
          // Capa del mapa offline
          TileLayer(
            tileProvider: MbTilesTileProvider.fromPath(path: widget.mbtilesPath),
            maxZoom: 18,
            minZoom: 5,
            tileBounds: LatLngBounds(esquinaSuroeste, esquinaNoreste),
            fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),

          // Capa de tus marcadores
      MarkerLayer(
            markers: [
          Marker(
                  rotate: true,
                  key: UniqueKey(),
                  point: LatLng(_centerLocationStatic.latitude, _centerLocationStatic.longitude),
                  child: Image.asset('assets/images/my_location_static.png')),
              // Tu lógica para mostrar 'myMarkers'
              // ...
            ],
          ),

          // Otras capas que necesites
          const RichAttributionWidget(
            attributions: [],
          ),
        ],
      ),
    );
  }
}
