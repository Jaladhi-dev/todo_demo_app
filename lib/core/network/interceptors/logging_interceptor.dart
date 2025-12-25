import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('Request: ${options.method} ${options.path}');
    AppLogger.debug('Headers: ${options.headers}');
    AppLogger.debug('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      'Response: ${response.statusCode} ${response.requestOptions.path}',
    );
    AppLogger.debug('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'Error: ${err.message} ${err.requestOptions.path}',
      err.error,
      err.stackTrace,
    );
    handler.next(err);
  }
}
