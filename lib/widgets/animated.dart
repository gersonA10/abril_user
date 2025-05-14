import 'package:flutter/material.dart';
import 'package:flutter_user/pages/trip%20screen/ongoingrides.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/widgets/widgets.dart';

class AnimatedOngoingRides extends StatefulWidget {
  const AnimatedOngoingRides({Key? key}) : super(key: key);

  @override
  _AnimatedOngoingRidesState createState() => _AnimatedOngoingRidesState();
}

class _AnimatedOngoingRidesState extends State<AnimatedOngoingRides>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Repite la animación de ida y vuelta.

    // Definimos la animación que mueve el auto de izquierda a derecha.
    _animation = Tween<double>(begin: 0.0, end: 70.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Positioned(
      top: media.height * 0.71,
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnGoingRides(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 40,
          width: media.width * 0.95,
          decoration: BoxDecoration(
            color: theme,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_animation.value, 0), // Mueve el auto en el eje X.
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/auto1.png',
                  width: 40, // Ajusta el tamaño de la imagen si es necesario.
                ),
              ),
              const Spacer(),
              MyText(
                text: '¡Tienes viajes pendientes!',
                size: media.width * 0.035,
                color: Colors.white,
                fontweight: FontWeight.bold,
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.white,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
