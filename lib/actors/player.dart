import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:my_first_game/pixel_adventure.dart';

enum PlayerState { idle, running, jump, doubleJump, fall, hit, wallJump }

enum PlayerDirection { left, right, idle }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  Player({this.character = 'Ninja Frog', position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation wallJumpAnimation;
  final double stepTime = 0.05;

  PlayerDirection playerDirection = PlayerDirection.idle;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.idle;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.idle;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(state: 'Idle', amount: 11);
    runningAnimation = _spriteAnimation(state: 'Run', amount: 12);
    jumpAnimation = _spriteAnimation(state: 'Jump', amount: 1);
    wallJumpAnimation = _spriteAnimation(state: 'Wall Jump', amount: 5);
    hitAnimation = _spriteAnimation(state: 'Hit', amount: 7);
    fallAnimation = _spriteAnimation(state: 'Fall', amount: 1);
    doubleJumpAnimation = _spriteAnimation(state: 'Double Jump', amount: 6);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.doubleJump: doubleJumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.fall: fallAnimation,
    };

    // current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
      {required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    double dx = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dx -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dx += moveSpeed;
        break;
      case PlayerDirection.idle:
        current = PlayerState.idle;
        break;
      default:
    }
    velocity = Vector2(dx, 0.0);
    position += velocity * dt;
  }
}
