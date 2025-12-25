class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Endpoints
  static const String todosEndpoint = '/todos';
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
