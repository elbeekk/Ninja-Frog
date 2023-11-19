import 'dart:async';
import 'dart:developer';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_game/components/jump_button.dart';
import 'package:my_first_game/components/player.dart';
import 'package:my_first_game/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection{
  @override
  Color backgroundColor() => const Color(0xff211f30);
  late CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystickComponent;
  bool showControls = false;
  List<String> levelNames = ['level_01',];
  int currentLevelIndex = 0;
  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();
    if(showControls){
      addJoystick();
      add(JumpButton());}
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(showControls){
    updateJoystick();}
    super.update(dt);
  }

  void addJoystick() {
    joystickComponent = JoystickComponent(
      priority: 10,
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
    // findGame()?.add(joystickComponent);
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
  void loadNextLevel(){
    if(currentLevelIndex<levelNames.length-1){
      log('increased it');
      currentLevelIndex++;
      _loadLevel();
    }else{
      _loadLevel();
      //no more levels
    }
  }
  void _loadLevel() {
    removeWhere((component) => component.isLoaded);
    Future.delayed(const Duration(seconds: 1),() {

      Level world = Level(levelName: levelNames[currentLevelIndex], player: player);
      cam = CameraComponent.withFixedResolution(
          width: 640, height: 360, world: world);
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    },);

  }
}
