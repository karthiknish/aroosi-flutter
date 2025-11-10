import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aroosi_flutter/features/safety/safety_controller.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/widgets/empty_states.dart';
import 'package:aroosi_flutter/widgets/offline_states.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Load blocked users on first open
    Future.microtask(
      () => ref.read(safetyControllerProvider.notifier).refreshBlocked(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(safetyControllerProvider.notifier).refreshBlocked(),
        child: state.loading && state.blockedUsers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.blockedUsers.isEmpty
                ? Builder(
                    builder: (context) {
                      final error = state.error!;
                      final isOfflineError =
                          error.toLowerCase().contains('network') ||
                          error.toLowerCase().contains('connection') ||
                          error.toLowerCase().contains('timeout') ||
                          error.toLowerCase().contains('offline');

                      return isOfflineError
                          ? OfflineState(
                              title: 'Connection Lost',
                              subtitle: 'Unable to load blocked users',
                              description: 'Check your internet connection and try again',
                              onRetry: () => ref
                                  .read(safetyControllerProvider.notifier)
                                  .refreshBlocked(),
                            )
                          : ErrorState(
                              title: 'Failed to Load Blocked Users',
                              subtitle: 'Something went wrong',
                              errorMessage: error,
                              onRetryPressed: () => ref
                                  .read(safetyControllerProvider.notifier)
                                  .refreshBlocked(),
                            );
                    },
                  )
                : state.blockedUsers.isEmpty
                    ? EmptyState(
                        title: 'No blocked users',
                        subtitle: 'You haven\'t blocked any users yet',
                        description: 'Blocked users will appear here',
                        icon: Icon(Icons.block, size: 64, color: Colors.grey[400]),
                      )
                    : Column(
                        children: [
                          if (state.error != null)
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.error!,
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(safetyControllerProvider.notifier)
                                        .refreshBlocked(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.blockedUsers.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final u = state.blockedUsers[index];
                              final name =
                                  u['fullName']?.toString() ??
                                  u['name']?.toString() ??
                                  'User';
                              final id =
                                  u['id']?.toString() ??
                                  u['_id']?.toString() ??
                                  '';
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person_outline),
                                ),
                                title: Text(name),
                                trailing: TextButton(
                                  onPressed: id.isEmpty
                                      ? null
                                      : () async {
                                          final ok = await ref
                                              .read(
                                                safetyControllerProvider
                                                    .notifier,
                                              )
                                              .unblock(id);
                                          if (!context.mounted) return;
                                          final messenger =
                                              ScaffoldMessenger.maybeOf(
                                            context,
                                          );
                                          messenger?.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                ok
                                                    ? 'Unblocked $name'
                                                    : 'Failed to unblock',
                                              ),
                                            ),
                                          );
                                        },
                                  child: const Text('Unblock'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(safetyControllerProvider.notifier).refreshBlocked(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
