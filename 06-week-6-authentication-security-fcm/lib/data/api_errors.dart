import 'package:dio/dio.dart';

String apiErrorMessage(DioException error) {
  if (error.response?.statusCode == 401) {
    return 'Sesi berakhir. Silakan login kembali.';
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'Koneksi terlalu lama. Coba lagi.',
    DioExceptionType.connectionError =>
      'Tidak ada koneksi internet.',
    _ => 'Terjadi kesalahan. Coba lagi.',
  };
}