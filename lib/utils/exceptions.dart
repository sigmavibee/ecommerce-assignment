// lib/exceptions/api_exceptions.dart
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized access"]);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = "Forbidden access"]);
  @override
  String toString() => 'ForbiddenException: $message';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'ApiException[$statusCode]: $message'
      : 'ApiException: $message';
}
