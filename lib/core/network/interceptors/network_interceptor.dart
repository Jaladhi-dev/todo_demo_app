import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkInterceptor extends Interceptor {
  final InternetConnectionChecker _connectionChecker;

  NetworkInterceptor(this._connectionChecker);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await _connectionChecker.hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );
    }
    return handler.next(options);
  }
}
