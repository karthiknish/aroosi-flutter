import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aroosi_flutter/features/matches/models.dart';
import 'package:aroosi_flutter/features/matches/matches_repository.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/features/chat/chat_repository.dart';
import 'package:aroosi_flutter/features/chat/chat_models.dart';
import 'package:aroosi_flutter/features/chat/unread_counts_controller.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/core/performance_service.dart';

// Repository providers
final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return FirestoreMatchesRepository();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// State notifier for matches
class MatchesNotifier extends Notifier<MatchesState> {
  final PerformanceService _performance = PerformanceService();
  StreamSubscription<List<Match>>? _matchesSubscription;
  ProviderSubscription<UnreadCountsState>? _unreadCountsSubscription;
  
  MatchesRepository get _matchesRepository => ref.read(matchesRepositoryProvider);
  ChatRepository? get _chatRepository => ref.read(chatRepositoryProvider);
  
  String? _currentUserID;
  final Map<String, ProfileSummary> _profileCache = {};
  final Map<String, int> _unreadCounts = {};
  List<Match> _latestMatches = [];

  @override
  MatchesState build() {
    ref.onDispose(_dispose);
    return const MatchesState();
  }

  void _dispose() {
    _performance.startTimer('matches_dispose');
    
    // ProviderSubscription is managed automatically by Riverpod 3.x
    _matchesSubscription = null;
    _unreadCountsSubscription = null;
    
    // Clear caches
    _profileCache.clear();
    _unreadCounts.clear();
    _latestMatches.clear();
    
    _performance.endTimer('matches_dispose');
  }

  Future<void> observeMatches(String userID) async {
    _performance.startTimer('observe_matches');
    _currentUserID = userID;
    _profileCache.clear();
    _unreadCounts.clear();
    _latestMatches.clear();

    state = const MatchesState(isLoading: true);

    try {
      // ProviderSubscription is managed automatically by Riverpod 3.x
      
      // Implement unread count tracking using unread counts controller
      final unreadCountsController = ref.read(unreadCountsProvider.notifier);
      await unreadCountsController.refresh();
      
      // Listen for unread count updates with proper subscription management
      _unreadCountsSubscription = ref.listen(unreadCountsProvider, (previous, next) {
        if (next.counts.isNotEmpty) {
          final conversationCounts = next.counts['conversations'] as Map<String, dynamic>? ?? {};
          
          // Update unread counts for matches that have conversations
          for (final match in state.items) {
            final conversationId = _getConversationIdForMatch(match.id);
            final unreadCount = conversationCounts[conversationId] as int? ?? 0;
            updateUnreadCount(match.id, unreadCount);
          }
        }
      });

      // Create new subscription with proper error handling
      _matchesSubscription = _matchesRepository
          .streamMatches(userID)
          .listen(
            (matches) async {
              _latestMatches = matches;
              await _ensureProfiles(matches, userID);
              
              state = MatchesState(
                items: _buildItems(_latestMatches, _currentUserID!),
                isLoading: false,
                error: null,
              );
              
              _performance.recordMetric('matches_loaded', matches.length);
            },
            onError: (error) {
              state = MatchesState(
                error: 'We couldn\'t load matches right now. Please try again later.',
                isLoading: false,
              );
              _performance.recordMetric('matches_error', 1);
            },
          );
    } catch (e) {
      state = MatchesState(
        error: 'We couldn\'t load matches right now. Please try again later.',
        isLoading: false,
      );
      _performance.recordMetric('matches_exception', 1);
    } finally {
      _performance.endTimer('observe_matches');
    }
  }

  void stopObserving() {
    _performance.startTimer('stop_observing');
    
    // ProviderSubscription is managed automatically by Riverpod 3.x
    _matchesSubscription = null;
    _unreadCountsSubscription = null;
    
    _performance.endTimer('stop_observing');
  }

  Future<void> refresh() async {
    if (_currentUserID != null) {
      await observeMatches(_currentUserID!);
    }
  }

  void updateUnreadCount(String matchID, int count) {
    _unreadCounts[matchID] = count;
    if (_currentUserID != null) {
      state = state.copyWith(
        items: state.items.map((match) {
          return match.id == matchID 
              ? match.copyWith(unreadCount: count)
              : match;
        }).toList(),
      );
    }
  }

  /// Helper method to get conversation ID for a match
  String _getConversationIdForMatch(String matchId) {
    // Generate conversation ID based on current user and match user
    if (_currentUserID == null) return matchId;
    
    // Create a consistent conversation ID by sorting user IDs
    final userIds = [_currentUserID!, matchId]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  Future<void> _ensureProfiles(List<Match> matches, String currentUserID) async {
    final participantIDs = matches.expand((match) => match.participantIDs).toList();
    final counterpartIDs = participantIDs.where((id) => id != currentUserID).toSet();
    final missingIDs = counterpartIDs.where((id) => _profileCache[id] == null);

    for (final id in missingIDs) {
      try {
        final profile = await _matchesRepository.fetchProfile(id);
        if (profile != null) {
          _profileCache[id] = profile;
        }
      } catch (e) {
        // Log error but continue
      }
    }
  }

  List<MatchListItem> _buildItems(List<Match> matches, String currentUserID) {
    final items = <MatchListItem>[];

    for (final match in matches) {
      final counterpartID = match.participantIDs.firstWhere(
        (id) => id != currentUserID,
        orElse: () => '',
      );
      final profile = _profileCache[counterpartID];
      final unread = _unreadCounts[match.id] ?? 0;
      
      items.add(MatchListItem(
        id: match.id,
        match: match,
        counterpartProfile: profile,
        unreadCount: unread,
      ));
    }

    return items..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
  }

  void clearError() {
    state = MatchesState(
      items: state.items,
      isLoading: state.isLoading,
      error: null,
    );
  }
}

// Provider for matches notifier
final matchesProvider = NotifierProvider<MatchesNotifier, MatchesState>(MatchesNotifier.new);
