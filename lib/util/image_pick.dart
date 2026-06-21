/// Seleção de imagem do drink (lado do owner).
///
/// Abre a galeria/arquivos do dispositivo e devolve a foto já **redimensionada
/// e comprimida** em base64 — pronta para guardar inline no [DrinkPreset]
/// (mesmo formato em web e Android, sem depender de caminho de arquivo).
library;

import 'dart:convert';

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

/// Pede uma imagem ao usuário e retorna o base64 (ou `null` se cancelado).
///
/// O limite de tamanho ([maxSide]/[quality]) mantém a imagem leve o bastante
/// para viver no SharedPreferences junto do catálogo.
Future<String?> pickDrinkImageBase64({
  double maxSide = 720,
  int quality = 78,
}) async {
  final XFile? file = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: maxSide,
    maxHeight: maxSide,
    imageQuality: quality,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}
