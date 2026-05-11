class GameState {
  int currentChapter;
  String currentSceneId;
  int unlockedChapter;
  int iman;
  int knowledge;
  int wealth;
  int respect;
  int coins;

  GameState({
    this.currentChapter = 1,
    this.currentSceneId = "scene_1",
    this.unlockedChapter = 1,
    this.iman = 50,
    this.knowledge = 50,
    this.wealth = 50,
    this.respect = 50,
    this.coins = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentChapter': currentChapter,
      'currentSceneId': currentSceneId,
      'unlockedChapter': unlockedChapter,
      'iman': iman,
      'knowledge': knowledge,
      'wealth': wealth,
      'respect': respect,
      'coins': coins,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentChapter: json['currentChapter'] ?? 1,
      currentSceneId: json['currentSceneId'] ?? "scene_1",
      unlockedChapter: json['unlockedChapter'] ?? 1,
      iman: json['iman'] ?? 50,
      knowledge: json['knowledge'] ?? 50,
      wealth: json['wealth'] ?? 50,
      respect: json['respect'] ?? 50,
      coins: json['coins'] ?? 0,
    );
  }
}
