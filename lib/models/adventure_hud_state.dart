enum AdventurePhase {
  loading,
  playing,
  paused,
  levelComplete,
}

class AdventureHudState {
  const AdventureHudState({
    required this.phase,
    required this.currentLevelIndex,
    required this.totalLevels,
    required this.levelTitle,
    required this.fruitsCollected,
    required this.totalFruits,
    required this.deaths,
    required this.soundEnabled,
    required this.touchControlsEnabled,
    required this.dashReady,
  });

  factory AdventureHudState.initial({
    required int currentLevelIndex,
    required int totalLevels,
    required String levelTitle,
    required bool soundEnabled,
    required bool touchControlsEnabled,
  }) {
    return AdventureHudState(
      phase: AdventurePhase.loading,
      currentLevelIndex: currentLevelIndex,
      totalLevels: totalLevels,
      levelTitle: levelTitle,
      fruitsCollected: 0,
      totalFruits: 0,
      deaths: 0,
      soundEnabled: soundEnabled,
      touchControlsEnabled: touchControlsEnabled,
      dashReady: false,
    );
  }

  final AdventurePhase phase;
  final int currentLevelIndex;
  final int totalLevels;
  final String levelTitle;
  final int fruitsCollected;
  final int totalFruits;
  final int deaths;
  final bool soundEnabled;
  final bool touchControlsEnabled;
  final bool dashReady;

  bool get hasNextLevel => currentLevelIndex < totalLevels - 1;
  bool get isFinalLevel => !hasNextLevel;
  int get levelNumber => currentLevelIndex + 1;

  AdventureHudState copyWith({
    AdventurePhase? phase,
    int? currentLevelIndex,
    int? totalLevels,
    String? levelTitle,
    int? fruitsCollected,
    int? totalFruits,
    int? deaths,
    bool? soundEnabled,
    bool? touchControlsEnabled,
    bool? dashReady,
  }) {
    return AdventureHudState(
      phase: phase ?? this.phase,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      totalLevels: totalLevels ?? this.totalLevels,
      levelTitle: levelTitle ?? this.levelTitle,
      fruitsCollected: fruitsCollected ?? this.fruitsCollected,
      totalFruits: totalFruits ?? this.totalFruits,
      deaths: deaths ?? this.deaths,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      touchControlsEnabled: touchControlsEnabled ?? this.touchControlsEnabled,
      dashReady: dashReady ?? this.dashReady,
    );
  }
}
