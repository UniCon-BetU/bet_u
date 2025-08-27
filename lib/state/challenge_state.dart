// lib/state/challenge_state.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../views/pages/challenge_tab/challenge_detail_page.dart';

class ChallengeState extends ChangeNotifier {
  final List<Challenge> recentVisited = [];
  final List<String> recentSearches = [];

  void addRecentVisited(Challenge c, {int max = 10}) {
    recentVisited.remove(c);
    recentVisited.insert(0, c);
    if (recentVisited.length > max) recentVisited.removeLast();
    notifyListeners();
  }

  void addRecentSearch(String title, {int max = 5}) {
    if (title.isEmpty) return;
    recentSearches.remove(title);
    recentSearches.insert(0, title);
    if (recentSearches.length > max) recentSearches.removeLast();
    notifyListeners();
  }

  Future<String> openDetail(
    BuildContext context, {
    required Challenge challenge,
    required bool fromSearch,
  }) async {
    addRecentVisited(challenge);
    if (fromSearch) addRecentSearch(challenge.title);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPage(challenge: challenge),
      ),
    );
    return fromSearch ? '추천' : '인기';
  }
}
