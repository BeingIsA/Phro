class CancenToken {
  bool _isCanceled = false;

  CancenToken();

  void cancel() {
    _isCanceled = true;
  }

  bool isCanceled() {
    return _isCanceled;
  }
}
