// lib/utils/number_extensions.dart
import 'package:intl/intl.dart';

final _nf = NumberFormat.decimalPattern(); // Intl.defaultLocale 기반

extension CommaNum on num {
  String get comma => _nf.format(this);
}

extension CommaNumNullable on num? {
  String get comma => this == null ? '-' : _nf.format(this);
}
