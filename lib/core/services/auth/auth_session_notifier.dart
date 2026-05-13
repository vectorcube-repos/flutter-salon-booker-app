import 'dart:async';

enum AuthSessionEvent { unauthorized, accountDisabled }

class AuthSessionNotifier {
  final StreamController<AuthSessionEvent> _controller =
      StreamController<AuthSessionEvent>.broadcast();

  Stream<AuthSessionEvent> get stream => _controller.stream;

  void notifyUnauthorized() {
    if (_controller.isClosed) return;
    _controller.add(AuthSessionEvent.unauthorized);
  }

  void notifyAccountDisabled() {
    if (_controller.isClosed) return;
    _controller.add(AuthSessionEvent.accountDisabled);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
