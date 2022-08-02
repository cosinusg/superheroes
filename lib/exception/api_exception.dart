// ignore_for_file: public_member_api_docs, sort_constructors_first
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);

  @override
  String toString() => 'ApiException(message: $message)';
}
