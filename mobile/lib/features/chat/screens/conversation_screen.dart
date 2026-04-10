import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/message.dart';
import '../providers/chat_provider.dart';

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
    final messages = state.messages;
    final isLoading = state.isLoading;
    final typingUsers = state.typingUsers;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(60),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chat',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isConnected
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.isConnected ? 'Connected' : 'Connecting...',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.go('/matches/${widget.matchId}'),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            // Messages list
            Expanded(
              child: isLoading && messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withAlpha(80)),
                                const SizedBox(height: 12),
                                Text('No messages yet',
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text('Say hello to get started!',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    )),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
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

            // Typing indicator
            if (typingUsers.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _TypingDots(),
                    const SizedBox(width: 6),
                    Text('Typing...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        )),
                  ],
                ),
              ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(60),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onChanged: _onTextChanged,
                        onSubmitted: (_) => _send(),
                        maxLines: null,
                        maxLength: 2000,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isTyping
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _send,
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: _isTyping
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
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
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
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
        top: showAvatar ? 6 : 1,
        bottom: 1,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primary.withAlpha(25),
              child: Text(
                _safeInitial(message.sender?.displayName),
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 28),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe ? theme.colorScheme.onPrimary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isMe
                              ? theme.colorScheme.onPrimary.withAlpha(160)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          message.readAt != null
                              ? Icons.done_all
                              : Icons.done,
                          size: 13,
                          color:
                              theme.colorScheme.onPrimary.withAlpha(160),
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
