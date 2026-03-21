import '/plugins.dart';
import 'package:dio/dio.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;
  static HttpUtil get instance => _instance;

  late Dio _dio;

  HttpUtil._internal() {
    BaseOptions options = BaseOptions();
    options.connectTimeout = const Duration(seconds: 10);
    options.receiveTimeout = const Duration(seconds: 10);
    options.contentType = 'application/json; charset=utf-8';
    options.responseType = ResponseType.json;

    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); //continue
      },
      onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
      },
      // onError: (DioError e, handler) {
      //   ErrorEntity eInfo = createErrorEntity(e);
      //   onError(eInfo);
      //   return handler.next(e); //continue
      // },
    ));
  }
  // 请求(默认post)
  Future _request(BuildContext? context, String url,
      {String method = "post", Map<String, dynamic>? params}) async {
    Options options = Options(method: method);

    try {
      final result =
          await _dio.request(url, queryParameters: params, options: options);

      return result;
    } on DioException {
      if (context != null && context.mounted) {
        final snackBar = SnackBar(
          content: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: const Text(
                '数据解析异常, 请稍后重试',
              ),
            ),
          ),
        );
        ScaffoldMessenger.of(context).removeCurrentSnackBar(
          reason: SnackBarClosedReason.remove,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<T> get<T>(
    BuildContext? context,
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? requestOptions,
  }) async {
    var response =
        await _request(context, url, method: "get", params: queryParameters);
    // print(response);
    return response?.data;
  }

  Future<T> post<T>(
    BuildContext? context,
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? requestOptions,
  }) async {
    var response =
        await _request(context, url, method: "post", params: queryParameters);
    // print(response);
    return response?.data;
  }
}
