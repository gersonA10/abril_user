import 'package:flutter/material.dart';

class AudioIconWidget extends StatefulWidget {
  const AudioIconWidget({
    super.key,
    required this.onStart,
    required this.onEnd,
    required this.onCancel,
  });

  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  State<AudioIconWidget> createState() => _AudioIconWidgetState();
}

class _AudioIconWidgetState extends State<AudioIconWidget> {
  bool isStarted = false;
  final position = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (down) {
        isStarted = true;
        widget.onStart();
        setState(() {});
      },
      onTapUp: (up) {
        isStarted = false;
        widget.onEnd();
        setState(() {});
      },
      onHorizontalDragUpdate: (details) {
        position.value -= 1;
      },
      onHorizontalDragEnd: (details) {
        if (isStarted) {
          widget.onCancel();
          isStarted = false;
        }
        setState(() {});
        position.value = 0;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isStarted)
            ValueListenableBuilder<double>(
              valueListenable: position,
              builder: (ctx, value, child) {
                return Transform.translate(
                  offset: Offset(value, 0),
                  child: const Text('< < < Desliza para cancelar'),
                );
              },
            ),
          const SizedBox(width: 18),
          Transform.scale(
            scale: isStarted ? 1.5 : 1,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xff484848),
              child: Icon(
                Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
