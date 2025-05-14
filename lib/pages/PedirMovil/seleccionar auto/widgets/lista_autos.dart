import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/PedirMovil/seleccionar%20auto/select_vehicle.dart';
import 'package:flutter_user/styles/styles.dart';


class ListaVehiculosDisponibles extends StatefulWidget {
  const ListaVehiculosDisponibles({super.key});

  @override
  State<ListaVehiculosDisponibles> createState() =>  _ListaVehiculosDisponiblesState();
}

class _ListaVehiculosDisponiblesState extends State<ListaVehiculosDisponibles> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return SizedBox(
      height: media.width * 0.42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: etaDetails.length,
        itemBuilder: (context, i) {
          final detail = etaDetails[i];
          final isSelected = selectedIndex == i;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = i;
              });
            },
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              tween: Tween<double>(begin: 1, end: isSelected ? 0.95 : 0.86),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(right: media.width * 0.035),
                    width: media.width * 0.27,
                    height: media.width * 0.42,
                    padding: EdgeInsets.all(media.width * 0.03),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade50 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(media.width * 0.035),
                      border: Border.all(
                        color: isSelected ? theme : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? theme : Colors.black12,
                          blurRadius: isSelected ? 4 : 2,
                          // offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isSelected ? 1 : 0.85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Capacidad
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: media.height * 0.018),
                              const SizedBox(width: 4),
                              Text(
                                '${detail['capacity']}',
                                style: TextStyle(
                                  fontSize: media.height * 0.014,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          /// Tiempo
                          Row(
                            children: [
                              Icon(Icons.schedule, size: media.height * 0.018),
                              const SizedBox(width: 4),
                              Text(
                                '${detail['base_distance']} min',
                                style: TextStyle(
                                  fontSize: media.height * 0.014,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          /// Imagen
                          Container(
                            alignment: Alignment.center,
                            width: media.width * 0.2,
                            height: media.width * 0.1,
                            child: Image.network(
                              detail['icon'],
                              fit: BoxFit.contain,
                            ),
                          ),

                          /// Nombre
                          Text(
                            detail['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: media.height * 0.0145,
                              color: isSelected ? theme : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
