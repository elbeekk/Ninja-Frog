import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_game/components/level.dart';
import 'package:my_first_game/components/player.dart';
import 'package:my_first_game/models/adventure_hud_state.dart';
import 'package:my_first_game/models/adventure_level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  static final Vector2 _targetVisibleGameSize = Vector2(640, 360);

  PixelAdventure({
    int initialLevelIndex = 0,
    bool touchControlsEnabled = true,
  })  : currentLevelIndex = _normalizeLevelIndex(initialLevelIndex),
        _touchControlsEnabled = touchControlsEnabled,
        hudState = ValueNotifier(
          AdventureHudState.initial(
            currentLevelIndex: _normalizeLevelIndex(initialLevelIndex),
            totalLevels: adventureLevels.length,
            levelTitle:
                adventureLevels[_normalizeLevelIndex(initialLevelIndex)].title,
            soundEnabled: true,
            touchControlsEnabled: touchControlsEnabled,
          ),
        );

  @override
  Color backgroundColor() => const Color(0xFF101A1B);

  static int _normalizeLevelIndex(int index) {
    if (index < 0) {
      return 0;
    }
    if (index >= adventureLevels.length) {
      return adventureLevels.length - 1;
    }
    return index;
  }

  final ValueNotifier<AdventureHudState> hudState;

  CameraComponent? cam;
  Level? _currentLevel;
  HardwareKeyboardDetector? _hardwareKeyboardDetector;
  late Player player;

  bool playSounds = true;
  double soundVolume = 0.75;
  Vector2 initialPosition = Vector2.zero();
  int currentLevelIndex;

  bool _touchControlsEnabled;
  bool _isLoadingLevel = false;
  bool _isLevelReady = false;
  bool _didStartInitialLoad = false;
  double _touchHorizontalMovement = 0;
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  static final Set<LogicalKeyboardKey> _leftKeys = {
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.arrowLeft,
  };
  static final Set<LogicalKeyboardKey> _rightKeys = {
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowRight,
  };
  static final Set<LogicalKeyboardKey> _jumpKeys = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.space,
  };
  static final Set<LogicalKeyboardKey> _dashKeys = {
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  };

  AdventureLevel get currentLevelData => adventureLevels[currentLevelIndex];

  static const List<String> _preloadedImages = [
    'Terrain/Terrain (16x16).png',
    'Items/Fruits/Apple.png',
    'Items/Fruits/Bananas.png',
    'Items/Fruits/Cherries.png',
    'Items/Fruits/Kiwi.png',
    'Items/Fruits/Melon.png',
    'Items/Fruits/Orange.png',
    'Items/Fruits/Pineapple.png',
    'Items/Fruits/Strawberry.png',
    'Items/Fruits/Collected.png',
    'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png',
    'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png',
    'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png',
    'Traps/Saw/On (38x38).png',
    'Main Characters/Ninja Frog/Idle (32x32).png',
    'Main Characters/Ninja Frog/Run (32x32).png',
    'Main Characters/Ninja Frog/Jump (32x32).png',
    'Main Characters/Ninja Frog/Double Jump (32x32).png',
    'Main Characters/Ninja Frog/Fall (32x32).png',
    'Main Characters/Ninja Frog/Hit (32x32).png',
    'Main Characters/Ninja Frog/Wall Jump (32x32).png',
    'Main Characters/Appearing (96x96).png',
    'Main Characters/Desappearing (96x96).png',
  ];

  @override
  FutureOr<void> onLoad() async {
    await images.loadAll(_preloadedImages);
    await FlameAudio.audioCache.loadAll([
      'hitHurt.wav',
      'jump.wav',
      'pickupCoin.wav',
      'powerUp.wav',
    ]);
    _hardwareKeyboardDetector = HardwareKeyboardDetector(
      onKeyEvent: _handleHardwareKeyEvent,
    );
    add(_hardwareKeyboardDetector!);
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    if (!_didStartInitialLoad) {
      _didStartInitialLoad = true;
      unawaited(_loadLevel(resetDeaths: true));
    }
  }

  @override
  void update(double dt) {
    _syncKeyboardMovement();
    if (_isLevelReady && hudState.value.dashReady != player.isDashReady) {
      _emitHudState(dashReady: player.isDashReady);
    }
    super.update(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final currentCamera = cam;
    if (currentCamera != null && currentCamera.isLoaded) {
      _syncCameraZoom(currentCamera);
    }
  }

  Future<void> _loadLevel({bool resetDeaths = false}) async {
    if (_isLoadingLevel) {
      return;
    }

    _isLoadingLevel = true;
    _isLevelReady = false;
    _touchHorizontalMovement = 0;
    _pressedKeys
      ..clear()
      ..addAll(_hardwareKeyboardDetector?.logicalKeysPressed ?? const {});
    pauseEngine();

    try {
      _emitHudState(
        phase: AdventurePhase.loading,
        currentLevelIndex: currentLevelIndex,
        totalLevels: adventureLevels.length,
        levelTitle: currentLevelData.title,
        fruitsCollected: 0,
        totalFruits: 0,
        deaths: resetDeaths ? 0 : hudState.value.deaths,
        soundEnabled: playSounds,
        touchControlsEnabled: _touchControlsEnabled,
        dashReady: false,
      );

      await _removeCurrentScene();

      player = Player();
      final world = Level(levelData: currentLevelData, player: player);
      final nextCamera = CameraComponent(world: world)
        ..viewfinder.anchor = Anchor.topLeft;

      _currentLevel = world;
      cam = nextCamera;

      addAll([nextCamera, world]);
      processLifecycleEvents();
      await Future.wait([world.loaded, nextCamera.loaded]);
      _syncCameraZoom(nextCamera);
      processLifecycleEvents();
      await world.mounted;

      _isLevelReady = true;
      resumeEngine();
      _emitHudState(
        phase: AdventurePhase.playing,
        currentLevelIndex: currentLevelIndex,
        totalLevels: adventureLevels.length,
        levelTitle: currentLevelData.title,
        soundEnabled: playSounds,
        touchControlsEnabled: _touchControlsEnabled,
        dashReady: player.isDashReady,
      );
    } finally {
      _isLoadingLevel = false;
    }
  }

  void _syncCameraZoom(CameraComponent camera) {
    final viewportSize = camera.viewport.size;
    final referenceSize =
        viewportSize.x > 0 && viewportSize.y > 0 ? viewportSize : size;
    final zoomX = referenceSize.x / _targetVisibleGameSize.x;
    final zoomY = referenceSize.y / _targetVisibleGameSize.y;
    final zoom = math.min(zoomX, zoomY);
    camera.viewfinder.zoom = zoom > 0 ? zoom : 1;
  }

  Future<void> _removeCurrentScene() async {
    final currentLevel = _currentLevel;
    final currentCamera = cam;

    currentLevel?.removeFromParent();
    currentCamera?.removeFromParent();
    processLifecycleEvents();

    if (currentLevel != null) {
      await currentLevel.removed;
    }
    if (currentCamera != null) {
      await currentCamera.removed;
    }

    _currentLevel = null;
    cam = null;
  }

  void _handleHardwareKeyEvent(KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _pressedKeys.add(key);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(key);
    }

    if (!_isLevelReady || hudState.value.phase != AdventurePhase.playing) {
      return;
    }

    if (event is KeyDownEvent) {
      if (_jumpKeys.contains(key)) {
        player.queueJump();
      }
      if (_dashKeys.contains(key)) {
        player.triggerDash();
        _emitHudState(dashReady: player.isDashReady);
      }
    }

    _syncKeyboardMovement();
  }

  void _syncKeyboardMovement() {
    if (!_isLevelReady || hudState.value.phase != AdventurePhase.playing) {
      if (_isLevelReady) {
        player.horizontalMovement = 0;
      }
      return;
    }

    final movingLeft = _pressedKeys.any(_leftKeys.contains);
    final movingRight = _pressedKeys.any(_rightKeys.contains);
    final keyboardMovement =
        movingLeft == movingRight ? 0.0 : (movingLeft ? -1.0 : 1.0);

    if (keyboardMovement != 0) {
      player.horizontalMovement = keyboardMovement;
      return;
    }

    if (_touchHorizontalMovement != 0) {
      player.horizontalMovement = _touchHorizontalMovement;
      return;
    }

    player.horizontalMovement = 0;
  }

  Future<void> loadNextLevel() async {
    if (currentLevelIndex < adventureLevels.length - 1) {
      currentLevelIndex++;
      await _loadLevel();
    }
  }

  void restartLevel() {
    unawaited(_loadLevel());
  }

  void jump() {
    if (_isLevelReady) {
      player.queueJump();
    }
  }

  void dash() {
    if (_isLevelReady) {
      player.triggerDash();
      _emitHudState(dashReady: player.isDashReady);
    }
  }

  void pauseAdventure() {
    if (!_isLevelReady || hudState.value.phase != AdventurePhase.playing) {
      return;
    }

    pauseEngine();
    _emitHudState(phase: AdventurePhase.paused, dashReady: player.isDashReady);
  }

  void resumeAdventure() {
    if (!_isLevelReady ||
        hudState.value.phase == AdventurePhase.levelComplete) {
      return;
    }

    resumeEngine();
    _emitHudState(phase: AdventurePhase.playing, dashReady: player.isDashReady);
  }

  void toggleSound() {
    playSounds = !playSounds;
    _emitHudState(soundEnabled: playSounds);
  }

  void setTouchControls(bool enabled) {
    if (_touchControlsEnabled == enabled) {
      return;
    }

    _touchControlsEnabled = enabled;
    _touchHorizontalMovement = 0;
    _emitHudState(touchControlsEnabled: enabled);

    if (!_isLevelReady) {
      return;
    }
  }

  void setTouchHorizontalMovement(double movement) {
    _touchHorizontalMovement = movement.clamp(-1, 1).toDouble();
    _syncKeyboardMovement();
  }

  void registerLevelFruitCount(int totalFruits) {
    _emitHudState(
      totalFruits: totalFruits,
      fruitsCollected: 0,
      dashReady: _isLevelReady ? player.isDashReady : false,
    );
  }

  void registerFruitCollected() {
    final nextCount = hudState.value.fruitsCollected + 1;
    _emitHudState(
      fruitsCollected: nextCount > hudState.value.totalFruits
          ? hudState.value.totalFruits
          : nextCount,
    );
  }

  void registerRespawn() {
    _emitHudState(
      deaths: hudState.value.deaths + 1,
      dashReady: player.isDashReady,
    );
  }

  void completeLevel() {
    if (!_isLevelReady ||
        hudState.value.phase == AdventurePhase.levelComplete) {
      return;
    }

    pauseEngine();
    _emitHudState(
      phase: AdventurePhase.levelComplete,
      dashReady: player.isDashReady,
    );
  }

  void disposeSession() {
    pauseEngine();
    hudState.dispose();
  }

  void _emitHudState({
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
    hudState.value = hudState.value.copyWith(
      phase: phase,
      currentLevelIndex: currentLevelIndex,
      totalLevels: totalLevels,
      levelTitle: levelTitle,
      fruitsCollected: fruitsCollected,
      totalFruits: totalFruits,
      deaths: deaths,
      soundEnabled: soundEnabled,
      touchControlsEnabled: touchControlsEnabled,
      dashReady: dashReady,
    );
  }
}
