import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/fect_data_firebase.dart';
import 'package:flutter_user/models/driver_model.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import 'header_chat_widget.dart';
import 'list_chat_widget.dart';
import 'send_message_widget.dart';

class ChatPage extends StatefulWidget {
  final String? requestId;
  final DriverModel? driver;
  const ChatPage({super.key, this.requestId, this.driver});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // final AudioRecorder _recorder = AudioRecorder();
  final _recorder = Record();
  final ScrollController _controller = ScrollController();
    late DatabaseReference _requestRef;

  List<dynamic> chatList = [];

  @override
  void initState() {
    super.initState();
     _listenIfDriverCancelled();
    _getRecordPermission();
  }

  Future<void> _getRecordPermission() async {
    await _recorder.hasPermission();
  }

   void _listenIfDriverCancelled() {
    _requestRef = FirebaseDatabase.instance.ref('requests/${widget.requestId}/cancelled_by_driver');
    
    _requestRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == true) {
        if (mounted) {
          Navigator.of(context).pop(); // Cierra la pantalla del chat
        }
      }
    });
  }


 @override
  void dispose() {
    _requestRef.onDisconnect();
    super.dispose();
  }

  //  final requestID = widget.requestId;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      child: Material(
        child: Scaffold(
          body: Container(
            height: media.height,
            width: media.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 195, 13, 0),
                  theme,
                ],
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/icon_new.png'),
                opacity: 0.3,
              ),
            ),
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                HeaderChatWidget(
                  driverName: widget.driver!.name,
                  carDetail: '${widget.driver!.color} ${widget.driver!.brand} ${widget.driver!.year}',
                  // carDetail: "${userRequestData['driverDetail']['data']['car_color']} ${userRequestData['driverDetail']['data']['car_make_name']} ${userRequestData['driverDetail']['data']['car_model_name']}",
                  profilePicture: widget.driver!.photoDriver
                ),
                SizedBox(height: media.width * 0.05),
                Expanded(
                  child: ListChatWidget(controller: _controller, requestId: widget.requestId!,),
                ),
                SendMessageWidget(
                  onLogout: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}