import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<File> cropImageToSquare(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final originalImage = img.decodeImage(bytes);

  if (originalImage == null) {
    throw Exception('Resim çözümlenemedi.');
  }

  final centerX = originalImage.width ~/ 2;
  final centerY = originalImage.height ~/ 2;
  final cropSize = 250;

  final left =
      (centerX - cropSize ~/ 2).clamp(0, originalImage.width - cropSize);
  final top =
      (centerY - cropSize ~/ 2).clamp(0, originalImage.height - cropSize);

  final cropped = img.copyCrop(originalImage,
      x: left, y: top, width: cropSize, height: cropSize);
  final croppedBytes = Uint8List.fromList(img.encodeJpg(cropped));

  final newPath =
      '${imageFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final croppedFile = File(newPath);
  return await croppedFile.writeAsBytes(croppedBytes);
}
