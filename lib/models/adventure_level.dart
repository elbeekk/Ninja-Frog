import 'package:flutter/material.dart';

class AdventureLevel {
  const AdventureLevel({
    required this.mapName,
    required this.title,
    required this.subtitle,
    required this.difficultyLabel,
    required this.accentColor,
  });

  final String mapName;
  final String title;
  final String subtitle;
  final String difficultyLabel;
  final Color accentColor;
}

const adventureLevels = <AdventureLevel>[
  AdventureLevel(
    mapName: 'level_01',
    title: 'Canopy Run',
    subtitle:
        'Warm up across orchard ledges, drifting saws, and quick fruit lines.',
    difficultyLabel: 'Starter',
    accentColor: Color(0xFF6ED38B),
  ),
  AdventureLevel(
    mapName: 'level_02',
    title: 'Ruins Relay',
    subtitle: 'Tighter jumps, faster hazards, and less room to recover.',
    difficultyLabel: 'Advanced',
    accentColor: Color(0xFFF4B261),
  ),
];
