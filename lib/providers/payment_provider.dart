import 'package:flutter/material.dart';

class PaymentProvider with ChangeNotifier {
  int _selectedMethod = 0;
   
  //Obtener ek valor del tipo de pago
  int get selectedMethod => _selectedMethod;

  void setMethod(int index) {
    _selectedMethod = index;
    notifyListeners();
  }
}
