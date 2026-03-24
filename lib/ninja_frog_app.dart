import 'package:flutter/material.dart';
import 'package:my_first_game/adventure_screen.dart';
import 'package:my_first_game/models/adventure_level.dart';
import 'package:my_first_game/ui/pixel_widgets.dart';

class NinjaFrogApp extends StatelessWidget {
  const NinjaFrogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ninja Frog',
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18231C),
        useMaterial3: false,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PixelBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _TitleArt(),
                    const SizedBox(height: 18),
                    const Text(
                      'NINJA FROG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: pixelText,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A compact pixel platformer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: pixelSubtext,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PixelButton(
                          label: 'Play',
                          compact: true,
                          onPressed: () => _openAdventure(context, 0),
                        ),
                        PixelButton(
                          label: 'Stages',
                          compact: true,
                          onPressed: () => _openLevels(context),
                          tone: pixelPanelDark,
                          foreground: pixelText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAdventure(BuildContext context, int levelIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdventureScreen(levelIndex: levelIndex),
      ),
    );
  }

  void _openLevels(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LevelSelectScreen(),
      ),
    );
  }
}

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PixelShell(
      title: 'Stages',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose a route and jump in.',
            style: TextStyle(
              color: pixelSubtext,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < adventureLevels.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == adventureLevels.length - 1 ? 0 : 12,
              ),
              child: _LevelCard(level: adventureLevels[index], index: index),
            ),
        ],
      ),
    );
  }
}

class _PixelShell extends StatelessWidget {
  const _PixelShell({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PixelBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PixelIconButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: pixelText,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleArt extends StatelessWidget {
  const _TitleArt();

  @override
  Widget build(BuildContext context) {
    return const PixelSprite(
      assetPath: 'assets/images/Main Characters/Ninja Frog/Fall (32x32).png',
      frameWidth: 32,
      frameHeight: 32,
      sheetWidth: 352,
      scale: 4.5,
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.index,
  });

  final AdventureLevel level;
  final int index;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(18),
      color: pixelPanelDark,
      borderColor: level.accentColor.withAlpha(110),
      shadow: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'STAGE ${index + 1}',
                    style: const TextStyle(
                      color: pixelSubtext,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    level.difficultyLabel.toUpperCase(),
                    style: TextStyle(
                      color: level.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                level.title.toUpperCase(),
                style: const TextStyle(
                  color: pixelText,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                level.subtitle,
                style: const TextStyle(
                  color: pixelSubtext,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

          final playButton = PixelButton(
            label: 'Play',
            compact: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdventureScreen(levelIndex: index),
                ),
              );
            },
            tone: index == 0 ? pixelAccent : pixelAccentWarm,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 14),
                playButton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              const SizedBox(width: 20),
              playButton,
            ],
          );
        },
      ),
    );
  }
}
