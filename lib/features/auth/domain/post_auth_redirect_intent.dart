import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_auth_redirect_intent.freezed.dart';

enum IntentTargetType { route, action }

@freezed
abstract class PostAuthRedirectIntent with _$PostAuthRedirectIntent {
  const factory PostAuthRedirectIntent({
    required IntentTargetType targetType,
    required String targetValue,
    Map<String, String>? arguments,
    @Default(Duration.zero) Duration createdAt,
  }) = _PostAuthRedirectIntent;

  const PostAuthRedirectIntent._();

  factory PostAuthRedirectIntent.route(String path) {
    return PostAuthRedirectIntent(
      targetType: IntentTargetType.route,
      targetValue: path,
    );
  }

  factory PostAuthRedirectIntent.action(
    String action, {
    Map<String, String>? arguments,
  }) {
    return PostAuthRedirectIntent(
      targetType: IntentTargetType.action,
      targetValue: action,
      arguments: arguments,
    );
  }

  String? get fallbackRoute => arguments?['route'];

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'redirect': targetValue,
      'intentType': targetType.name,
    };
    final args = arguments;
    if (args != null && args.isNotEmpty) {
      params['intentArgs'] = base64Url.encode(
        utf8.encode(jsonEncode(args)),
      );
    }
    return params;
  }

  static PostAuthRedirectIntent? fromQueryParameters({
    required String? redirectPath,
    required IntentTargetType redirectType,
    String? encodedArguments,
  }) {
    if (redirectPath == null || redirectPath.isEmpty) {
      return null;
    }

    Map<String, String>? arguments;
    if (encodedArguments != null && encodedArguments.isNotEmpty) {
      final decoded = utf8.decode(base64Url.decode(encodedArguments));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      arguments = json.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }

    return PostAuthRedirectIntent(
      targetType: redirectType,
      targetValue: redirectPath,
      arguments: arguments,
    );
  }
}
