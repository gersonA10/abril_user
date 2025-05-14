import 'package:flutter/material.dart';
import 'package:flutter_user/styles/styles.dart';

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
            child: GestureDetector(
              onTap: onPressedIcon,
              child: Image.asset('assets/images/exit.png')
            ),
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
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: theme),
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
            child: const Text('Aceptar',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Para mostrar el diálogo en cualquier parte de tu aplicación:

