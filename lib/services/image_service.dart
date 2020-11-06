import 'dart:typed_data';
import 'dart:ui';

import 'package:dgg/datamodels/emotes.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:http/http.dart' as http;

@lazySingleton
class ImageService {
  Future<Image> downloadAndProcessEmote(Emote emote) async {
    http.Client client = new http.Client();
    http.Response req = await client.get(Uri.parse(emote.url));
    Uint8List bytes = req.bodyBytes;

    imglib.Image image = imglib.decodeImage(bytes);

    if (emote.animated) {
      imglib.Image croppped = imglib.copyCrop(
        image,
        0,
        0,
        emote.width,
        image.height,
      );
      return Image.memory(imglib.encodePng(croppped));
    } else {
      return Image.memory(imglib.encodePng(image));
    }
  }
}
