import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/PedirMovil/seleccionar%20auto/widgets/lista_autos.dart';
import 'package:flutter_user/pages/splash%20screen/loading.dart';
import 'package:flutter_user/pages/trip%20screen/bookingwidgets.dart';
import 'package:flutter_user/providers/request_provider.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/estados_widget.dart';
import 'package:flutter_user/widgets/prefrencias_widget.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

  int? selectedIndex;


class StepSelectVehicle extends StatelessWidget {
    final LatLng? customPickup;
    final String? nameAdress;
  const StepSelectVehicle({super.key, this.customPickup, this.nameAdress});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return  provider.isLoadingRideAccept == true ? 
    Container(
      width: double.infinity,
      height: size.height,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/images/load.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Buscando conductor...',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    ): Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(
              text: languages[choosenLanguage]['text_availablerides'],
              size: size.width * fourteen,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            const Preferencias(),
            const SizedBox(height: 10),
            const ListaVehiculosDisponibles(),
            const SizedBox(height: 10),
            const PaymentOptionSelector(),
            const SizedBox(height: 24),
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  provider.isLoadingRide = true;
                  var result = await createRequest(
                    jsonEncode({
                      'pick_lat': customPickup!.latitude,
                      'pick_lng': customPickup!.longitude,
                      'vehicle_type': etaDetails[selectedIndex!]['zone_type_id'],
                      'ride_type': 1,
                      'payment_opt': 1,
                      'pick_address': nameAdress,
                      'request_eta_amount': etaDetails[selectedIndex!]['total'],
                      'is_pet_available': (choosePets == false) ? false : true,
                      'is_luggage_available': (chooseLuggages == false) ? false : true,
                      'is_licoreria': (licoreria == false) ? false : true,
                      'is_parrilla': (parrilla == false) ? false : true
                    }),
                     'api/v1/request/create',
                     context
                  );
                  provider.isLoadingRide = false;
                  if (result == 'success') { 
                   final String requestID = userRequestData['id'];
                   prefs.setString('requestIDRIDE', requestID);
                  provider.startSearch();
                  provider.startListeningToRequestStreams(requestID, context);
                    
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme),
                child: const Text(
                  "Pedir Móvil Ahora",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOptionSelector extends StatefulWidget {
  const PaymentOptionSelector({super.key});

  @override
  State<PaymentOptionSelector> createState() => _PaymentOptionSelectorState();
}

class _PaymentOptionSelectorState extends State<PaymentOptionSelector> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> options = [
    {'label': 'Efectivo', 'icon': Icons.phone_iphone},
    {'label': 'Pago por QR', 'icon': Icons.qr_code_2_sharp},
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(options.length, (index) {
        final selected = selectedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: selected ? 45 : 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? Colors.red.shade50 : Colors.white,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
            border: Border.all(
              color: selected ? Colors.redAccent : Colors.black12,
              width: 1.4,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => selectedIndex = index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    options[index]['icon'],
                    color: selected ? Colors.redAccent : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    options[index]['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.redAccent : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

