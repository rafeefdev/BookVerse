import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { grid, list }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);
