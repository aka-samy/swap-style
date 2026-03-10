import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final BadgeType type;
  final double iconSize;

  const VerifiedBadge({
    super.key,
    required this.type,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (type) {
      BadgeType.item => (Colors.green, 'Verified'),
      BadgeType.user => (Colors.blue, 'Verified User'),
    };

    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: color, size: iconSize,
                semanticLabel: label),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: iconSize * 0.75,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum BadgeType { item, user }
