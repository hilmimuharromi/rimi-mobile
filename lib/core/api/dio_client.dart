import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_config.dart';
import 'api_exception.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

final dioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = prefs.getString(AppConfig.accessTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final data = error.response?.data;

        // Attempt refresh once on 401
        if (status == 401 && error.requestOptions.extra['retried'] != true) {
          final refresh = prefs.getString(AppConfig.refreshTokenKey);
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiUrl));
              final res = await refreshDio.post(
                '/auth/refresh',
                data: {'refresh_token': refresh},
              );
              final body = res.data;
              if (body is Map && body['data'] is Map) {
                final d = body['data'] as Map;
                final access = d['access_token']?.toString();
                final newRefresh = d['refresh_token']?.toString();
                if (access != null) {
                  await prefs.setString(AppConfig.accessTokenKey, access);
                  if (newRefresh != null) {
                    await prefs.setString(AppConfig.refreshTokenKey, newRefresh);
                  }
                  final req = error.requestOptions;
                  req.headers['Authorization'] = 'Bearer $access';
                  req.extra['retried'] = true;
                  final clone = await dio.fetch(req);
                  return handler.resolve(clone);
                }
              }
            } catch (_) {
              await prefs.remove(AppConfig.accessTokenKey);
              await prefs.remove(AppConfig.refreshTokenKey);
              await prefs.remove(AppConfig.userJsonKey);
            }
          }
        }

        String message = 'Koneksi gagal';
        String? code;
        if (data is Map) {
          message = data['error']?.toString() ??
              data['message']?.toString() ??
              message;
          code = data['code']?.toString();
        } else if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          message = 'Timeout — coba lagi';
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'Tidak bisa terhubung ke server';
        }

        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: ApiException(
              message: message,
              statusCode: status,
              code: code,
            ),
          ),
        );
      },
    ),
  );

  return dio;
});
