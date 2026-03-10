import 'package:flutter/material.dart';

/// A star-rating prompt shown after a swap is marked completed.
/// Calls [onSubmit] with the chosen score (1–5) and optional comment.
class RatingPrompt extends StatefulWidget {
  const RatingPrompt({
    super.key,
    required this.rateeDisplayName,
    required this.onSubmit,
    this.onSkip,
  });

  final String rateeDisplayName;
  final void Function(int score, String? comment) onSubmit;
  final VoidCallback? onSkip;

  @override
  State<RatingPrompt> createState() => _RatingPromptState();
}

class _RatingPromptState extends State<RatingPrompt> {
  int _hoveredStar = 0;
  int _selectedScore = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rate your swap with ${widget.rateeDisplayName}',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Star selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled = starIndex <= (_hoveredStar > 0
                  ? _hoveredStar
                  : _selectedScore);
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedScore = starIndex;
                  _hoveredStar = 0;
                }),
                onPanUpdate: (details) {
                  // Allow dragging across stars
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStar = starIndex),
                  onExit: (_) => setState(() => _hoveredStar = 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: filled ? Colors.amber : cs.outlineVariant,
                      semanticLabel: 'Star $starIndex',
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedScore == 0
                ? 'Tap to rate'
                : _starLabel(_selectedScore),
            style: theme.textTheme.labelLarge?.copyWith(
              color: _selectedScore > 0 ? Colors.amber.shade700 : cs.outline,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Leave a comment (optional)',
              border: OutlineInputBorder(),
              hintText: 'How was the experience?',
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.onSkip != null)
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _selectedScore == 0
                    ? null
                    : () {
                        final comment = _commentController.text.trim();
                        widget.onSubmit(
                          _selectedScore,
                          comment.isEmpty ? null : comment,
                        );
                      },
                child: const Text('Submit Rating'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _starLabel(int score) {
    return switch (score) {
      1 => 'Poor',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Great',
      5 => 'Excellent!',
      _ => '',
    };
  }
}
