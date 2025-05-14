import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_user/functions/fect_data_firebase.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ListChatWidget extends StatefulWidget {
  final ScrollController controller;
  final String requestId;

  const ListChatWidget(
      {super.key, required this.controller, required this.requestId});

  @override
  State<ListChatWidget> createState() => _ListChatWidgetState();
}

class _ListChatWidgetState extends State<ListChatWidget> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  final RequestService requestService = RequestService();
  // final requestID = userDetails['onTripRequest']['data']['id'];
  List<Map<String, dynamic>> messages = [];
  StreamSubscription? _messagesSubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    _messagesSubscription = _messagesRef
        .child('requests/${widget.requestId}/array_mensajes')
        .onValue
        .listen((event) async {
      if (!mounted) return;

      if (event.snapshot.value != null && event.snapshot.value is List) {
        List<dynamic> data = event.snapshot.value as List<dynamic>;
        List<Map<String, dynamic>> updatedMessages = [];

        for (int i = 0; i < data.length; i++) {
          if (data[i] != null) {
            Map<String, dynamic> msg = Map<String, dynamic>.from(data[i]);
            updatedMessages.add(msg);

            // Detectar nuevo mensaje
            if (msg["estado"] == "enviado" && msg["origen"] == "driver") {
              _messagesRef
                  .child('requests/${widget.requestId}/array_mensajes/$i')
                  .update({"estado": "visto"});
            }
          }
        }

        setState(() {
          messages = updatedMessages;
        });
      }
    });
  }

  // void _listenToMessages() {
  //   _messagesSubscription = _messagesRef
  //       .child('requests/${widget.requestId}/array_mensajes')
  //       .onValue
  //       .listen((event) {
  //     if (!mounted) return; // Evita actualizar el estado si la pantalla ya no está activa

  //     if (event.snapshot.value != null && event.snapshot.value is List) {
  //       List<dynamic> data = event.snapshot.value as List<dynamic>;
  //       List<Map<String, dynamic>> updatedMessages = [];

  //       for (int i = 0; i < data.length; i++) {
  //         if (data[i] != null) {
  //           Map<String, dynamic> msg = Map<String, dynamic>.from(data[i]);
  //           updatedMessages.add(msg);

  //           // 🔹 Marcar como "visto" solo si la pantalla está abierta
  //           if (msg["estado"] == "enviado" && msg["origen"] == "driver") {
  //             _messagesRef
  //                 .child('requests/${widget.requestId}/array_mensajes/$i')
  //                 .update({"estado": "visto"});
  //           }
  //         }
  //       }

  //       setState(() {
  //         messages = updatedMessages;
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _messagesSubscription
        ?.cancel(); // Cancelar la suscripción al salir de la pantalla
    super.dispose();
  }

  Widget getMessageStatusIcon(String estado) {
    switch (estado) {
      case "enviado":
        return const Icon(Icons.done_all, color: Colors.grey, size: 16);
      case "visto":
        return const Icon(Icons.done_all, color: Colors.blue, size: 16);
      default:
        return Container();
    }
  }

  Widget buildMessageContent(Map<String, dynamic> chatItem) {
    String contenido = chatItem['contenido'] ?? "";
    bool isAudio = contenido.contains("audios/audio_");
    bool isImage = contenido.contains("imagenes/image_");

    if (isAudio) {
      return AudioMessageWidget(audioUrl: contenido);
    } else if (isImage) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: contenido),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            contenido,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Text(
        contenido,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: chatItem['origen'] == "cliente" ? theme : Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return ListView.builder(
      controller: widget.controller,
      itemCount: messages.length,
      padding: EdgeInsets.only(top: media.width * 0.025),
      itemBuilder: (context, i) {
        final chatItem = messages[i];
        final bool isClient = chatItem['origen'] == "cliente";

        return Align(
          alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:
                  isClient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  width: media.width * 0.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft:
                            isClient ? const Radius.circular(20) : Radius.zero,
                        topRight:
                            isClient ? Radius.zero : const Radius.circular(20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                      color: isClient
                          ? Colors.white
                          : Colors.white.withOpacity(0.3)),
                  child: buildMessageContent(chatItem),
                ),
                SizedBox(height: media.width * 0.015),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (chatItem['hora_envio'] ?? "")
                          .split(":")
                          .take(2)
                          .join(":"),
                      style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 169, 169, 169)),
                    ),
                    const SizedBox(width: 5),
                    if (isClient) getMessageStatusIcon(chatItem['estado']),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;

  const AudioMessageWidget({super.key, required this.audioUrl});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero; // Reinicia la barra de progreso
      });
    });
  }

  void _togglePlayback() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayback,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: _duration.inSeconds > 0
                    ? _position.inSeconds / _duration.inSeconds
                    : 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(theme),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class ImageViewer extends StatelessWidget {
  final String imageUrl;

  const ImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoViewGallery.builder(
          itemCount: 1,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
