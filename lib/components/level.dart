import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:my_first_game/components/background_tile.dart';
import 'package:my_first_game/components/checkpoint.dart';
import 'package:my_first_game/components/colission_block.dart';
import 'package:my_first_game/components/fruit.dart';
import 'package:my_first_game/components/player.dart';
import 'package:my_first_game/components/saw.dart';
import 'package:my_first_game/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure>{
  final String levelName;
  final Player player;
  Level({required this.levelName,required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    priority=1;
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    // _scrollingBackground();
    _spawningObjects();
    _addCollisions();
  
    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    final backgroundColor = backgroundLayer?.properties.getValue('BackgroundColor');
    final backgroundTile = BackgroundTile(
      color:backgroundColor ?? 'Yellow',
      position: Vector2.zero(),
    );
    add(backgroundTile);

  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    for(TiledObject spawnPoint in spawnPointsLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x,spawnPoint.y);
          game.initialPosition = Vector2(spawnPoint.x, spawnPoint.y);
          player.scale.x = 1;
          add(player);
          break;
        case 'Fruit':
          final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.height, spawnPoint.width),
          );
          add(fruit);
          break;
        case 'Saw':
          final isVertical = spawnPoint.properties.getValue('isVertical');
          final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');
          final saw =Saw(
            isVertical: isVertical,
            offNeg: offNeg,
            offPos: offPos,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.height, spawnPoint.width),
          );
          add(saw);
          break;
        case 'Checkpoint':
          final checkpoint= Checkpoint(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.height, spawnPoint.width),
          );
          add(checkpoint);
          break;
        default:
      }
    }
  }

  void _addCollisions() {
    final collisionsPointsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    for(TiledObject collision in collisionsPointsLayer?.objects??[]){
      switch(collision.class_){
        case 'Platform':
          final platform = CollisionBlock(
            position: Vector2(collision.x,collision.y),
            size: Vector2(collision.width,collision.height),
            platform: true,
          );
          collisionBlocks.add(platform);
          add(platform);
          break;
        default:
          final block = CollisionBlock(
            position: Vector2(collision.x,collision.y),
            size: Vector2(collision.width,collision.height),
          );
          collisionBlocks.add(block);
          add(block);
      }
    }

    player.collisionBlocks=collisionBlocks;

  }
}