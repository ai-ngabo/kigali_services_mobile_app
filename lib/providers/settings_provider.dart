import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    NotificationService.instance.setEnabled(_notificationsEnabled);
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notificationsEnabled = value;
    NotificationService.instance.setEnabled(value);
    notifyListeners();
  }
}