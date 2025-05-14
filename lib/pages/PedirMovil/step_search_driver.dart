import 'package:flutter/material.dart';
import 'package:flutter_user/providers/request_provider.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepSearchingDriver extends StatelessWidget {
  const StepSearchingDriver({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context);
    final totalSeconds = 120;
    final progress = provider.searchTimeLeft / totalSeconds;

    return _bottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Animación GIF arriba de todo
          SizedBox(
            height: 150,
            child: Image.asset(
              'assets/images/await_mobile.gif',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "Buscando conductor...",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          /// Barra de tiempo
          Stack(
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                height: 20,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  color: theme,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    "${provider.searchTimeLeft} s",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Botón cancelar
          ElevatedButton.icon(
            onPressed: () => provider.cancelSearch(),
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: Text(
              "Cancelar búsqueda",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _bottomSheet({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
    ),
    child: child,
  );
}
