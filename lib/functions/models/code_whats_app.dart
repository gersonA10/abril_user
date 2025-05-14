// To parse this JSON data, do
//
//     final codeWhatsApp = codeWhatsAppFromJson(jsonString);

import 'dart:convert';

CodeWhatsApp codeWhatsAppFromJson(String str) =>
    CodeWhatsApp.fromJson(json.decode(str));

String codeWhatsAppToJson(CodeWhatsApp data) => json.encode(data.toJson());

class CodeWhatsApp {
  String message;
  int codigo;

  CodeWhatsApp({
    required this.message,
    required this.codigo,
  });

  CodeWhatsApp copyWith({
    String? message,
    int? codigo,
  }) =>
      CodeWhatsApp(
        message: message ?? this.message,
        codigo: codigo ?? this.codigo,
      );

  factory CodeWhatsApp.fromJson(Map<String, dynamic> json) => CodeWhatsApp(
        message: json["message"],
        codigo: json["codigo"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "codigo": codigo,
      };
}
