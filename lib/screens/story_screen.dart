import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/audio_provider.dart';
import '../models/scene_model.dart';
import '../services/story_service.dart';
import '../utils/constants.dart';
import '../widgets/stats_bar.dart';
import '../widgets/dialogue_box.dart';
import 'hill_climb_screen.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  Map<String, Scene> _scenes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _scenes = await StoryService.loadChapter(gameProvider.gameState.currentChapter);

    // Fallback if scenes are empty, create a dummy scene
    if (_scenes.isEmpty) {
      _scenes["scene_1"] = Scene(
        id: "scene_1",
        speaker: "System",
        text: "Chapter ${gameProvider.gameState.currentChapter} coming soon or not found.",
        backgroundImage: "",
        choices: [
          Choice(text: "End Chapter", nextSceneId: "end_chapter")
        ]
      );
      gameProvider.setScene("scene_1");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleChoice(Choice choice) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (choice.statChanges != null) {
      gameProvider.updateStats(choice.statChanges);
    }

    if (choice.nextSceneId == "end_chapter" || !_scenes.containsKey(choice.nextSceneId)) {
      _showChapterEndDialog();
    } else {
      gameProvider.setScene(choice.nextSceneId);
    }
  }

  void _showChapterEndDialog() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final coinsNeeded = AppConstants.chapterUnlockCoins;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text('Chapter Complete', style: TextStyle(color: AppColors.gold)),
          content: Text(
            'You have finished this chapter.\nYou need $coinsNeeded coins to unlock the next chapter.\nCurrent coins: ${gameProvider.gameState.coins}',
            style: const TextStyle(color: AppColors.creamWhite),
          ),
          actions: [
            if (gameProvider.gameState.coins >= coinsNeeded)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (gameProvider.unlockNextChapter()) {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadChapter();
                  }
                },
                child: const Text('Unlock Next Chapter', style: TextStyle(color: AppColors.forestGreen)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HillClimbScreen()),
                );
              },
              child: const Text('Play Hill Climb to Earn Coins', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final currentSceneId = gameProvider.gameState.currentSceneId;
        final scene = _scenes[currentSceneId];

        if (scene == null) {
           return const Scaffold(
             backgroundColor: Colors.black,
             body: Center(child: Text("Scene not found", style: TextStyle(color: Colors.white))),
           );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: AspectRatio(
              aspectRatio: AppConstants.aspectRatio,
              child: Container(
                color: AppColors.darkBackground,
                child: Stack(
                  children: [
                    // Layer 1: Background Image (Placeholder logic)
                    if (scene.backgroundImage.isNotEmpty)
                      Positioned.fill(
                        child: Image.asset(
                          scene.backgroundImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
                        ),
                      ),

                    // Layer 2: Stats Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: StatsBar(
                        iman: gameProvider.gameState.iman,
                        knowledge: gameProvider.gameState.knowledge,
                        wealth: gameProvider.gameState.wealth,
                        respect: gameProvider.gameState.respect,
                        coins: gameProvider.gameState.coins,
                      ),
                    ),

                    // Layer 3: Character Sprite (Placeholder logic)
                    if (scene.characterSprite != null && scene.characterSprite!.isNotEmpty)
                      Positioned(
                        right: 50,
                        bottom: 100,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Image.asset(
                          scene.characterSprite!,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 200, color: Colors.white),
                        ),
                      ),

                    // Layer 4: Dialogue Box
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: DialogueBox(
                        speaker: scene.speaker,
                        text: scene.text,
                        choices: scene.choices,
                        onChoiceSelected: _handleChoice,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
