import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// ✅ Get token from shared OR generate new
  Future<String?> getToken() async {
    final savedToken = await SharedPrefsHelper.getFcmToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      return savedToken;
    }

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    if (token != null) {
      await SharedPrefsHelper.saveFcmToken(token);
    }

    return token;
  }

  /// ✅ Refresh listener (ONLY ONCE)
  void listenTokenRefresh(Function(String token) onRefresh) {
    _messaging.onTokenRefresh.listen((token) async {
      await SharedPrefsHelper.saveFcmToken(token);
      onRefresh(token);
    });
  }

  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
    });
  }

  void listenNotificationClicks(Function(Map<String, dynamic>) onTap) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onTap(message.data);
    });
  }
}
