import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:my_first_game/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure>,TapCallbacks{
  JumpButton();
  final margin = 32;
  final buttonSize = 80;
  @override
  FutureOr<void> onLoad() {
    priority=100;
    sprite=Sprite(game.images.fromCache('Buttons/JumpButton.png'));
    position = Vector2(game.size.x-margin-buttonSize, game.size.y-margin-buttonSize);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.isJumped=true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.isJumped=false;
    super.onTapUp(event);
  }
}