import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static Future<void> shareImage(GlobalKey repaintKey, String text) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        await shareText(text);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await shareText(text);
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cyberfit_share.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(ShareParams(
        text: text,
        files: [XFile(file.path)],
      ));
    } catch (_) {
      await shareText(text);
    }
  }
}
