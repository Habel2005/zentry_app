import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// A robust provider that correctly manages connectivity state for the UI.
class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOnline = true;
  bool _hasDismissedDialog = false;

  ConnectivityProvider() {
    _initialize();
  }

  bool get isOnline => _isOnline;
  // The UI should only show the dialog if we are offline AND the user hasn't already dismissed it.
  bool get shouldShowDialog => !_isOnline && !_hasDismissedDialog;

  Future<void> _initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final bool newStatus = results.any(
      (result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet,
    );

    if (newStatus != _isOnline) {
      _isOnline = newStatus;

      // If the user comes back online, we reset the dismiss flag.
      // This ensures the dialog will appear again on the *next* disconnect.
      if (_isOnline) {
        _hasDismissedDialog = false;
      }
      notifyListeners();
    }
  }

  // This is called by the UI when the dismiss button is pressed.
  void dismissDialog() {
    if (!_hasDismissedDialog) {
      _hasDismissedDialog = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
