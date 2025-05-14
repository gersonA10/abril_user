// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_user/functions/chat_audio_service.dart';
// import 'package:flutter_user/functions/functions.dart';
// import 'package:flutter_user/styles/styles.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'dart:async';

// class SendMessage extends StatefulWidget {
//   const SendMessage({super.key, required this.onLogout});

//   final VoidCallback onLogout;

//   @override
//   State<SendMessage> createState() => _SendMessageState();
// }

// class _SendMessageState extends State<SendMessage> {
//   bool isLoadingMessage = false;
//   final TextEditingController chatText = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   final AudioRecorder _recorder = AudioRecorder();
//   bool isRecording = false;
//    final audioService = ChatAudioService();
//   bool showSendButton = false;
//   Timer? _recordingTimer;

//     Future<void> selectImage() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Galería'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Cámara'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//     Future<void> _pickImage(ImageSource source) async {

//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         isLoadingMessage = true; // Mostrar el loader
//       });

//       final result = await audioService.sendImageMessage(pickedFile.path);

//       setState(() {
//         isLoadingMessage = false; // Ocultar el loader
//       });

//       if (result == 'logout') {
//         widget.onLogout();
//       }
//     }
//   }

// Future<void> startRecording() async {
//   // final hasPermission = await _recorder.hasPermission();
//   // if (hasPermission) {
//     // Obtener directorio válido para guardar el audio
//     Directory directory = await getApplicationDocumentsDirectory();
//     String filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

//     await _recorder.start(
//       const RecordConfig(),
//       path: filePath,
//     );

//     setState(() => isRecording = true);
//     _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {});
//     });
//   // }
// }


//   Future<void> stopRecording() async {
//     if (isRecording) {
//       final path = await _recorder.stop();
//       _recordingTimer?.cancel();
//       setState(() => isRecording = false);
//       // Llamar al servicio para enviar audio
//       final resp = await audioService.sendAudioMessage(path!);
//       _recorder.dispose();
//       if (resp == 'logout') {
//         widget.onLogout();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         // Text('data'),
//         if (isLoadingMessage == true) Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Text('Enviando...', style: TextStyle(color: Colors.white),),
//             SizedBox(width: 10,),
//             CircularProgressIndicator(color: Colors.white,)
//           ],
//         ),
//         Container(
//           margin: const EdgeInsets.all(10),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.all(Radius.circular(20)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.photo_library, color: theme),
//                 onPressed: selectImage,
//               ),
//               SizedBox(
//                 width: showSendButton ? size.width * 0.52 : size.width * 0.68,
//                 child: TextField(
//                   controller: chatText,
//                   decoration: InputDecoration(
//                     hintText: isRecording ? "Grabando audio..." : "Escribe un mensaje",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white
//                   ),
//                   onChanged: (text) {
//                     setState(() => showSendButton = text.isNotEmpty);
//                   },
//                 ),
//               ),
//               SizedBox(width: showSendButton ? 50 : 20,),
//               !showSendButton ? 
//               GestureDetector(
//                 onLongPress: startRecording,
//                 onLongPressUp: stopRecording,
//                 child: Icon(Icons.mic, color: isRecording ? Colors.green : theme),
//               ) : Container(),
//               SizedBox(width: 10,),
//               showSendButton
//                   ? GestureDetector(
//                       onTap: () async {
//                         String message = chatText.text;
//                         setState(() => isLoadingMessage = true);
//                         Future.delayed(Duration(seconds: 1), () {
//                           setState(() {
//                             chatText.clear();
//                             isLoadingMessage = false;
//                             showSendButton = false;
//                           });
//                         });
//                          final val = await sendMessage(message);
                         
//                       },
//                       child: CircleAvatar(
//                         radius: 22,
//                         backgroundColor: theme,
//                         child: Icon(Icons.send, color: Colors.white),
//                       ),
//                     )
//                   : SizedBox.shrink(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
