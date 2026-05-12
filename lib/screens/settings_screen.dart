import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: AppConstants.aspectRatio,
          child: Container(
            color: AppColors.darkBackground,
            padding: const EdgeInsets.all(32.0),
            child: Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.creamWhite, size: 32),
                          onPressed: () {
                            audioProvider.playButtonClick();
                            Navigator.of(context).pop();
                          },
                        ),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48), // To balance the back button
                      ],
                    ),
                    const SizedBox(height: 60),

                    // Music Volume Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_note, color: AppColors.creamWhite, size: 36),
                        const SizedBox(width: 20),
                        const Text('Music', style: TextStyle(color: AppColors.creamWhite, fontSize: 24)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Slider(
                            value: audioProvider.bgmVolume,
                            activeColor: AppColors.forestGreen,
                            inactiveColor: Colors.grey,
                            onChanged: (value) {
                              audioProvider.setBgmVolume(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text('${(audioProvider.bgmVolume * 100).toInt()}%', style: const TextStyle(color: AppColors.gold, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // SFX Volume Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up, color: AppColors.creamWhite, size: 36),
                        const SizedBox(width: 20),
                        const Text('SFX   ', style: TextStyle(color: AppColors.creamWhite, fontSize: 24)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Slider(
                            value: audioProvider.sfxVolume,
                            activeColor: AppColors.forestGreen,
                            inactiveColor: Colors.grey,
                            onChanged: (value) {
                              audioProvider.setSfxVolume(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text('${(audioProvider.sfxVolume * 100).toInt()}%', style: const TextStyle(color: AppColors.gold, fontSize: 20)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
