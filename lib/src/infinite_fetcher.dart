import 'dart:async';

abstract interface class Sortable {
  DateTime get sortKey;
}

class InfiniteFetcher<T extends Sortable, E> {
  InfiniteFetcher(
    this._limit,
    this._fetchOld,
    this._fetchNew,
    this._notify,
  ) {
    _initialFetch();
  }

  final int _limit;
  var _offset = 0;

  List<T>? _dataList;
  List<T>? get dataList => _dataList;
  E? _error;
  E? get error => _error;

  bool hasMore = true;

  bool get _hasData => _dataList != null && _dataList!.isNotEmpty;

  final Future<({List<T> data, E? error})> Function(int limit, int offset)
      _fetchOld;
  final Future<({List<T> data, E? error})> Function(DateTime after)
      _fetchNew;

  final void Function() _notify;

  Future<void> fetchOld([bool increaseOffset = true]) async {
    if (increaseOffset) {
      _offset += _limit;
    }
    final res = await _fetchOld(_limit + 1, _offset); // +1 is to check hasMore.
    _error = res.error;
    if (error != null) {
      _notify();
      return;
    }

    if (res.data.length > _limit) {
      res.data.removeLast();
      assert(res.data.length == _limit);
    } else {
      hasMore = false;
    }
    _dataList = _dataList == null ? res.data : [..._dataList!, ...res.data];

    _notify();
  }

  void retryFetchOld() {
    _resetError();
    fetchOld(false);
  }

  void retry() {
    _resetData();
    _resetError();
    _initialFetch();
  }

  Future<void> fetchNew() async {
    assert(_dataList != null);

    final res = await _fetchNew(_hasData
        ? _dataList!.first.sortKey
        : DateTime.parse(
            "1900-01-01T00:00:00.001000+09:00") /* 現在の日時からずっと過去の日時 */);
    _error = res.error;
    if (error != null) {
      _notify();
      return;
    }
    _dataList = [
      ...res.data,
      ..._dataList!,
    ];
    _notify();
  }

  void _initialFetch() {
    fetchOld(false);
  }

  void _resetData() {
    _dataList = null;
  }

  void _resetError() {
    _error = null;
  }
}
