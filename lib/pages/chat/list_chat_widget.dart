// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_user/functions/fect_data_firebase.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _messagesSubscription = _messagesRef.child('requests/${widget.requestId}/array_mensajes').onValue.listen((event) async {
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
              _messagesRef.child('requests/${widget.requestId}/array_mensajes/$i').update({"estado": "visto"});
            }
          }
        }

        final bool isNearBottom =
            widget.controller.hasClients && widget.controller.position.pixels >= widget.controller.position.maxScrollExtent - 200;

        setState(() {
          messages = updatedMessages;
        });

        if (isNearBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.controller.hasClients) {
              widget.controller.animateTo(
                widget.controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    });
  }


  @override
  void dispose() {
    _messagesSubscription?.cancel(); 
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
        _position = Duration.zero;
      });
    });
  }

  Future<void> _togglePlayback() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.stop(); // reset
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      debugPrint('❌ Error reproduciendo audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo reproducir el audio")),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      width: 280,
      child: Row(
        children: [
          IconButton(
            iconSize: 36,
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: theme),
            onPressed: _togglePlayback,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  minHeight: 4,
                  value: _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

class ImageViewerSave extends StatelessWidget {
  final String imageUrl;

  const ImageViewerSave({super.key, required this.imageUrl});

Future<void> saveImageFromUrl(String imageUrl, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List imageData = response.bodyBytes;

      final result = await ImageGallerySaverPlus.saveImage(
        imageData,
        quality: 80,
        name: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      final filePath = result['filePath'] ?? result['file'];
      if (filePath != null && filePath.toString().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imagen guardada")),
        );

        // Abrir la galería (o la app asociada al archivo)
        await OpenFile.open(filePath.toString());
      } else {
        throw 'No se pudo obtener la ruta del archivo';
      }
    } catch (e) {
      print('❌ Error al guardar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al guardar la imagen")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Guardar imagen',
            onPressed: () => saveImageFromUrl(imageUrl, context),
          ),
        ],
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

