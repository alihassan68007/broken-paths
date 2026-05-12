import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../models/scene_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DialogueBox extends StatefulWidget {
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
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  String displayedText = "";
  Timer? _timer;
  int _currentIndex = 0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant DialogueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    setState(() {
      displayedText = "";
      _currentIndex = 0;
      _isTyping = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _finishTyping() {
    if (_isTyping) {
      _timer?.cancel();
      setState(() {
        displayedText = widget.text;
        _isTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finishTyping,
      child: Container(
        width: double.infinity,
        color: Colors.black.withOpacity(0.8),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.speaker.isNotEmpty)
              Text(
                widget.speaker,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              displayedText,
              style: const TextStyle(
                color: AppColors.creamWhite,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isTyping && widget.choices.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.choices.map((choice) {
                  return ElevatedButton(
                    onPressed: () => widget.onChoiceSelected(choice),
                    child: Text(choice.text),
                  );
                }).toList(),
              ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
