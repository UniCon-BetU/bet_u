// lib/utils/challenge_history.dart
import 'package:flutter/foundation.dart';
import '../models/challenge.dart';

class ChallengeHistory {
  ChallengeHistory._();
  static final instance = ChallengeHistory._();

  /// 최신이 맨 앞. 외부에서 구독 가능
  final ValueNotifier<List<Challenge>> recent = ValueNotifier<List<Challenge>>([]);

  void record(Challenge c) {
    final list = List<Challenge>.from(recent.value);

    bool equals(Challenge a, Challenge b) {
      try {
        final aId = (a as dynamic).id;
        final bId = (b as dynamic).id;
        if (aId != null && bId != null) return aId == bId;
      } catch (_) {}
      return a.title == b.title;
    }

    list.removeWhere((x) => equals(x, c));
    list.insert(0, c);
    if (list.length > 10) list.removeLast();

    recent.value = list;
  }
}
