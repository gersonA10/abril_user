import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class ChatAudioService {
   Future<String> sendImageMessage(String pathImageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final ri = prefs.getString('requestIDRIDE');
    final dio = Dio();
    String result;

    try {
      // Cargar y comprimir la imagen
      final originalImage = File(pathImageFile).readAsBytesSync();
      final decodedImage = img.decodeImage(originalImage)!;

      // Ajustar el tamaño o calidad de la imagen según tus necesidades
      final compressedImage = img.encodeJpg(decodedImage, quality: 50); // Calidad 75%

      // Guardar la imagen comprimida en un archivo temporal
      final tempDir = Directory.systemTemp;
      final compressedFile = File('${tempDir.path}/compressed_image.jpg')
        ..writeAsBytesSync(Uint8List.fromList(compressedImage));

      // Preparar los datos para enviar
      final formData = FormData.fromMap({
        'user_id': userDetails['id'],
        'request_id': ri,
        'imagen': await MultipartFile.fromFile(
          compressedFile.path,
          filename: compressedFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '${url}api/imagen/chat',
        data: formData,
      );

      if (response.statusCode == 200) {
        getCurrentMessages();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        result = 'failed';
      }

      // Borrar el archivo temporal
      await compressedFile.delete();

      return result;
    } catch (e) {
      print('Error: $e');
      return 'failed';
    }
  }
  
  Future<String> sendAudioMessage(String pathAudioFile) async {
    final prefs = await SharedPreferences.getInstance();
    final ri = prefs.getString('requestIDRIDE');
    final dio = Dio();
    String result;
    try {
      final formData = FormData.fromMap({
        'user_id': userDetails['id'],
        'request_id': ri,
        'audio': await MultipartFile.fromFile(
          pathAudioFile,
          filename: pathAudioFile.split('/').last,
        ),
      });
      final response = await dio.post(
        '${url}api/audio/chat',
        data: formData,
      );


      if (response.statusCode == 200) {
        getCurrentMessages();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        result = 'failed';
      }
      return result;
    } on DioException catch (e) {

      return 'failed';
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
      return 'failed';
    }
  }
}
