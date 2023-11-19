import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:my_first_game/components/checkpoint.dart';
import 'package:my_first_game/components/colission_block.dart';
import 'package:my_first_game/components/custom_hitbox.dart';
import 'package:my_first_game/components/fruit.dart';
import 'package:my_first_game/components/saw.dart';
import 'package:my_first_game/components/utils.dart';
import 'package:my_first_game/pixel_adventure.dart';

enum PlayerState { idle, running, jump, doubleJump, fall, hit, wallJump,appearing ,disappearing}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler,CollisionCallbacks {
  String character;

  Player({this.character = 'Ninja Frog', position}) : super(position: position);

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
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool isJumped = false;
  List<CollisionBlock> collisionBlocks = [];
  final double _gravity = 9.8;
  final double _jumpForce = 310;
  final double _terminalVelocity = 300;
  bool gotHit = false;
  CustomHitBox hitBox =  CustomHitBox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  bool reachedCheckpoint  =false;
  double fixedDeltaTime = 1/60;
  double accumulatedTime = 0;


  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    // debugMode = true;
    add(RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(game.player.absolutePosition.y>game.size.y)_respawn();
    accumulatedTime+=dt;
    while(accumulatedTime>=fixedDeltaTime){
      if(!gotHit&&!reachedCheckpoint){
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime-=fixedDeltaTime;
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    isJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    return super.onKeyEvent(event, keysPressed);
  }
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {

    if(other is Fruit){
      other.collidingWithPlayer();
    }else if(other is Saw){
      _respawn();
    }else if(other is Checkpoint){
      _reachedCheckpoint();}

    super.onCollisionStart(intersectionPoints, other);
  }
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(state: 'Idle', amount: 11);
    runningAnimation = _spriteAnimation(state: 'Run', amount: 12);
    jumpAnimation = _spriteAnimation(state: 'Jump', amount: 1);
    wallJumpAnimation = _spriteAnimation(state: 'Wall Jump', amount: 5);
    hitAnimation = _spriteAnimation(state: 'Hit', amount: 7)..loop=false;
    fallAnimation = _spriteAnimation(state: 'Fall', amount: 1);
    doubleJumpAnimation = _spriteAnimation(state: 'Double Jump', amount: 6);
    appearingAnimation = _specialSpriteAnimation(state: 'Appearing', amount: 7);
    disappearingAnimation = _specialSpriteAnimation(state: 'Desappearing', amount: 7);

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
  SpriteAnimation _specialSpriteAnimation(
      {required String state, required int amount}) {
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
    if (isJumped && isOnGround) {
      _playerJump(dt);
    }
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) playerState = PlayerState.running;

    if (velocity.y > 0) playerState = PlayerState.fall;
    if (velocity.y < 0) playerState = PlayerState.jump;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (CollisionBlock block in collisionBlocks) {
      if (!block.platform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitBox.offsetX-hitBox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitBox.width+hitBox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    isOnGround = false;
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (CollisionBlock block in collisionBlocks) {
      if (block.platform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.height-hitBox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.height-hitBox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height-hitBox.offsetY;

            break;
          }
        }
      }
    }
  }

  void _playerJump(double dt)async {
    if(game.playSounds){
      FlameAudio.play('jump.wav',volume:game.soundVolume/2);
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    isJumped = false;
  }

  void _respawn()async {
    if(game.playSounds){
      FlameAudio.play('hitHurt.wav',volume:game.soundVolume);
    }
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x=1;
    position=game.initialPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity=Vector2.zero();
    position = game.initialPosition;
    _updatePlayerState();
    Future.delayed(const Duration(milliseconds: 400),() {
      gotHit=false;
      },);

    // position = startingPosition;
  }

  void _reachedCheckpoint()async {
    if(game.playSounds){
      FlameAudio.play('powerUp.wav',volume:game.soundVolume);
    }
    reachedCheckpoint=true;
    if(scale.x>0){
      position = position-Vector2.all(32);
    }else if(scale.x<0){
      position=position+Vector2(32,-32);
    }
    current = PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint=false;
    position=Vector2.all(-1000);
    Future.delayed(const Duration(seconds: 3),() {
      game.loadNextLevel();
    },);

  }
}
