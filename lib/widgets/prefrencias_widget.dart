import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/trip%20screen/bookingwidgets.dart';
import 'package:flutter_user/styles/styles.dart';


class Preferencias extends StatefulWidget {
  // final dynamic type;
  const Preferencias({super.key});
  @override
  _PreferenciasState createState() => _PreferenciasState();
}

class _PreferenciasState extends State<Preferencias> {
   void toggleSelection(String tipo) {
    setState(() {
      if (tipo == 'Licorería') {
        licoreria = !licoreria;
        if (licoreria) {
          chooseLuggages = false;
          choosePets = false;
          parrilla = false;
        }
      } else {
        if (tipo == 'Equipaje') {
          chooseLuggages = !chooseLuggages;
        } else if (tipo == 'Mascotas') {
          choosePets = !choosePets;
        } else if (tipo == 'Parrilla') {
          parrilla = !parrilla;
        }

        // Si se selecciona algo diferente a Licorería, Licorería se deselecciona
        if (chooseLuggages || choosePets || parrilla) {
          licoreria = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: 240,
          // height: 120,
          // padding: const EdgeInsets.all(20),
          padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10  ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1.0,
                offset: Offset(0.0, 4.0)
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Preferencias',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme
                ),
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón Equipaje
                  preferenceButton('Equipaje', Icons.luggage, chooseLuggages, () {
                    toggleSelection('Equipaje');
                  }),
                  // Botón Parrilla
                  preferenceButton('Parrilla', Icons.car_rental, parrilla, () {
                    toggleSelection('Parrilla');
                  }),
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón Mascotas
                  preferenceButton('Mascotas', Icons.pets, choosePets, () {
                    toggleSelection('Mascotas');
                  }),
                  // Botón Licorería
                  preferenceButton('Licorería', Icons.local_bar, licoreria, () {
                    toggleSelection('Licorería');
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    
  }

Widget preferenceButton(String text, IconData icon, bool isSelected, VoidCallback onPressed) {
    return Container(
      width: 100,
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? theme : const Color.fromARGB(255, 182, 182, 182),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                // border: Border.all(color: Colors.grey, width: 2),
              ),
              // padding: const EdgeInsets.all(0),
              child: Icon(
                icon,
                size: 12,
                color:  Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
