import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scene_model.dart';

class StoryService {
  static Future<Map<String, Scene>> loadChapter(int chapterNumber) async {
    try {
      final String response = await rootBundle.loadString('assets/data/story_ch$chapterNumber.json');
      final Map<String, dynamic> data = json.decode(response);

      Map<String, Scene> scenes = {};

      if (data.containsKey('scenes')) {
        for (var sceneData in data['scenes']) {
          Scene scene = Scene.fromJson(sceneData);
          scenes[scene.id] = scene;
        }
      }

      return scenes;
    } catch (e) {
      print("Error loading story chapter $chapterNumber: $e");
      return {};
    }
  }
}
