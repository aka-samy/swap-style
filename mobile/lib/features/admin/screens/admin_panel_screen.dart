import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error_mapper.dart';
import '../../../core/providers/auth_provider.dart';
import '../data/admin_repository.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _users = const [];
  List<Map<String, dynamic>> _reports = const [];
  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _matches = const [];
  Map<String, dynamic>? _notificationsHealth;
  Map<String, dynamic>? _chatHealth;

  AdminRepository get _repo => AdminRepository(ref.read(apiClientProvider));

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _repo.getDashboard(),
        _repo.getUsers(search: _searchController.text),
        _repo.getReports(status: 'pending'),
        _repo.getItems(),
        _repo.getMatches(),
        _repo.getNotificationsHealth(),
        _repo.getChatHealth(),
      ]);

      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _users = results[1] as List<Map<String, dynamic>>;
        _reports = results[2] as List<Map<String, dynamic>>;
        _items = results[3] as List<Map<String, dynamic>>;
        _matches = results[4] as List<Map<String, dynamic>>;
        _notificationsHealth = results[5] as Map<String, dynamic>;
        _chatHealth = results[6] as Map<String, dynamic>;
      });
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      setState(() {
        _error = ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load admin data. Please try again.',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setUserRole(String userId, String role) async {
    try {
      await _repo.updateUserRole(userId, role);
      await _loadAll();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleSuspend(String userId, bool isCurrentlySuspended) async {
    try {
      if (isCurrentlySuspended) {
        await _repo.unsuspendUser(userId);
      } else {
        await _repo.suspendUser(userId, days: 7);
      }
      await _loadAll();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _resolveReport(String reportId, String status) async {
    try {
      await _repo.resolveReport(reportId, status);
      await _loadAll();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _moderateItem(String itemId, String status) async {
    try {
      await _repo.updateItemStatus(itemId, status);
      await _loadAll();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final message = ApiErrorMapper.toUserMessage(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  bool _isSuspended(Map<String, dynamic> user) {
    final value = user['suspendedUntil'];
    if (value == null) return false;
    final date = DateTime.tryParse(value.toString());
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You do not have access to this page.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_isLoading && _dashboard == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _loadAll,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadAll,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Dashboard'),
              const Tab(text: 'Users'),
              Tab(
                child: Row(
                  children: [
                    const Text('Reports'),
                    if (_reports.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.error_rounded, size: 16, color: theme.colorScheme.error),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Items'),
              const Tab(text: 'Matches'),
              const Tab(text: 'Monitor'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(theme),
            _buildUsersTab(theme),
            _buildReportsTab(theme),
            _buildItemsTab(theme),
            _buildMatchesTab(theme),
            _buildMonitorTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(ThemeData theme) {
    final users = _dashboard?['users'] as Map<String, dynamic>? ?? const {};
    final moderation =
        _dashboard?['moderation'] as Map<String, dynamic>? ?? const {};
    final swaps = _dashboard?['swaps'] as Map<String, dynamic>? ?? const {};

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            title: 'Users',
            value: '${users['total'] ?? 0}',
            subtitle: 'Suspended: ${users['suspended'] ?? 0}',
            icon: Icons.people_alt_outlined,
          ),
          _StatCard(
            title: 'Pending Reports',
            value: '${moderation['pendingReports'] ?? 0}',
            subtitle: 'Needs moderation review',
            icon: Icons.flag_outlined,
          ),
          _StatCard(
            title: 'Active Matches',
            value: '${swaps['activeMatches'] ?? 0}',
            subtitle: 'Available items: ${swaps['availableItems'] ?? 0}',
            icon: Icons.swap_horiz_rounded,
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _loadAll,
              ),
            ),
            onSubmitted: (_) => _loadAll(),
          ),
          const SizedBox(height: 12),
          if (_users.isEmpty)
            _EmptyTabState(
              icon: Icons.people_outline_rounded,
              title: 'No users found',
              subtitle: 'Try another search or refresh.',
            ),
          ..._users.map((user) {
            final suspended = _isSuspended(user);
            final role = (user['role'] as String?) ?? 'USER';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['displayName']?.toString() ?? 'Unknown user',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(user['email']?.toString() ?? ''),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Role: $role')),
                        Chip(label: Text(suspended ? 'Suspended' : 'Active')),
                        FilledButton.tonal(
                          onPressed: () => _toggleSuspend(
                            user['id'].toString(),
                            suspended,
                          ),
                          child:
                              Text(suspended ? 'Unsuspend' : 'Suspend 7 days'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _setUserRole(
                            user['id'].toString(),
                            role == 'ADMIN' ? 'USER' : 'ADMIN',
                          ),
                          child: Text(
                            role == 'ADMIN' ? 'Set User Role' : 'Set Admin Role',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReportsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_reports.isEmpty)
            const _EmptyTabState(
              icon: Icons.flag_outlined,
              title: 'No pending reports',
              subtitle: 'Everything is currently reviewed.',
            ),
          ..._reports.map((report) {
            final reporter =
                report['reporter'] as Map<String, dynamic>? ?? const {};
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['reason']?.toString() ?? 'Report',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['details']?.toString().isNotEmpty == true
                          ? report['details'].toString()
                          : 'No additional details provided',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reporter: ${reporter['displayName'] ?? '-'}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => _resolveReport(
                            report['id'].toString(),
                            'reviewed',
                          ),
                          child: const Text('Mark Reviewed'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _resolveReport(
                            report['id'].toString(),
                            'resolved',
                          ),
                          child: const Text('Resolve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_items.isEmpty)
            const _EmptyTabState(
              icon: Icons.checkroom_outlined,
              title: 'No items to moderate',
              subtitle: 'Refresh later for new posts.',
            ),
          ..._items.map((item) {
            final owner = item['owner'] as Map<String, dynamic>? ?? const {};
            final status = item['status']?.toString() ?? 'available';
            final category = item['category']?.toString() ?? '-';
            final brand = item['brand']?.toString() ?? '-';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$brand • $category',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Owner: ${owner['displayName'] ?? '-'}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text('Status: $status')),
                        FilledButton.tonal(
                          onPressed: () => _moderateItem(
                            item['id'].toString(),
                            status == 'removed' ? 'available' : 'removed',
                          ),
                          child: Text(
                            status == 'removed' ? 'Restore' : 'Remove',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMatchesTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_matches.isEmpty)
            const _EmptyTabState(
              icon: Icons.swap_horiz_rounded,
              title: 'No matches yet',
              subtitle: 'Match activity will appear here.',
            ),
          ..._matches.map((match) {
            final userA = match['userA'] as Map<String, dynamic>? ?? const {};
            final userB = match['userB'] as Map<String, dynamic>? ?? const {};
            final status = match['status']?.toString() ?? 'pending';
            return Card(
              child: ListTile(
                title: Text(
                  '${userA['displayName'] ?? '-'} ↔ ${userB['displayName'] ?? '-'}',
                ),
                subtitle: Text('Status: $status'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonitorTab(ThemeData theme) {
    final notif = _notificationsHealth ?? const {};
    final chat = _chatHealth ?? const {};

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            title: 'Notifications',
            value: '${notif['unread'] ?? 0}',
            subtitle: 'Unread • Sent 24h: ${notif['sentLast24h'] ?? 0}',
            icon: Icons.notifications_active_outlined,
          ),
          _StatCard(
            title: 'Chat',
            value: '${chat['unreadMessages'] ?? 0}',
            subtitle:
                'Unread messages • Sent 24h: ${chat['messagesLast24h'] ?? 0}',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          _StatCard(
            title: 'Active Chat Matches (24h)',
            value: '${chat['activeMatchChatsLast24h'] ?? 0}',
            subtitle: 'Matches with at least one message in last 24h',
            icon: Icons.forum_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withAlpha(18),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
