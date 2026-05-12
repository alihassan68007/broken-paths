import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import 'story_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
// import 'load_game_screen.dart'; // To be implemented later

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  Widget _buildMenuButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 250,
        child: ElevatedButton(
          onPressed: () {
            Provider.of<AudioProvider>(context, listen: false).playButtonClick();
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.black.withOpacity(0.6),
            side: const BorderSide(color: AppColors.gold, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.creamWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: AppConstants.aspectRatio,
          child: Container(
            decoration: const BoxDecoration(
              // In the future, replace color with a beautiful cinematic background image
              color: AppColors.darkBackground,
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/bg_home.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken), // Darken for readability
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BROKEN PATHS',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                _buildMenuButton(context, 'New Game', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StoryScreen()),
                  );
                }),
                _buildMenuButton(context, 'Load Game', () {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoadGameScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Load Game - Coming Soon')));
                }),
                _buildMenuButton(context, 'Settings', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }),
                _buildMenuButton(context, 'Achievements', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
