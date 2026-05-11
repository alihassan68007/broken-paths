import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/scene_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DialogueBox extends StatelessWidget {
  final String speaker;
  final String text;
  final List<Choice> choices;
  final Function(Choice) onChoiceSelected;

  const DialogueBox({
    Key? key,
    required this.speaker,
    required this.text,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (speaker.isNotEmpty)
            Text(
              speaker,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.creamWhite,
              fontSize: 18,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          if (choices.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: choices.map((choice) {
                return ElevatedButton(
                  onPressed: () => onChoiceSelected(choice),
                  child: Text(choice.text),
                );
              }).toList(),
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
        ],
      ),
    );
  }
}
