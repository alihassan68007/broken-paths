import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class GameProvider with ChangeNotifier {
  GameState _gameState = GameState();

  GameState get gameState => _gameState;

  void loadGameState(GameState state) {
    _gameState = state;
    notifyListeners();
  }

  void updateStats(Map<String, int>? changes) {
    if (changes == null) return;

    _gameState.iman = (_gameState.iman + (changes['iman'] ?? 0)).clamp(0, 100);
    _gameState.knowledge = (_gameState.knowledge + (changes['knowledge'] ?? 0)).clamp(0, 100);
    _gameState.wealth = (_gameState.wealth + (changes['wealth'] ?? 0)).clamp(0, 100);
    _gameState.respect = (_gameState.respect + (changes['respect'] ?? 0)).clamp(0, 100);
    notifyListeners();
  }

  void addCoins(int amount) {
    _gameState.coins += amount;
    notifyListeners();
  }

  bool unlockNextChapter() {
    if (_gameState.coins >= AppConstants.chapterUnlockCoins) {
      _gameState.coins -= AppConstants.chapterUnlockCoins;
      _gameState.unlockedChapter++;
      _gameState.currentChapter = _gameState.unlockedChapter;
      _gameState.currentSceneId = "scene_1"; // reset to start of next chapter
      notifyListeners();
      return true;
    }
    return false;
  }

  void setScene(String sceneId) {
    _gameState.currentSceneId = sceneId;
    notifyListeners();
  }

  void resetGame() {
    _gameState = GameState();
    notifyListeners();
  }
}
