import '/auth/base_auth_user_provider.dart';

class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();

  Future<void> initialize() async {}

  Future<void> syncForUser(BaseAuthUser user) async {}
}
