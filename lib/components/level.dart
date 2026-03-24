import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:my_first_game/components/checkpoint.dart';
import 'package:my_first_game/components/colission_block.dart';
import 'package:my_first_game/components/fruit.dart';
import 'package:my_first_game/components/player.dart';
import 'package:my_first_game/components/saw.dart';
import 'package:my_first_game/models/adventure_level.dart';
import 'package:my_first_game/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  Level({
    required this.levelData,
    required this.player,
  });

  final AdventureLevel levelData;
  final Player player;

  late TiledComponent level;
  final List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    priority = 1;
    level =
        await TiledComponent.load('${levelData.mapName}.tmx', Vector2.all(16));
    add(level);
    _spawnObjects();
    _addCollisions();
    return super.onLoad();
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    var fruitCount = 0;

    for (final spawnPoint in spawnPointsLayer?.objects ?? <TiledObject>[]) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          game.initialPosition = Vector2(spawnPoint.x, spawnPoint.y);
          player.scale.x = 1;
          add(player);
          break;
        case 'Fruit':
          fruitCount++;
          add(
            Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.height, spawnPoint.width),
            ),
          );
          break;
        case 'Saw':
          add(
            Saw(
              isVertical: spawnPoint.properties.getValue('isVertical'),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.height, spawnPoint.width),
            ),
          );
          break;
        case 'Checkpoint':
          add(
            Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.height, spawnPoint.width),
            ),
          );
          break;
        default:
      }
    }

    game.registerLevelFruitCount(fruitCount);
  }

  void _addCollisions() {
    final collisionsPointsLayer =
        level.tileMap.getLayer<ObjectGroup>('Collisions');

    for (final collision in collisionsPointsLayer?.objects ?? <TiledObject>[]) {
      switch (collision.class_) {
        case 'Platform':
          final platform = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
            platform: true,
          );
          collisionBlocks.add(platform);
          add(platform);
          break;
        default:
          final block = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          );
          collisionBlocks.add(block);
          add(block);
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
