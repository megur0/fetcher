import 'dart:async';

class StreamFetcher<T, E> {
  StreamFetcher(this._getSubscription, this._notify,
      {E? Function(E? error, StackTrace? stackTrace)? errorHandler})
      : _errorHandler = errorHandler {
    setSubScription();
  }

  T? _data;
  T? get data => _data;

  E? _error;
  E? get error => _error;
  final E? Function(E? error, StackTrace? stackTrace)? _errorHandler;

  final void Function() _notify;

  StreamSubscription<T?>? _subscription;

  final StreamSubscription<T?> Function(Function(T? l) onData,
      Function(E? error, StackTrace? stackTrace) onError) _getSubscription;

  void setSubScription() {
    _subscription = _getSubscription(
      (event) {
        _data = event;
        _resetError();
        _notify();
      },
      (err, st) {
        if (_errorHandler != null) {
          _error = _errorHandler(err, st);
        } else {
          _error = err;
        }
        _notify();
      },
    );
  }

  void retry() {
    _resetError();
    _resetData();
    _resetSubscription();
  }

  void _resetSubscription() {
    _cancelSubscription();
    setSubScription();
  }

  void _resetError() {
    _error = null;
  }

  void _resetData() {
    _data = null;
  }

  void _cancelSubscription() {
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  void dispose() {
    _cancelSubscription();
  }
}
