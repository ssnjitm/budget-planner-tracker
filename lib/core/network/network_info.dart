import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get hasConnection async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Stream<bool> get connectionChanges => _connectivity.onConnectivityChanged
      .map((results) => results.any((result) => result != ConnectivityResult.none))
      .distinct();
}
