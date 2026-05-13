import 'dart:async';

/// Broadcasts favorite changes across the app.
///
/// When a product is added to or removed from favorites (via the repository),
/// this notifier emits the change so consumers (e.g. [ProductsBloc]) can stay
/// in sync without passing route results or refetching.
///
/// Registered as a singleton. Use [favoriteChanges] to listen.
class FavoritesNotifier {
  FavoritesNotifier() : _controller = StreamController<({int productId, bool isFavorite})>.broadcast();

  final StreamController<({int productId, bool isFavorite})> _controller;

  /// Stream of favorite changes. Emits (productId, isFavorite) after each
  /// successful add/remove. Cancel the subscription when done.
  Stream<({int productId, bool isFavorite})> get favoriteChanges => _controller.stream;

  /// Notifies listeners that a product's favorite state changed.
  /// Called by the repository after successful API calls.
  void notifyFavoriteChanged(int productId, bool isFavorite) {
    if (!_controller.isClosed) {
      _controller.add((productId: productId, isFavorite: isFavorite));
    }
  }

  /// Disposes the controller. Call only when the app is shutting down.
  /// Typically not needed for app lifetime singletons.
  void dispose() {
    _controller.close();
  }
}
