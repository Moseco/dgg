import 'dart:typed_data';
import 'dart:ui';

import 'package:dgg/datamodels/emotes.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:http/http.dart' as http;

class ImageService {
  Future<Image?> downloadAndProcessEmote(Emote emote) async {
    http.Client client = new http.Client();
    http.Response req = await client.get(Uri.parse(emote.url));
    Uint8List bytes = req.bodyBytes;

    if (emote.mime == "image/gif") {
      return Image.memory(bytes);
    } else {
      if (emote.animated) {
        imglib.Image? image = imglib.decodeImage(bytes);

        if (image != null) {
          emote.frames = [];
          int frameCount = image.width ~/ emote.width;

          for (int i = 0; i < frameCount; i++) {
            imglib.Image frame = imglib.copyCrop(
              image,
              i * emote.width,
              0,
              emote.width,
              image.height,
            );
            emote.frames!.add(Image.memory(
              imglib.encodePng(frame) as Uint8List,
              gaplessPlayback: true,
            ));
          }

          return emote.frames![0];
        } else {
          return null;
        }
      } else {
        return Image.memory(bytes);
      }
    }
  }
}
