import 'package:flutter/material.dart';

enum AvatarSize { sm, md, lg }

class AvatarInitials extends StatelessWidget {
  const AvatarInitials({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    this.size = AvatarSize.md,
  });

  final String firstName;
  final String lastName;
  final String nickname;
  final AvatarSize size;

  double get _diameter => switch (size) {
        AvatarSize.sm => 24.0,
        AvatarSize.md => 40.0,
        AvatarSize.lg => 56.0,
      };

  double get _fontSize => switch (size) {
        AvatarSize.sm => 10.0,
        AvatarSize.md => 16.0,
        AvatarSize.lg => 22.0,
      };

  String get _initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  Color _backgroundColorFromNickname() {
    int hash = 0;
    for (final codeUnit in nickname.codeUnits) {
      hash = codeUnit + ((hash << 5) - hash);
    }
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.50).toColor();
  }

  Color _foregroundColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.35 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundColorFromNickname();
    final fg = _foregroundColor(bg);

    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }
}
