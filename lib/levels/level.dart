import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:my_first_game/actors/player.dart';

class Level extends World{
  final String levelName;
  final Player player;
  Level({required this.levelName,required this.player});


  late TiledComponent level;
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for(TiledObject spawnPoint in spawnPointsLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x,spawnPoint.y);
          add(player);
          break;
        default:
      }
    }
    return super.onLoad();
  }
}