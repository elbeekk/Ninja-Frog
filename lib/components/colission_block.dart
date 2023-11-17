import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool platform;

  CollisionBlock({position, size, this.platform = false})
      : super(position: position, size: size) {
    // debugMode = true;
  }
}
