import 'package:flutter/material.dart';

const pixelInk = Color(0xFF102013);
const pixelPanel = Color(0xFF253626);
const pixelPanelDark = Color(0xFF182519);
const pixelAccent = Color(0xFFB4E06E);
const pixelAccentWarm = Color(0xFFF5BE68);
const pixelBorder = Color(0xFF6C8A4C);
const pixelShadow = Color(0xFF071007);
const pixelText = Color(0xFFF2F6E2);
const pixelSubtext = Color(0xFFC4D0B2);

Color _shiftLightness(Color color, double delta) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + delta).clamp(0.0, 1.0).toDouble())
      .toColor();
}

class PixelBackdrop extends StatelessWidget {
  const PixelBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF111A11),
        image: DecorationImage(
          image: AssetImage('assets/images/Background/Gray.png'),
          repeat: ImageRepeat.repeat,
          fit: BoxFit.none,
          filterQuality: FilterQuality.none,
          opacity: 0.22,
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xCC0B120C),
              Color(0xAA101A11),
              Color(0xEE081008),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = pixelPanel,
    this.borderColor = pixelBorder,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: pixelShadow.withAlpha(70),
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _PixelButtonShell extends StatelessWidget {
  const _PixelButtonShell({
    required this.child,
    required this.tone,
    required this.padding,
    this.width,
    this.height,
    this.pressed = false,
  });

  final Widget child;
  final Color tone;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final borderTone = _shiftLightness(tone, -0.22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, pressed ? 1 : 0, 0),
      decoration: BoxDecoration(
        color: tone,
        border: Border.all(color: borderTone, width: 2),
        boxShadow: pressed
            ? null
            : [
                BoxShadow(
                  color: pixelShadow.withAlpha(80),
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _PixelInteractiveShell extends StatefulWidget {
  const _PixelInteractiveShell({
    required this.onPressed,
    required this.builder,
    this.splashColor,
  });

  final VoidCallback onPressed;
  final Widget Function(bool pressed) builder;
  final Color? splashColor;

  @override
  State<_PixelInteractiveShell> createState() => _PixelInteractiveShellState();
}

class _PixelInteractiveShellState extends State<_PixelInteractiveShell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (pressed) {
          if (_pressed != pressed) {
            setState(() {
              _pressed = pressed;
            });
          }
        },
        splashColor: widget.splashColor,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: widget.builder(_pressed),
      ),
    );
  }
}

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.tone = pixelAccent,
    this.foreground = pixelInk,
    this.horizontalPadding,
    this.verticalPadding,
    this.opacity = 1,
  });

  final String label;
  final VoidCallback onPressed;
  final bool compact;
  final Color tone;
  final Color foreground;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: foreground,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.9,
      fontSize: compact ? 12 : 14,
      height: 0.95,
    );
    final fillColor = tone.withAlpha((opacity.clamp(0, 1) * 255).round());

    return _PixelInteractiveShell(
      onPressed: onPressed,
      splashColor: pixelText.withAlpha(18),
      builder: (pressed) => _PixelButtonShell(
        tone: fillColor,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? (compact ? 14 : 18),
          vertical: verticalPadding ?? (compact ? 10 : 11),
        ),
        pressed: pressed,
        child: Center(
          child: Text(label.toUpperCase(), style: style),
        ),
      ),
    );
  }
}

class PixelIconButton extends StatelessWidget {
  const PixelIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.tone = pixelPanelDark,
    this.iconColor = pixelText,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color tone;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return _PixelInteractiveShell(
      onPressed: onPressed,
      splashColor: iconColor.withAlpha(18),
      builder: (pressed) => _PixelButtonShell(
        tone: tone,
        padding: EdgeInsets.zero,
        width: size,
        height: size,
        pressed: pressed,
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.44,
          ),
        ),
      ),
    );
  }
}

class PixelTextBlock extends StatelessWidget {
  const PixelTextBlock({
    super.key,
    required this.title,
    this.subtitle,
    this.align = CrossAxisAlignment.start,
    this.titleSize = 28,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment align;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: pixelText,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            height: 0.95,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              color: pixelSubtext,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class PixelTag extends StatelessWidget {
  const PixelTag({
    super.key,
    required this.label,
    this.color = pixelPanelDark,
    this.textColor = pixelSubtext,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: pixelBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.assetPath,
    required this.frameWidth,
    required this.frameHeight,
    required this.sheetWidth,
    this.frameIndex = 0,
    this.scale = 4,
  });

  final String assetPath;
  final double frameWidth;
  final double frameHeight;
  final double sheetWidth;
  final int frameIndex;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final maxFrameIndex =
        ((sheetWidth / frameWidth).floor() - 1).clamp(0, 1000000);
    final resolvedFrameIndex = frameIndex.clamp(0, maxFrameIndex);
    final alignmentX = maxFrameIndex == 0
        ? -1.0
        : -1.0 +
            (2 * resolvedFrameIndex * frameWidth) / (sheetWidth - frameWidth);

    return SizedBox(
      width: frameWidth * scale,
      height: frameHeight * scale,
      child: ClipRect(
        child: Align(
          alignment: Alignment(alignmentX, 0),
          widthFactor: frameWidth / sheetWidth,
          child: Image.asset(
            assetPath,
            fit: BoxFit.none,
            scale: 1 / scale,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
