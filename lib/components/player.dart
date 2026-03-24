import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:my_first_game/components/checkpoint.dart';
import 'package:my_first_game/components/colission_block.dart';
import 'package:my_first_game/components/custom_hitbox.dart';
import 'package:my_first_game/components/fruit.dart';
import 'package:my_first_game/components/saw.dart';
import 'package:my_first_game/components/utils.dart';
import 'package:my_first_game/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jump,
  doubleJump,
  fall,
  hit,
  wallJump,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Player({this.character = 'Ninja Frog', position}) : super(position: position);

  final String character;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation wallJumpAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double stepTime = 0.05;
  final double moveSpeed = 105;
  final double _gravity = 9.8;
  final double _jumpForce = 310;
  final double _terminalVelocity = 300;
  final double _dashForce = 250;
  final double _dashDuration = 0.14;
  final double _dashCooldown = 0.85;
  final double fixedDeltaTime = 1 / 60;

  double horizontalMovement = 0;
  double accumulatedTime = 0;
  double _dashTimeLeft = 0;
  double _dashCooldownLeft = 0;
  double _dashDirection = 1;

  int _jumpCount = 0;
  bool _jumpQueued = false;
  bool isOnGround = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitBox hitBox =
      CustomHitBox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  bool get isDashReady =>
      _dashCooldownLeft <= 0 && !gotHit && !reachedCheckpoint;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(
      RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint && position.y > game.size.y + size.y) {
      _respawn();
    }

    accumulatedTime = math.min(accumulatedTime + dt, fixedDeltaTime * 3);
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updateDashTimers(fixedDeltaTime);
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
        _updatePlayerState();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collidingWithPlayer();
    } else if (other is Saw) {
      _respawn();
    } else if (other is Checkpoint) {
      _reachedCheckpoint();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void queueJump() {
    if (gotHit || reachedCheckpoint) {
      return;
    }
    _jumpQueued = true;
  }

  void triggerDash() {
    if (!isDashReady) {
      return;
    }

    if (game.playSounds) {
      FlameAudio.play('powerUp.wav', volume: game.soundVolume * 0.8);
    }

    _dashCooldownLeft = _dashCooldown;
    _dashTimeLeft = _dashDuration;
    _dashDirection = horizontalMovement == 0
        ? (scale.x < 0 ? -1 : 1)
        : (horizontalMovement < 0 ? -1 : 1);
    velocity.y = 0;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(state: 'Idle', amount: 11);
    runningAnimation = _spriteAnimation(state: 'Run', amount: 12);
    jumpAnimation = _spriteAnimation(state: 'Jump', amount: 1);
    wallJumpAnimation = _spriteAnimation(state: 'Wall Jump', amount: 5);
    hitAnimation = _spriteAnimation(state: 'Hit', amount: 7)..loop = false;
    fallAnimation = _spriteAnimation(state: 'Fall', amount: 1);
    doubleJumpAnimation = _spriteAnimation(state: 'Double Jump', amount: 6);
    appearingAnimation = _specialSpriteAnimation(state: 'Appearing', amount: 7);
    disappearingAnimation =
        _specialSpriteAnimation(state: 'Desappearing', amount: 7);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.doubleJump: doubleJumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation({
    required String state,
    required int amount,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation({
    required String state,
    required int amount,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        loop: false,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (_jumpQueued) {
      _consumeJump(dt);
    }

    if (_dashTimeLeft > 0) {
      velocity.x = _dashDirection * _dashForce;
      position.x += velocity.x * dt;
      return;
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _consumeJump(double dt) {
    _jumpQueued = false;

    if (isOnGround) {
      _playerJump(dt);
      _jumpCount = 1;
      return;
    }

    if (_jumpCount < 2) {
      _playerJump(dt, doubleJump: true);
      _jumpCount++;
    }
  }

  void _updatePlayerState() {
    var playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (_dashTimeLeft > 0 || velocity.x != 0) {
      playerState = PlayerState.running;
    }
    if (velocity.y > 0) {
      playerState = PlayerState.fall;
    }
    if (velocity.y < 0) {
      playerState = _jumpCount > 1 ? PlayerState.doubleJump : PlayerState.jump;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.platform && checkCollision(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitBox.offsetX - hitBox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitBox.width + hitBox.offsetX;
          break;
        }
      }
    }
  }

  void _applyGravity(double dt) {
    if (_dashTimeLeft > 0) {
      return;
    }

    isOnGround = false;
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity).toDouble();
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.platform) {
        if (checkCollision(this, block) && velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitBox.height - hitBox.offsetY;
          isOnGround = true;
          _jumpCount = 0;
          break;
        }
      } else if (checkCollision(this, block)) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitBox.height - hitBox.offsetY;
          isOnGround = true;
          _jumpCount = 0;
          break;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitBox.offsetY;
          break;
        }
      }
    }
  }

  void _playerJump(double dt, {bool doubleJump = false}) {
    if (game.playSounds) {
      FlameAudio.play('jump.wav', volume: game.soundVolume / 2);
    }

    velocity.y = -(doubleJump ? _jumpForce * 0.92 : _jumpForce);
    position.y += velocity.y * dt;
    isOnGround = false;
  }

  void _updateDashTimers(double dt) {
    if (_dashTimeLeft > 0) {
      _dashTimeLeft = math.max(0, _dashTimeLeft - dt);
    }
    if (_dashCooldownLeft > 0) {
      _dashCooldownLeft = math.max(0, _dashCooldownLeft - dt);
    }
  }

  void _respawn() async {
    if (gotHit || reachedCheckpoint) {
      return;
    }

    if (game.playSounds) {
      FlameAudio.play('hitHurt.wav', volume: game.soundVolume);
    }

    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = game.initialPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    horizontalMovement = 0;
    _jumpCount = 0;
    _dashTimeLeft = 0;
    _dashCooldownLeft = 0;
    position = game.initialPosition.clone();
    _updatePlayerState();
    game.registerRespawn();

    Future.delayed(const Duration(milliseconds: 400), () {
      gotHit = false;
    });
  }

  void _reachedCheckpoint() async {
    if (reachedCheckpoint) {
      return;
    }

    if (game.playSounds) {
      FlameAudio.play('powerUp.wav', volume: game.soundVolume);
    }

    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();

    position = Vector2.all(-1000);
    game.completeLevel();
  }
}
