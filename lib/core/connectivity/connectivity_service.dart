import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  if (_usesTestWidgetsBinding) {
    yield true;
    return;
  }

  final connectivity = Connectivity();
  yield await _resolveOnlineState(
    await connectivity.checkConnectivity(),
  );

  await for (final results in connectivity.onConnectivityChanged) {
    yield await _resolveOnlineState(results);
  }
});

Future<bool> _resolveOnlineState(
  List<ConnectivityResult> results, {
  Future<List<InternetAddress>> Function(String)? lookup,
}) async {
  if (results.length == 1 && results.first == ConnectivityResult.none) {
    return false;
  }

  try {
    final response = await (lookup ?? InternetAddress.lookup)(
      'supabase.co',
    ).timeout(const Duration(seconds: 3));
    return response.isNotEmpty;
  } on Object {
    return false;
  }
}

@visibleForTesting
Future<bool> resolveOnlineStateForTesting(
  List<ConnectivityResult> results, {
  Future<List<InternetAddress>> Function(String)? lookup,
}) => _resolveOnlineState(results, lookup: lookup);

bool get _usesTestWidgetsBinding =>
    WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
