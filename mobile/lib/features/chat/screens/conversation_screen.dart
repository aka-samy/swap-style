import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';
import '../../../core/models/message.dart';
import '../../matching/data/matching_repository.dart';
import '../providers/chat_provider.dart';

final _chatMatchProvider =
    FutureProvider.family<Match, String>((ref, matchId) async {
  final client = ref.watch(apiClientProvider);
  return MatchingRepository(client).getMatch(matchId);
});

class ConversationScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String currentUserId;

  const ConversationScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  String _statusLabel(MatchStatus status) {
    return switch (status) {
      MatchStatus.pending => 'Pending',
      MatchStatus.negotiating => 'Negotiating',
      MatchStatus.agreed => 'Agreed',
      MatchStatus.awaitingConfirmation => 'Awaiting confirmation',
      MatchStatus.completed => 'Completed',
      MatchStatus.canceled => 'Canceled',
      MatchStatus.expired => 'Expired',
    };
  }

  void _showMatchStatusSheet(Match? match) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Status',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          match == null
                              ? 'Loading status...'
                              : _statusLabel(match.status),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push('/matches/${widget.matchId}');
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('View Match Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(chatProvider(widget.matchId).notifier);
      notifier.joinRoom();
      notifier.loadMessages();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    final typing = value.isNotEmpty;
    if (typing != _isTyping) {
      setState(() => _isTyping = typing);
      ref.read(chatProvider(widget.matchId).notifier).setTyping(typing);
    }
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    setState(() => _isTyping = false);
    ref.read(chatProvider(widget.matchId).notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(chatProvider(widget.matchId));
    final matchAsync = ref.watch(_chatMatchProvider(widget.matchId));
    final loadedMatch = matchAsync.maybeWhen(data: (m) => m, orElse: () => null);
    final messages = state.messages;
    final isLoading = state.isLoading;
    final typingUsers = state.typingUsers;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/chats');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conversation',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isConnected
                                    ? Colors.greenAccent.shade400
                                    : (state.error == null ? Colors.amber : Colors.redAccent),
                                boxShadow: [
                                  if (state.isConnected)
                                    BoxShadow(
                                      color: Colors.greenAccent.withAlpha(100),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.isConnected
                                  ? 'Connected securely'
                                  : (state.error == null
                                      ? 'Connecting...'
                                      : 'Realtime unavailable'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Match Details',
                    onPressed: () => _showMatchStatusSheet(loadedMatch),
                    icon: const Icon(Icons.more_horiz_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            // Messages List
            Expanded(
              child: isLoading && messages.isEmpty
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                  : messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.chat_rounded,
                                      size: 48,
                                      color: theme.colorScheme.primary.withAlpha(150)),
                                ),
                                const SizedBox(height: 24),
                                Text('Start the conversation',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                Text('Send a message to discuss your swap details safely.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    )),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (ctx, i) {
                            final msg = messages[i];
                            final isMe =
                                msg.senderId == widget.currentUserId;
                            final showAvatar = i == messages.length - 1 ||
                                messages[i + 1].senderId != msg.senderId;
                            return _MessageBubble(
                              message: msg,
                              isMe: isMe,
                              showAvatar: showAvatar,
                            );
                          },
                        ),
            ),

            // Typing Indicator
            if (typingUsers.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _TypingDots(),
                    const SizedBox(width: 8),
                    Text('Typing...',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),

            // Floating Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: theme.scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(10),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          onChanged: _onTextChanged,
                          onSubmitted: (_) => _send(),
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withAlpha(150)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _isTyping
                                ? LinearGradient(
                                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: !_isTyping ? theme.colorScheme.surface : null,
                            shape: BoxShape.circle,
                            boxShadow: _isTyping
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withAlpha(80),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: IconButton(
                            tooltip: 'Send',
                            onPressed: _send,
                            icon: Icon(
                              Icons.send_rounded,
                              color: _isTyping
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final t = (_controller.value - delay).clamp(0.0, 1.0);
          final opacity = (t < 0.5 ? t * 2 : 2 - t * 2).clamp(0.3, 1.0);
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((opacity * 255).toInt()),
            ),
          );
        }),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  });

  String _safeInitial(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return '?';
    return cleaned.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 12 : 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withAlpha(200),
                    theme.colorScheme.secondary.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _safeInitial(message.sender?.displayName),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 36),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                gradient: isMe
                    ? LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? theme.colorScheme.primary : theme.shadowColor).withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isMe ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isMe
                              ? Colors.white.withAlpha(180)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.readAt != null
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: Colors.white.withAlpha(180),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
