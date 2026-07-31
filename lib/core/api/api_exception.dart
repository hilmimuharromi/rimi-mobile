class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

/// Unwraps BE envelope `{ data, message }` or throws on `{ error, code }`.
T unwrapData<T>(dynamic body, T Function(dynamic raw) map) {
  if (body is! Map) {
    throw ApiException(message: 'Respons tidak valid');
  }
  if (body['error'] != null) {
    throw ApiException(
      message: body['error']?.toString() ?? 'Terjadi kesalahan',
      code: body['code']?.toString(),
    );
  }
  return map(body['data']);
}
