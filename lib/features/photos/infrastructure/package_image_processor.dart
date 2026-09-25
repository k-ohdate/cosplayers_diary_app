import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../domain/photo_service.dart';

class PackageImageProcessor implements ImageProcessor {
  const PackageImageProcessor();

  @override
  Future<Uint8List> resizeForStorage(Uint8List source, {required int maxLongEdge}) async {
    final decoded = image.decodeImage(source);
    if (decoded == null) throw const FormatException('画像を読み取れません');
    image.bakeOrientation(decoded);
    if (decoded.width <= maxLongEdge && decoded.height <= maxLongEdge) return source;
    final resized = decoded.width >= decoded.height
        ? image.copyResize(decoded, width: maxLongEdge, interpolation: image.Interpolation.cubic)
        : image.copyResize(decoded, height: maxLongEdge, interpolation: image.Interpolation.cubic);
    return Uint8List.fromList(image.encodeJpg(resized, quality: 90));
  }
}
