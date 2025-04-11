import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class UnsafeHttpClient {
  static http.Client create() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    return IOClient(ioClient);
  }
}
