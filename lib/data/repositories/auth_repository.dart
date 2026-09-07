import '../handler/api_endpoints_url.dart';
import '../services/client/client_service.dart';
import '../services/client/result.dart';

class AuthRepository extends ClientService {
  Future<Result<BaseResponse, String>> signIn({
    required Map<String, dynamic> data,
  }) {
    return request(
      requestType: RequestType.post,
      path: ApiEndpoints.signIn,
      data: data,
    );
  }
}
