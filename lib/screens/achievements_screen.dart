import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class Achievement {
  final String title;
  final String description;
  final bool isUnlocked;

  Achievement({required this.title, required this.description, this.isUnlocked = false});
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  final List<Achievement> _mockAchievements = const [
    Achievement(title: "The Balanced Believer", description: "Completed the game with high Iman and moderate Wealth.", isUnlocked: true),
    Achievement(title: "Top Student", description: "Prioritized Knowledge above all else.", isUnlocked: true),
    Achievement(title: "Honest Trader", description: "Built a successful halal business.", isUnlocked: false),
    Achievement(title: "Scholar", description: "Reached 100 Knowledge.", isUnlocked: false),
    Achievement(title: "Respected Elder", description: "Gained the highest respect in the community.", isUnlocked: false),
    Achievement(title: "Philanthropist", description: "Gave away maximum wealth in charity.", isUnlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: AppConstants.aspectRatio,
          child: Container(
            color: AppColors.darkBackground,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.creamWhite, size: 32),
                      onPressed: () {
                        Provider.of<AudioProvider>(context, listen: false).playButtonClick();
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for centering
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _mockAchievements.length,
                    itemBuilder: (context, index) {
                      final ach = _mockAchievements[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: ach.isUnlocked ? AppColors.forestGreen.withOpacity(0.8) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ach.isUnlocked ? AppColors.gold : Colors.white24, width: 2),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  ach.isUnlocked ? Icons.emoji_events : Icons.lock,
                                  color: ach.isUnlocked ? AppColors.gold : Colors.white38,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ach.title,
                                    style: TextStyle(
                                      color: ach.isUnlocked ? AppColors.creamWhite : Colors.white54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ach.description,
                              style: TextStyle(
                                color: ach.isUnlocked ? AppColors.creamWhite.withOpacity(0.9) : Colors.white38,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
