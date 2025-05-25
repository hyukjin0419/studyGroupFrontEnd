import 'package:flutter/cupertino.dart';

mixin LoadingNotifier on ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<T> runWithLoading<T>(Future<T> Function() task) async {
    _setLoading(true);
    try{
      return await task();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}