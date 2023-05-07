import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hacksparker/src/core/utils/exceptions/exception.dart';
import 'package:hacksparker/src/core/utils/logger.dart';
import 'package:hacksparker/src/core/utils/shared_data/api_timeouts.dart';
import 'package:hacksparker/src/core/utils/shared_data/app_urls.dart';

class NetworkRequester {
  late final Dio _dio;

  NetworkRequester() {
    prepareRequest();
  }

  void prepareRequest() {
    BaseOptions dioOptions = BaseOptions(
      connectTimeout: const Duration(milliseconds: ApiTimeouts.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiTimeouts.receiveTimeout),
      baseUrl: AppUrls.baseUrl,
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
      headers: {'Accept': Headers.jsonContentType},
    );

    _dio = Dio(dioOptions);

    _dio.interceptors.clear();

    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options,
                RequestInterceptorHandler requestInterceptorHandler) =>
            requestInterceptor(options, requestInterceptorHandler)));

    _dio.interceptors.add(LogInterceptor(
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
        logPrint: _printLog));
  }

  dynamic requestInterceptor(RequestOptions options,
      RequestInterceptorHandler requestInterceptorHandler) async {
    requestInterceptorHandler.next(options);
  }

  _printLog(Object object) => logger.e(object.toString());

  Future<Response<Map<String, dynamic>>> get(
      {required String path,
      Map<String, dynamic>? query,
      Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path,
          queryParameters: query, options: Options(headers: headers));

      return returnResponse(response);
    } on DioError catch (error) {
      throwSocketException(error);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> post({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path,
          queryParameters: query,
          data: data,
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: headers));

      return returnResponse(response);
    } on DioError catch (error) {
      throwSocketException(error);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> put({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        queryParameters: query,
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      return returnResponse(response);
    } on DioError catch (error) {
      throwSocketException(error);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> patch({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path,
          queryParameters: query, data: data);
      return returnResponse(response);
    } on DioError catch (error) {
      throwSocketException(error);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> delete({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(path,
          queryParameters: query, data: data);
      return returnResponse(response);
    } on DioError catch (error) {
      throwSocketException(error);
      rethrow;
    }
  }

  void throwSocketException(DioError error) {
    if (error.error is SocketException ||
        error.type == DioErrorType.connectionTimeout) {
      throw const SocketException('No Internet');
    }
  }

  Response<Map<String, dynamic>> returnResponse(
      Response<Map<String, dynamic>> response) {
    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
        throw BadRequestExceptionDio();
      case 403:
        throw UnauthorisedExceptionDio();
      case 500:
        throw InternalServerErrorDio();
      default:
        throw UnexpectedExceptionDio();
    }
  }
}
