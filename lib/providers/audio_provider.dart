import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;

  bool get isMuted => _isMuted;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
    notifyListeners();
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume;
    _bgmPlayer.setVolume(_bgmVolume);
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume;
    _sfxPlayer.setVolume(_sfxVolume);
    notifyListeners();
  }

  Future<void> playBgm(String assetPath) async {
    if (_isMuted) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _bgmPlayer.play(AssetSource(assetPath));
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (_isMuted) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource(assetPath));
  }

  Future<void> playButtonClick() async {
    if (_isMuted) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource('audio/button_click.mp3'));
  }

  Future<void> playAchievement() async {
    if (_isMuted) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource('audio/achievement.mp3'));
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
