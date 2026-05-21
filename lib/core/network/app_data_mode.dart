import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppDataMode {
  production,
}

extension AppDataModeX on AppDataMode {
  bool get isLocalSeed => false;
}

final appDataModeProvider = Provider<AppDataMode>((ref) {
  return AppDataMode.production;
});
