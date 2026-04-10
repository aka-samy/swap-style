import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(24),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: theme.colorScheme.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'SwapStyle',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
