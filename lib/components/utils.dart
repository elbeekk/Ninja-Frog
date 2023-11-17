import 'package:my_first_game/components/colission_block.dart';
import 'package:my_first_game/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.hitBox;
  final playerX = player.position.x+hitbox.offsetX;
  final playerY = player.position.y+hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;
  final fixedX =player.scale.x<0?playerX-(hitbox.offsetX*2)-playerWidth:playerX;
  final fixedY= block.platform?playerY+playerHeight:playerY;
  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      blockX < fixedX + playerWidth);
}
