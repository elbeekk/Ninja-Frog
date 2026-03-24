import 'package:my_first_game/models/adventure_hud_state.dart';
import 'package:test/test.dart';

void main() {
  group('AdventureHudState', () {
    test('tracks next level availability and level number', () {
      const state = AdventureHudState(
        phase: AdventurePhase.playing,
        currentLevelIndex: 0,
        totalLevels: 2,
        levelTitle: 'Canopy Run',
        fruitsCollected: 3,
        totalFruits: 12,
        deaths: 1,
        soundEnabled: true,
        touchControlsEnabled: true,
        dashReady: true,
      );

      expect(state.levelNumber, 1);
      expect(state.hasNextLevel, isTrue);
      expect(state.isFinalLevel, isFalse);
    });

    test('copyWith overrides only requested fields', () {
      const state = AdventureHudState(
        phase: AdventurePhase.loading,
        currentLevelIndex: 1,
        totalLevels: 2,
        levelTitle: 'Ruins Relay',
        fruitsCollected: 0,
        totalFruits: 6,
        deaths: 0,
        soundEnabled: true,
        touchControlsEnabled: false,
        dashReady: false,
      );

      final updated = state.copyWith(
        phase: AdventurePhase.levelComplete,
        fruitsCollected: 6,
        deaths: 2,
        dashReady: true,
      );

      expect(updated.phase, AdventurePhase.levelComplete);
      expect(updated.fruitsCollected, 6);
      expect(updated.deaths, 2);
      expect(updated.dashReady, isTrue);
      expect(updated.levelTitle, 'Ruins Relay');
      expect(updated.isFinalLevel, isTrue);
    });
  });
}
