import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
    notifyListeners();
  }

  Future<void> playBgm(String assetPath) async {
    if (_isMuted) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(assetPath));
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (_isMuted) return;
    await _sfxPlayer.play(AssetSource(assetPath));
  }

  Future<void> playButtonClick() async {
    if (_isMuted) return;
    // Assuming a placeholder path for now
    await _sfxPlayer.play(AssetSource('audio/button_click.mp3'));
  }

  Future<void> playAchievement() async {
    if (_isMuted) return;
    // Assuming a placeholder path for now
    await _sfxPlayer.play(AssetSource('audio/achievement.mp3'));
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
