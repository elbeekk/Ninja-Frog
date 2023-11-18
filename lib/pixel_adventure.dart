import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_game/components/player.dart';
import 'package:my_first_game/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection{
  @override
  Color backgroundColor() => const Color(0xff211f30);
  late final CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystickComponent;
  bool showJoystick = false;
  @override
  FutureOr<void> onLoad() async {
    final world = Level(levelName: 'level_01', player: player);
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    if(showJoystick){
    addJoystick();}

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(showJoystick){
    updateJoystick();}
    super.update(dt);
  }

  void addJoystick() {
    joystickComponent = JoystickComponent(
        knob: SpriteComponent(
          sprite: Sprite(
            images.fromCache('Buttons/Knob.png'),
          ),
        ),
        background: SpriteComponent(
          sprite: Sprite(
            images.fromCache('Buttons/Joystick.png'),
          ),
        ),
        margin: const EdgeInsets.only(left: 32, bottom: 32));
    add(joystickComponent);
  }

  void updateJoystick() {
    switch (joystickComponent.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement=-1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
      player.horizontalMovement=1;
        break;
      default:
        //idle
        player.horizontalMovement=0;
        break;
    }
  }
}
