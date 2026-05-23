import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app_links_settings_prompted';
const _channel = MethodChannel('com.carbodex.qitak/app_links');

abstract final class AppLinksPromptService {
  static Future<bool> shouldPrompt() async {
    if (!Platform.isAndroid) return false;
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefsKey) ?? false);
  }

  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openDefaultAppsSettings');
    } on MissingPluginException {
      // Channel unavailable on this device/build.
    }
  }
}
