import 'dart:typed_data';

import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as imglib;
import 'package:http/http.dart' as http;

class ImageService {
  final _sharedPreferencesService = locator<SharedPreferencesService>();

  Future<void> validateCache(String? dggCacheKey) async {
    if (dggCacheKey == null) {
      // Dgg cache key is null, clear the cache
      return DefaultCacheManager().emptyCache();
    }

    String? currentCacheKey = _sharedPreferencesService.getCacheVersion();

    if (currentCacheKey != dggCacheKey) {
      // New dgg cache key is different from the previous one we used
      //    Clear the cache and set new cache key version
      await DefaultCacheManager().emptyCache();
      return _sharedPreferencesService.setCacheVersion(dggCacheKey);
    }
  }

  Future<Image?> loadAndProcessEmote(Emote emote) async {
    // Check if emote is in the cache
    String emoteCacheKey = "emote_${emote.name}";
    FileInfo? fileInfo =
        await DefaultCacheManager().getFileFromCache(emoteCacheKey);

    late Uint8List emoteBytes;

    if (fileInfo != null) {
      // Emote is in the cache, use cached version
      emoteBytes = await fileInfo.file.readAsBytes();
    } else {
      // Emote is not in the cache, download it
      http.Client client = http.Client();
      http.Response response = await client.get(Uri.parse(emote.url));

      if (response.statusCode == 200) {
        // Download successful, put in the cache
        emoteBytes = response.bodyBytes;
        await DefaultCacheManager().putFile(emoteCacheKey, emoteBytes);
      } else {
        // Download was not successful, return null
        return null;
      }
    }

    if (emote.mime == "image/gif") {
      return Image.memory(emoteBytes, fit: BoxFit.fitHeight);
    } else {
      if (emote.needsCutting) {
        imglib.Image? image = imglib.decodeImage(emoteBytes);

        if (image != null) {
          emote.frames = [];
          int frameCount = image.width ~/ emote.width;

          for (int i = 0; i < frameCount; i++) {
            imglib.Image frame = imglib.copyCrop(
              image,
              x: i * emote.width,
              y: 0,
              width: emote.width,
              height: image.height,
            );
            emote.frames!.add(Image.memory(
              imglib.encodePng(frame) as Uint8List,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            ));
          }

          return emote.frames![0];
        } else {
          return null;
        }
      } else {
        return Image.memory(emoteBytes, fit: BoxFit.fitHeight);
      }
    }
  }

  Future<Image?> loadAndProcessFlair(Flair flair) async {
    // Check if flair is in the cache
    String flairCacheKey = "flair_${flair.name}";
    FileInfo? fileInfo =
        await DefaultCacheManager().getFileFromCache(flairCacheKey);

    late Uint8List flairBytes;

    if (fileInfo != null) {
      // Flair is in the cache, use cached version
      flairBytes = await fileInfo.file.readAsBytes();
    } else {
      // Flair is not in the cache, download it
      http.Client client = http.Client();
      http.Response response = await client.get(Uri.parse(flair.url!));

      if (response.statusCode == 200) {
        // Download successful, put in the cache
        flairBytes = response.bodyBytes;
        await DefaultCacheManager().putFile(flairCacheKey, flairBytes);
      } else {
        // Download was not successful, return null
        return null;
      }
    }

    return Image.memory(flairBytes, fit: BoxFit.fitHeight);
  }
}
