import 'package:flutter/material.dart';
import 'package:flutter_user/styles/styles.dart';

class ModalConfirm extends StatelessWidget {
  final String number;
  const ModalConfirm({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(15),
      children: [
        Text(
          "¿Este es el número correcto?",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          number,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: theme),
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  "NO",
                  style: TextStyle(color: theme),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "SI",
                  style: TextStyle(color: textColorwhite),
                )),
          ],
        ),
      ],
    );
  }
}
