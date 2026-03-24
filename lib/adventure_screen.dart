import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_first_game/models/adventure_hud_state.dart';
import 'package:my_first_game/pixel_adventure.dart';
import 'package:my_first_game/ui/pixel_widgets.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key, required this.levelIndex});

  final int levelIndex;

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  late final PixelAdventure _game;
  bool _touchControlsEnabled = true;
  bool _allowRoutePop = false;

  @override
  void initState() {
    super.initState();
    _game = PixelAdventure(initialLevelIndex: widget.levelIndex);
  }

  @override
  void dispose() {
    _game.disposeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final prefersTouchControls = _shouldUseTouchControls(mediaQuery);

    if (prefersTouchControls != _touchControlsEnabled) {
      _touchControlsEnabled = prefersTouchControls;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _game.setTouchControls(prefersTouchControls);
        }
      });
    }

    return PopScope<void>(
      canPop: _allowRoutePop,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            GameWidget<PixelAdventure>(
              game: _game,
              autofocus: true,
              backgroundBuilder: (context) {
                return const PixelBackdrop(child: SizedBox.expand());
              },
            ),
            ValueListenableBuilder<AdventureHudState>(
              valueListenable: _game.hudState,
              builder: (context, hudState, _) {
                final showModalOverlay =
                    hudState.phase == AdventurePhase.paused ||
                        hudState.phase == AdventurePhase.levelComplete ||
                        hudState.phase == AdventurePhase.loading;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hudState.touchControlsEnabled && !showModalOverlay)
                      _TouchControlLayer(
                        onJump: _game.jump,
                        onMovementChanged: _game.setTouchHorizontalMovement,
                      ),
                    IgnorePointer(
                      ignoring: showModalOverlay,
                      child: _GameHud(
                        hudState: hudState,
                        onPause: _game.pauseAdventure,
                        onToggleSound: _game.toggleSound,
                      ),
                    ),
                    if (showModalOverlay)
                      _OverlayLayer(
                        hudState: hudState,
                        onResume: _game.resumeAdventure,
                        onRestart: _game.restartLevel,
                        onNextLevel:
                            hudState.hasNextLevel ? _game.loadNextLevel : null,
                        onExit: _exitAdventure,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldUseTouchControls(MediaQueryData mediaQuery) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return mediaQuery.size.shortestSide < 700;
    }
  }

  void _exitAdventure() {
    if (_allowRoutePop) {
      return;
    }

    setState(() {
      _allowRoutePop = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.hudState,
    required this.onPause,
    required this.onToggleSound,
  });

  final AdventureHudState hudState;
  final VoidCallback onPause;
  final VoidCallback onToggleSound;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        10 + padding.left,
        10 + padding.top,
        10 + padding.right,
        10 + padding.bottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _FruitCounterBadge(
                    collected: hudState.fruitsCollected,
                    total: hudState.totalFruits,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PixelIconButton(
                icon: hudState.soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                onPressed: onToggleSound,
                tone: hudState.soundEnabled ? pixelAccent : pixelPanelDark,
                iconColor: hudState.soundEnabled ? pixelInk : pixelText,
              ),
              const SizedBox(width: 8),
              PixelIconButton(
                icon: Icons.pause_rounded,
                onPressed: onPause,
                tone: pixelAccentWarm,
                iconColor: pixelInk,
              ),
            ],
          ),
          const Spacer(),
          if (!hudState.touchControlsEnabled)
            const Align(
              alignment: Alignment.bottomLeft,
              child: _KeyboardHint(),
            ),
        ],
      ),
    );
  }
}

class _TouchControlLayer extends StatefulWidget {
  const _TouchControlLayer({
    required this.onJump,
    required this.onMovementChanged,
  });

  final VoidCallback onJump;
  final ValueChanged<double> onMovementChanged;

  @override
  State<_TouchControlLayer> createState() => _TouchControlLayerState();
}

class _TouchControlLayerState extends State<_TouchControlLayer>
    with SingleTickerProviderStateMixin {
  static bool _didShowIntroHint = false;

  int? _movementPointer;
  Offset? _joystickCenter;
  double _joystickDeltaX = 0;
  late final AnimationController _introPulseController;
  Timer? _introTimer;
  bool _showIntroHint = false;

  @override
  void initState() {
    super.initState();
    _introPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      lowerBound: 0.35,
      upperBound: 1,
    );

    if (!_didShowIntroHint) {
      _didShowIntroHint = true;
      _showIntroHint = true;
      _introPulseController.repeat(reverse: true);
      _introTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showIntroHint = false;
        });
        _introPulseController.stop();
      });
    } else {
      _introPulseController.value = 1;
    }
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _introPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final controlTopInset = mediaQuery.padding.top + 72;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final joystickSize =
            (size.shortestSide * 0.28).clamp(132.0, 176.0).toDouble();
        final knobSize = joystickSize * 0.44;
        final maxTravel = (joystickSize - knobSize) / 2;

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) => _handlePointerDown(
            localPosition: event.localPosition,
            pointer: event.pointer,
            size: size,
            controlTopInset: controlTopInset,
          ),
          onPointerMove: (event) {
            if (event.pointer == _movementPointer) {
              _updateMovement(
                position: event.localPosition,
                maxTravel: maxTravel,
              );
            }
          },
          onPointerUp: (event) => _handlePointerEnd(event.pointer),
          onPointerCancel: (event) => _handlePointerEnd(event.pointer),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_showIntroHint)
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _introPulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _introPulseController.value,
                        child: child,
                      );
                    },
                    child: const _TouchIntroOverlay(),
                  ),
                ),
              if (_joystickCenter != null)
                _FloatingJoystick(
                  center: _joystickCenter!,
                  size: joystickSize,
                  knobSize: knobSize,
                  knobOffsetX: _joystickDeltaX,
                ),
            ],
          ),
        );
      },
    );
  }

  void _handlePointerDown({
    required Offset localPosition,
    required int pointer,
    required Size size,
    required double controlTopInset,
  }) {
    if (localPosition.dy < controlTopInset) {
      return;
    }

    if (localPosition.dx < size.width / 2) {
      _movementPointer ??= pointer;
      if (_movementPointer == pointer) {
        setState(() {
          _joystickCenter = localPosition;
          _joystickDeltaX = 0;
        });
        widget.onMovementChanged(0);
      }
      return;
    }

    widget.onJump();
  }

  void _handlePointerEnd(int pointer) {
    if (pointer != _movementPointer) {
      return;
    }

    _movementPointer = null;
    setState(() {
      _joystickCenter = null;
      _joystickDeltaX = 0;
    });
    widget.onMovementChanged(0);
  }

  void _updateMovement({
    required Offset position,
    required double maxTravel,
  }) {
    final center = _joystickCenter;
    if (center == null) {
      return;
    }

    final deltaX = (position.dx - center.dx).clamp(-maxTravel, maxTravel);
    final deadZone = maxTravel * 0.18;

    setState(() {
      _joystickDeltaX = deltaX.toDouble();
    });

    if (deltaX.abs() <= deadZone) {
      widget.onMovementChanged(0);
      return;
    }

    widget.onMovementChanged((deltaX / maxTravel).toDouble());
  }
}

class _TouchIntroOverlay extends StatelessWidget {
  const _TouchIntroOverlay();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _TouchIntroZone(
            label: 'Joystick',
            tone: pixelAccent,
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          child: _TouchIntroZone(
            label: 'Jump',
            tone: pixelAccentWarm,
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }
}

class _TouchIntroZone extends StatelessWidget {
  const _TouchIntroZone({
    required this.label,
    required this.tone,
    required this.alignment,
  });

  final String label;
  final Color tone;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withAlpha(40),
        border: Border(
          right: alignment == Alignment.centerLeft
              ? BorderSide(color: pixelText.withAlpha(70), width: 1.5)
              : BorderSide.none,
          left: alignment == Alignment.centerRight
              ? BorderSide(color: pixelText.withAlpha(70), width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: pixelText,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 22,
            shadows: [
              const Shadow(
                color: pixelShadow,
                offset: Offset(2, 2),
              ),
              Shadow(
                color: tone.withAlpha(150),
                blurRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingJoystick extends StatelessWidget {
  const _FloatingJoystick({
    required this.center,
    required this.size,
    required this.knobSize,
    required this.knobOffsetX,
  });

  final Offset center;
  final double size;
  final double knobSize;
  final double knobOffsetX;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: 0.22,
              child: Image.asset(
                'assets/images/Buttons/Joystick.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            ),
            Positioned(
              left: (size - knobSize) / 2 + knobOffsetX,
              top: (size - knobSize) / 2,
              child: Opacity(
                opacity: 0.38,
                child: Image.asset(
                  'assets/images/Buttons/Knob.png',
                  width: knobSize,
                  height: knobSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayLayer extends StatelessWidget {
  const _OverlayLayer({
    required this.hudState,
    required this.onResume,
    required this.onRestart,
    required this.onNextLevel,
    required this.onExit,
  });

  final AdventureHudState hudState;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback? onNextLevel;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final isLoading = hudState.phase == AdventurePhase.loading;
    final isPaused = hudState.phase == AdventurePhase.paused;

    final title = isLoading
        ? 'Loading'
        : isPaused
            ? 'Paused'
            : hudState.isFinalLevel
                ? 'Finished'
                : 'Stage Clear';

    return ColoredBox(
      color: const Color(0x99000000),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: PixelPanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PixelTextBlock(title: title, titleSize: 28),
                  const SizedBox(height: 18),
                  if (isLoading)
                    const _LoadingStripe()
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (isPaused)
                          PixelButton(label: 'Resume', onPressed: onResume),
                        if (!isPaused && onNextLevel != null)
                          PixelButton(label: 'Next', onPressed: onNextLevel!),
                        PixelButton(
                          label: 'Replay',
                          onPressed: onRestart,
                          tone: pixelAccentWarm,
                        ),
                        PixelButton(
                          label: 'Exit',
                          onPressed: onExit,
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
    );
  }
}

class _FruitCounterBadge extends StatelessWidget {
  const _FruitCounterBadge({
    required this.collected,
    required this.total,
  });

  final int collected;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$collected / $total',
      style: const TextStyle(
        color: pixelText,
        fontWeight: FontWeight.w900,
        fontSize: 22,
        height: 0.95,
        letterSpacing: 0.8,
        shadows: [
          Shadow(
            color: pixelShadow,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  const _KeyboardHint();

  @override
  Widget build(BuildContext context) {
    return const PixelPanel(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: pixelPanelDark,
      child: Text(
        'MOVE: A / D OR ARROWS    JUMP: SPACE    DASH: SHIFT',
        style: TextStyle(
          color: pixelSubtext,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _LoadingStripe extends StatelessWidget {
  const _LoadingStripe();

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: EdgeInsets.zero,
      color: pixelPanelDark,
      shadow: false,
      child: SizedBox(
        height: 18,
        child: Row(
          children: List.generate(
            8,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                color: index.isEven ? pixelAccent : pixelAccentWarm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
