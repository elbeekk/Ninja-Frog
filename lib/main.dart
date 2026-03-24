import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:my_first_game/ninja_frog_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const NinjaFrogApp());
}
