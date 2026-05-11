class Scene {
  final String id;
  final String speaker;
  final String text;
  final String backgroundImage;
  final String? characterSprite;
  final List<Choice> choices;

  Scene({
    required this.id,
    required this.speaker,
    required this.text,
    required this.backgroundImage,
    this.characterSprite,
    required this.choices,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      speaker: json['speaker'],
      text: json['text'],
      backgroundImage: json['backgroundImage'],
      characterSprite: json['characterSprite'],
      choices: (json['choices'] as List)
          .map((choice) => Choice.fromJson(choice))
          .toList(),
    );
  }
}

class Choice {
  final String text;
  final String nextSceneId;
  final Map<String, int>? statChanges;

  Choice({
    required this.text,
    required this.nextSceneId,
    this.statChanges,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    Map<String, int>? stats;
    if (json['statChanges'] != null) {
      stats = Map<String, int>.from(json['statChanges']);
    }
    return Choice(
      text: json['text'],
      nextSceneId: json['nextSceneId'],
      statChanges: stats,
    );
  }
}
