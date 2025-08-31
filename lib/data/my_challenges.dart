import 'package:flutter/foundation.dart';
import 'package:bet_u/models/challenge.dart';

final List<Challenge> myChallenges = [];
final ValueNotifier<List<Challenge>> myChallengesNotifier =
    ValueNotifier<List<Challenge>>([]);
