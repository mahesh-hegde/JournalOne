import 'package:flutter_riverpod/flutter_riverpod.dart';

const loading = "Loading...";

// Providers
final dateProvider = StateProvider((ref) => DateTime.now());
final textProvider = StateProvider((ref) => loading);
final stagedTextProvider = StateProvider((ref) => "??");
final editingStateProvider = StateProvider((ref) => false);
