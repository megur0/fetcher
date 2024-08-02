import 'dart:async';

class Fetcher<T, E> {
  Fetcher(
    this._fetch,
    this._notify,
  ) {
    _execFetch();
  }

  T? _data;
  T? get data => _data;
  E? _error;
  E? get error => _error;

  final Future<({T data, E? error})> Function() _fetch;

  final void Function() _notify;

  Future<void> _execFetch() async {
    final res = await _fetch();
    _error = res.error;
    if (_error == null) {
      _data = res.data;
    }
    _notify();
  }

  void retry() {
    _resetData();
    _resetError();
    _execFetch();
  }

  void _resetData() {
    _data = null;
  }

  void _resetError() {
    _error = null;
  }
}
