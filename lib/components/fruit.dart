import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:my_first_game/components/custom_hitbox.dart';
import 'package:my_first_game/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure>,CollisionCallbacks {
  final String fruit;

  Fruit({this.fruit = 'Apple', position, size})
      : super(position: position, size: size);
  // {debugMode = true;}

  final double stepTime = 0.05;
  final hitbox = CustomHitBox(offsetX: 10, offsetY: 10, width: 12, height: 12);
   bool collected =false;
  @override
  FutureOr<void> onLoad() {
    priority=-1;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.height, hitbox.width),
        collisionType: CollisionType.passive
        ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    return super.onLoad();
  }

  void collidingWithPlayer() async{
    if(!collected){
      if(game.playSounds)await FlameAudio.play('pickupCoin.wav',volume: game.soundVolume,);
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
            amount: 7,
            stepTime: stepTime,
            textureSize: Vector2.all(32),
            loop: false
        ),
      );
      await animationTicker?.completed;
      Future.delayed(const Duration(milliseconds: 100),() => removeFromParent(),);
    }
  }
}
