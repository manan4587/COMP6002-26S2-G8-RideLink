import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static Future<bool> get isConnected async {
    List<ConnectivityResult> result = await (Connectivity().checkConnectivity());

    bool isConnected = result.contains(ConnectivityResult.none);

    if (!isConnected) {
      return true;
    }
    return false;
  }
}
