import 'package:shared_preferences/shared_preferences.dart';

/// 本机偏好 —— 微交互「只出现一次」等轻量状态
class AppPrefs {
  AppPrefs._();

  static const _firstTodoHintShown = 'first_todo_hint_shown';

  static Future<bool> hasShownFirstTodoHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTodoHintShown) ?? false;
  }

  static Future<void> markFirstTodoHintShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTodoHintShown, true);
  }
}