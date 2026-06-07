import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

class FakeClock implements Clock {
  final DateTime _now;
  const FakeClock(this._now);
  @override
  DateTime now() => _now;
}

final clockProvider = Provider<Clock>((ref) => const SystemClock());
