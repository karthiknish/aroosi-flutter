part of 'package:aroosi_flutter/features/profiles/models.dart';

/// Supervised communication for traditional courtship.
class SupervisedConversation extends Equatable {
  const SupervisedConversation({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.supervisorId,
    required this.status,
    required this.createdAt,
    this.conversationId,
    this.rules,
    this.timeLimit,
    this.topicRestrictions,
    this.lastActivity,
  });

  final String id;
  final String participant1Id;
  final String participant2Id;
  final String supervisorId;
  final String status; // 'active', 'paused', 'completed', 'terminated'
  final int createdAt;
  final String? conversationId;
  final List<String>? rules; // communication rules
  final int? timeLimit; // minutes per day
  final List<String>? topicRestrictions; // forbidden topics
  final int? lastActivity;

  SupervisedConversation copyWith({
    String? id,
    String? participant1Id,
    String? participant2Id,
    String? supervisorId,
    String? status,
    int? createdAt,
    String? conversationId,
    List<String>? rules,
    int? timeLimit,
    List<String>? topicRestrictions,
    int? lastActivity,
  }) => SupervisedConversation(
        id: id ?? this.id,
        participant1Id: participant1Id ?? this.participant1Id,
        participant2Id: participant2Id ?? this.participant2Id,
        supervisorId: supervisorId ?? this.supervisorId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        conversationId: conversationId ?? this.conversationId,
        rules: rules ?? this.rules,
        timeLimit: timeLimit ?? this.timeLimit,
        topicRestrictions: topicRestrictions ?? this.topicRestrictions,
        lastActivity: lastActivity ?? this.lastActivity,
      );

  static SupervisedConversation fromJson(Map<String, dynamic> json) =>
      SupervisedConversation(
        id: json['id']?.toString() ?? '',
        participant1Id: json['participant1Id']?.toString() ?? '',
        participant2Id: json['participant2Id']?.toString() ?? '',
        supervisorId: json['supervisorId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'active',
        createdAt: json['createdAt'] is int
            ? json['createdAt']
            : DateTime.now().millisecondsSinceEpoch,
        conversationId: json['conversationId']?.toString(),
        rules: (json['rules'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        timeLimit: json['timeLimit'] is int ? json['timeLimit'] : null,
        topicRestrictions: (json['topicRestrictions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        lastActivity:
            json['lastActivity'] is int ? json['lastActivity'] : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant1Id': participant1Id,
        'participant2Id': participant2Id,
        'supervisorId': supervisorId,
        'status': status,
        'createdAt': createdAt,
        if (conversationId != null) 'conversationId': conversationId,
        if (rules != null) 'rules': rules,
        if (timeLimit != null) 'timeLimit': timeLimit,
        if (topicRestrictions != null) 'topicRestrictions': topicRestrictions,
        if (lastActivity != null) 'lastActivity': lastActivity,
      };

  @override
  List<Object?> get props => [
        id,
        participant1Id,
        participant2Id,
        supervisorId,
        status,
        createdAt,
        conversationId,
        rules,
        timeLimit,
        topicRestrictions,
        lastActivity,
      ];
}
