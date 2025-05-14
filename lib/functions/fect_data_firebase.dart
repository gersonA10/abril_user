
import 'package:firebase_database/firebase_database.dart';

class RequestService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('requests');

  void markClientMessagesAsRead(String requestId) {
  final DatabaseReference messagesRef = FirebaseDatabase.instance.ref();
  
  messagesRef.child('requests/$requestId/array_mensajes').once().then((event) {
    if (event.snapshot.value != null && event.snapshot.value is List) {
      List<dynamic> data = event.snapshot.value as List<dynamic>;

      for (int i = 0; i < data.length; i++) {
        if (data[i] != null) {
          Map<String, dynamic> msg = Map<String, dynamic>.from(data[i]);

          // Si el mensaje fue enviado por el driver y aún está en "enviado", lo marcamos como "visto"
          if (msg["estado"] == "enviado" && msg["origen"] == "driver") {
            messagesRef
                .child('requests/$requestId/array_mensajes/$i')
                .update({"estado": "visto"});
          }
        }
      }
    }
  });
}


Future<Map<String, dynamic>?> getRequestData(String requestId) async {
  final DatabaseReference requestRef =
      FirebaseDatabase.instance.ref('requests/$requestId');

  final DataSnapshot snapshot = await requestRef.get();

  if (snapshot.exists && snapshot.value != null) {
    return Map<String, dynamic>.from(snapshot.value as Map);
  } else {
    return null;
  }
}

  

  Stream<int?> getMessageCountStream(String requestId) {
    return _ref.child(requestId).child('bocina').onValue.map((event) {

      return event.snapshot.value as int?;
    });
  }

  Stream<int> listenDriverMessageCount(String requestId) {
    return _ref.child(requestId).child('nro_mensajes_driver').onValue.map((event) {
      final data = event.snapshot.value;
      return (data != null) ? int.tryParse(data.toString()) ?? 0 : 0;
    });
  }
  Stream<int> listenClientMessageCount(String requestId) {
    return _ref.child(requestId).child('nro_mensajes_cliente').onValue.map((event) {
      final data = event.snapshot.value;
      return (data != null) ? int.tryParse(data.toString()) ?? 0 : 0;
    });
  }

  Stream<String?> getCancelledByUser(String requestId) {
    return _ref.child(requestId).child('cancelled_by_user').onValue.map((event) {

      return event.snapshot.value.toString();
    });
  }
   Stream<String?> getCancelledByUserBool(String requestId) {
    return _ref.child(requestId).child('cancelled_by_user').onValue.map((event) {
      return event.snapshot.value.toString();
    });
  }

     Stream<String?> getCancelledByDriver(String requestId) {
    return _ref.child(requestId).child('cancelled_by_driver').onValue.map((event) {
      return event.snapshot.value.toString();
    });
  }


  Stream<String?> getCompltedRide(String requestId) {
    return _ref.child(requestId).child('is_completed').onValue.map((event) {

      return event.snapshot.value.toString();
    });
  }


   Stream<int?> getStatusRide(String requestId) {
    return _ref.child(requestId).child('is_accept').onValue.map((event) {

      return event.snapshot.value as int?;
    });
  }
   Stream<String?> getTripArrived(String requestId) {
    return _ref.child(requestId).child('trip_arrived').onValue.map((event) {

      return event.snapshot.value.toString();
    });
  }
   Stream<String?> getTripStart(String requestId) {
    return _ref.child(requestId).child('trip_start').onValue.map((event) {

      return event.snapshot.value.toString();
    });
  }

  


}